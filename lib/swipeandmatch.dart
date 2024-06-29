import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart';
import 'firebase_options.dart';

class SwipeAndMatchPage extends StatefulWidget {
  SwipeAndMatchPage({Key? key}) : super(key: key);

  @override
  _SwipeAndMatchPageState createState() => _SwipeAndMatchPageState();
}

class _SwipeAndMatchPageState extends State<SwipeAndMatchPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DocumentSnapshot> matches = [];
  List<DocumentSnapshot> receivedCharms = [];
  List<DocumentSnapshot> sentCharms = [];
  List<DocumentSnapshot> profiles = [];

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
    _fetchMatches();
    _fetchReceivedCharms();
    _fetchSentCharms();
  }

  void _fetchProfiles() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var userDoc = await _firestore.collection('users').doc(user.uid).get();
      var userData = userDoc.data();
      var genderPreference = userData!['genderPreference'];

      var querySnapshot = await _firestore
          .collection('users')
          .where('gender', isEqualTo: genderPreference)
          .get();
      setState(() {
        profiles = querySnapshot.docs;
      });
    }
  }

  void _fetchMatches() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var querySnapshot = await _firestore
          .collection('matches')
          .where('users', arrayContains: user.uid)
          .get();
      setState(() {
        matches = querySnapshot.docs;
      });
    }
  }

  void _fetchReceivedCharms() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var querySnapshot = await _firestore
          .collection('charms')
          .where('receiver', isEqualTo: user.uid)
          .get();
      setState(() {
        receivedCharms = querySnapshot.docs;
      });
    }
  }

  void _fetchSentCharms() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var querySnapshot = await _firestore
          .collection('charms')
          .where('sender', isEqualTo: user.uid)
          .get();
      setState(() {
        sentCharms = querySnapshot.docs;
      });
    }
  }

  void _likeProfile(DocumentSnapshot profile) async {
    User? user = _auth.currentUser;
    if (user != null) {
      var userDoc = await _firestore.collection('users').doc(user.uid).get();
      var userData = userDoc.data();

      await _firestore.collection('charms').add({
        'sender': user.uid,
        'receiver': profile.id,
        'timestamp': FieldValue.serverTimestamp(),
      });

      var charmDoc = await _firestore
          .collection('charms')
          .where('sender', isEqualTo: profile.id)
          .where('receiver', isEqualTo: user.uid)
          .get();

      if (charmDoc.docs.isNotEmpty) {
        await _firestore.collection('matches').add({
          'users': [user.uid, profile.id],
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Remove from charms collection
        await _firestore
            .collection('charms')
            .doc(charmDoc.docs[0].id)
            .delete();
      }

      _fetchMatches();
      _fetchReceivedCharms();
      _fetchSentCharms();
    }
  }

  void _dislikeProfile(DocumentSnapshot profile) {
    setState(() {
      profiles.remove(profile);
    });
  }

  Widget _buildProfileCard(DocumentSnapshot profile) {
    var profileData = profile.data() as Map<String, dynamic>;
    return Card(
      child: Column(
        children: [
          Image.network(profileData['profilePictureUrl']),
          Text(profileData['username']),
          Text('${profileData['age']} ans'),
          Text(profileData['region']),
          Text(profileData['city']),
          Text(profileData['description']),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => _dislikeProfile(profile),
              ),
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () => _likeProfile(profile),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMatches() {
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        var match = matches[index];
        var matchData = match.data() as Map<String, dynamic>;
        var otherUserId = matchData['users']
            .firstWhere((uid) => uid != _auth.currentUser!.uid);
        return ListTile(
          title: Text('Match with $otherUserId'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(userId: otherUserId),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceivedCharms() {
    return ListView.builder(
      itemCount: receivedCharms.length,
      itemBuilder: (context, index) {
        var charm = receivedCharms[index];
        var charmData = charm.data() as Map<String, dynamic>;
        return ListTile(
          title: Text('Charm from ${charmData['sender']}'),
        );
      },
    );
  }

  Widget _buildSentCharms() {
    return ListView.builder(
      itemCount: sentCharms.length,
      itemBuilder: (context, index) {
        var charm = sentCharms[index];
        var charmData = charm.data() as Map<String, dynamic>;
        return ListTile(
          title: Text('Charm sent to ${charmData['receiver']}'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Swipe & Match'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Matchs'),
              Tab(text: 'Charmes reçus'),
              Tab(text: 'Charmes envoyés'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMatches(),
            _buildReceivedCharms(),
            _buildSentCharms(),
          ],
        ),
      ),
    );
  }
}
