import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  String _errorMessage = '';
  String? _selectedGender;
  String? _selectedOrientation;
  String? _selectedRelationType;
  String? _selectedRegion;
  String? _selectedCity;
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  File? _profileImage;

  final List<String> _regions = ['Guyane', 'Martinique', 'Guadeloupe'];
  final Map<String, List<String>> _cities = {
    'Guyane': [
      'Cayenne', 'Kourou', 'Saint-Laurent-du-Maroni', 'Rémire-Montjoly', 'Matoury',
      'Macouria', 'Approuague-Kaw', 'Awala-Yalimapo', 'Camopi', 'Grand-Santi',
      'Iracoubo', 'Mana', 'Maripasoula', 'Ouanary', 'Papaïchton', 'Roura', 'Saül',
      'Sinnamary', 'Saint-Elie', 'Saint-Georges'
    ],
    'Martinique': [
      'Fort-de-France', 'Le Lamentin', 'Le Robert', 'Sainte-Marie', 'Le François',
      'Ducos', 'Rivière-Salée', 'Saint-Joseph', 'Schoelcher', 'Gros-Morne',
      'Le Marin', 'Sainte-Luce', 'La Trinité', 'Saint-Pierre', 'Le Vauclin'
    ],
    'Guadeloupe': [
      'Les Abymes', 'Baie-Mahault', 'Le Gosier', 'Petit-Bourg', 'Sainte-Anne',
      'Pointe-à-Pitre', 'Morne-à-l\'Eau', 'Saint-François', 'Sainte-Rose',
      'Capesterre-Belle-Eau', 'Le Moule', 'Lamentin', 'Basse-Terre', 'Saint-Claude'
    ],
  };
  final List<String> _orientations = ['Hétérosexuel', 'Lesbienne', 'Gay', 'Bisexuel (féminin)'];
  final List<String> _relationTypes = ['Red Charmeur', 'Blue Charmeur'];
  final List<String> _genders = ['Masculin', 'Féminin'];

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFfd6c9e)),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFc0dfef)) : null,
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFfd6c9e)),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Informations personnelles',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFfd6c9e),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFc0dfef)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: _inputDecoration('Que recherchez-vous ?', icon: Icons.search),
                              value: _selectedRelationType,
                              items: _relationTypes
                                  .map((value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRelationType = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez sélectionner une option';
                                }
                                return null;
                              },
                            ),
                          ),
                          Tooltip(
                            message: _selectedRelationType == 'Red Charmeur' 
                                ? 'Relation sans engagement' 
                                : 'Relation sérieuse',
                            child: Icon(Icons.info_outline, color: const Color(0xFFc0dfef)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: _inputDecoration('Email', icon: Icons.email),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: _inputDecoration('Mot de passe', icon: Icons.lock).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFFc0dfef),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          if (value.length < 8) {
                            return 'Le mot de passe doit contenir au moins 8 caractères';
                          }
                          if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) {
                            return 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: _inputDecoration('Confirmer le mot de passe', icon: Icons.lock).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFFc0dfef),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer votre mot de passe';
                          }
                          if (value != _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: _inputDecoration('Nom d\'utilisateur', icon: Icons.person),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom d\'utilisateur';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: _inputDecoration('Prénom', icon: Icons.person_outline),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre prénom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: _inputDecoration('Nom de famille', icon: Icons.family_restroom),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom de famille';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        decoration: _inputDecoration('Âge', icon: Icons.cake),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre âge';
                          }
                          int? age = int.tryParse(value);
                          if (age == null) {
                            return 'Veuillez entrer un âge valide';
                          }
                          if (age < 18) {
                            return 'Vous devez avoir au moins 18 ans pour vous inscrire';
                          }
                          if (age > 99) {
                            return 'Veuillez entrer un âge valide (maximum 99 ans)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration('Sexe', icon: Icons.wc),
                        value: _selectedGender,
                        items: _genders
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner votre sexe';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration('Orientation sexuelle', icon: Icons.favorite),
                        value: _selectedOrientation,
                        items: _orientations
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedOrientation = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner une orientation sexuelle';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration('Région', icon: Icons.location_on),
                        value: _selectedRegion,
                        items: _regions
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRegion = value;
                            _selectedCity = null;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner une région';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration('Ville', icon: Icons.location_city),
                        value: _selectedCity,
                        items: _selectedRegion != null
                            ? _cities[_selectedRegion]!
                                .map((value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ))
                                .toList()
                            : [],
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner une ville';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration('Décrivez-vous', icon: Icons.description),
                        maxLines: null,
                        minLines: 3,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez vous décrire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _acceptTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            _acceptTerms = value!;
                          });
                        },
                        title: const Text('En cochant vous acceptez les conditions générales de vente et d\'utilisation'),
                        activeColor: const Color(0xFFc0dfef),
                      ),
                      CheckboxListTile(
                        value: _acceptPrivacy,
                        onChanged: (bool? value) {
                          setState(() {
                            _acceptPrivacy = value!;
                          });
                        },
                        title: const Text('En cochant vous acceptez la politique de vie privée'),
                        activeColor: const Color(0xFFc0dfef),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _showSummary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFfd6c9e),
                          foregroundColor: Colors.white,
                          textStyle: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Suivant'),
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _showSummary() {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms || !_acceptPrivacy) {
        setState(() {
          _errorMessage = !_acceptTerms && !_acceptPrivacy
              ? 'Veuillez accepter les conditions générales et la politique de vie privée.'
              : !_acceptTerms
                  ? 'Veuillez accepter les conditions générales.'
                  : 'Veuillez accepter la politique de vie privée.';
        });
        return;
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Résumé de vos informations',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: const Color(0xFFfd6c9e),
                fontSize: 24,
              ),
            ),
            content: Container(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildSummaryItem('Âge', _ageController.text),
                    _buildSummaryItem('Pseudo', _usernameController.text),
                    _buildSummaryItem('Nom et prénom', '${_firstNameController.text} ${_lastNameController.text}'),
                    _buildSummaryItem('Adresse email', _emailController.text),
                    _buildSummaryItem('Région', _selectedRegion ?? ''),
                    _buildSummaryItem('Ville', _selectedCity ?? ''),
                    _buildSummaryItem('Description', _descriptionController.text),
                    _buildSummaryItem('Sexe', _selectedGender ?? ''),
                    _buildSummaryItem('Orientation sexuelle', _selectedOrientation ?? ''),
                    _buildSummaryItem('Type de relation', _selectedRelationType ?? ''),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Précédent', style: TextStyle(color: Color(0xFFc0dfef))),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Finaliser l\'inscription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFfd6c9e),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _register();
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs obligatoires et accepter les conditions.';
      });
    }
  }

  Widget _buildSummaryItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFc0dfef).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFfd6c9e),
            ),
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

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String? profileImageUrl;
      if (_profileImage != null) {
        Reference ref = _storage.ref().child('profile_images/${userCredential.user!.uid}');
        UploadTask uploadTask = ref.putFile(_profileImage!);
        TaskSnapshot snapshot = await uploadTask;
        profileImageUrl = await snapshot.ref.getDownloadURL();
      }

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text,
        'username': _usernameController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'age': int.parse(_ageController.text),
        'gender': _selectedGender,
        'orientation': _selectedOrientation,
        'relationType': _selectedRelationType,
        'region': _selectedRegion,
        'city': _selectedCity,
        'description': _descriptionController.text,
        'profileImageUrl': profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          _errorMessage = 'Le mot de passe fourni est trop faible.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'Un compte existe déjà pour cet email.';
        } else {
          _errorMessage = 'Une erreur s\'est produite. Veuillez réessayer.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur inattendue s\'est produite: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
