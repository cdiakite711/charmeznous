import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Profil',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFfd6c9e),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _userData['profileImageUrl'] != null
                  ? NetworkImage(_userData['profileImageUrl'])
                  : AssetImage(_userData['gender'] == 'Féminin'
                      ? 'assets/images/default_female_profile.png'
                      : 'assets/images/default_male_profile.png') as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              '${_userData['firstName'] ?? ''} ${_userData['lastName'] ?? ''}',
              style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Ajoutez ici d'autres informations du profil que vous souhaitez afficher
          ],
        ),
      ),
    );
  }
}
