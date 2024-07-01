import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  late User _user;
  late Map<String, dynamic> _userData;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user.uid).get();
    setState(() {
      _userData = userDoc.data() as Map<String, dynamic>;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    try {
      final ref = _storage.ref().child('profile_pictures/${_user.uid}');
      await ref.putFile(_imageFile!);
      final url = await ref.getDownloadURL();
      await _firestore.collection('users').doc(_user.uid).update({'profileImageUrl': url});
      setState(() {
        _userData['profileImageUrl'] = url;
      });
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image: $e');
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
      body: _userData == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFc0dfef)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 20),
                    _buildProfileInfo(),
                    const SizedBox(height: 20),
                    _buildProfileActions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 60,
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : CachedNetworkImageProvider(_userData['profileImageUrl']) as ImageProvider,
            child: _imageFile == null
                ? Icon(Icons.camera_alt, color: Colors.white, size: 30)
                : null,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _userData['username'],
          style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          '${_userData['firstName']} ${_userData['lastName']}',
          style: GoogleFonts.montserrat(fontSize: 18, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Âge', _userData['age'].toString()),
        _buildInfoRow('Sexe', _userData['gender']),
        _buildInfoRow('Orientation sexuelle', _userData['orientation']),
        _buildInfoRow('Région', _userData['region']),
        _buildInfoRow('Ville', _userData['city']),
        _buildInfoRow('Type de relation', _userData['relationType']),
        const SizedBox(height: 10),
        Text(
          'Description',
          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          _userData['description'],
          style: GoogleFonts.montserrat(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: const Color(0xFFfd6c9e)),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Action pour modifier le profil
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFfd6c9e),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: const Text('Modifier le profil'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // Action pour se déconnecter
            _auth.signOut();
            Navigator.of(context).pushReplacementNamed('/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: const Text('Se déconnecter'),
        ),
      ],
    );
  }
}