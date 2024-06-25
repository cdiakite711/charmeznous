import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  String _emailError = '';
  String _passwordError = '';
  bool _isHoveringForgotPassword = false;
  bool _isHoveringRegister = false;
  bool _isHoveringButton = false;

  Future<void> _login() async {
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    if (_emailError.isEmpty && _passwordError.isEmpty) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (userCredential.user != null) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'user-not-found') {
            _emailError = 'Adresse email non trouvée dans la base de données.';
          } else if (e.code == 'wrong-password') {
            _passwordError = 'Mot de passe incorrect. Veuillez vérifier et réessayer.';
          } else {
            _emailError = 'Une erreur est survenue. Veuillez réessayer.';
          }
        });
      } catch (e) {
        setState(() {
          _emailError = 'Une erreur est survenue. Veuillez réessayer.';
        });
      }
    }
  }

  String _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Veuillez entrer une adresse email.';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Le format de l\'adresse email est incorrect. Veuillez vérifier et réessayer.';
    }
    return '';
  }

  String _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Veuillez entrer un mot de passe.';
    }
    return '';
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFfd6c9e)),
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
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bon retour parmi nous !',
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFc0dfef),
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration('Email'),
                  style: const TextStyle(color: Colors.black),
                ),
                if (_emailError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      _emailError,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: _inputDecoration('Mot de passe').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  obscureText: _obscureText,
                ),
                if (_passwordError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      _passwordError,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _isHoveringButton = true),
                  onExit: (_) => setState(() => _isHoveringButton = false),
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isHoveringButton ? const Color(0xFF87CEEB) : const Color(0xFFFD6C9E),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Connexion',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/forgotPassword'),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _isHoveringForgotPassword = true),
                    onExit: (_) => setState(() => _isHoveringForgotPassword = false),
                    child: Text(
                      'Mot de passe oublié ?',
                      style: GoogleFonts.openSans(
                        color: _isHoveringForgotPassword ? const Color(0xFF87CEEB) : const Color(0xFFFD6C9E),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/register'),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _isHoveringRegister = true),
                    onExit: (_) => setState(() => _isHoveringRegister = false),
                    child: RichText(
                      text: TextSpan(
                        text: 'Vous êtes nouveau ? ',
                        style: GoogleFonts.openSans(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' inscrivez-vous',
                            style: GoogleFonts.openSans(
                              color: _isHoveringRegister ? const Color(0xFF87CEEB) : const Color(0xFFFD6C9E),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
