import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'swipeandmatch.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user;
  Map<String, dynamic> _userData = {};
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user.uid).get();
    setState(() {
      _userData = userDoc.data() as Map<String, dynamic>;
      print("Genre de l'utilisateur: ${_userData['gender']}"); // Ajoutez cette ligne
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CharmeZnous',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFfd6c9e),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implémenter la logique des notifications
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Swipe & Match',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        selectedItemColor: const Color(0xFFfd6c9e),
        unselectedItemColor: Colors.grey,
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return SwipeAndMatchPage();
      case 2:
        return _buildMessagesPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bienvenue, ${_userData['firstName'] ?? 'Utilisateur'}!',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFfd6c9e),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SwipeAndMatchPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFfd6c9e),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text('Commencer à swiper'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPage() {
    // TODO: Implémenter la page de recherche
    return const Center(child: Text('Page de recherche'));
  }

  Widget _buildMessagesPage() {
    // TODO: Implémenter la page de messages
    return const Center(child: Text('Page de messages'));
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _userData['profileImageUrl'] != null && _userData['profileImageUrl'].isNotEmpty
                  ? NetworkImage(_userData['profileImageUrl'])
                  : AssetImage(_userData['gender'] == 'Féminin'
                      ? 'assets/images/default_female_profile.png'
                      : 'assets/images/default_male_profile.png') as ImageProvider,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${_userData['firstName']} ${_userData['lastName']}',
            style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Âge: ${_userData['age']}'),
          Text('Genre: ${_userData['gender']}'),
          Text('Orientation: ${_userData['orientation']}'),
          Text('Recherche: ${_userData['relationType']}'),
          Text('Région: ${_userData['region']}'),
          Text('Ville: ${_userData['city']}'),
          const SizedBox(height: 20),
          Text(
            'Description:',
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(_userData['description'] ?? 'Aucune description'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: Implémenter la logique pour modifier le profil
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFfd6c9e),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text('Modifier le profil'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFfd6c9e),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(_userData['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_userData['firstName']} ${_userData['lastName']}',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userData['email'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              // TODO: Implémenter la navigation vers les paramètres
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Aide et support'),
            onTap: () {
              // TODO: Implémenter la navigation vers l'aide et le support
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
    );
  }
}
