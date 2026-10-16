import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/auth_messages.dart';
import '../widgets/form_style.dart';
import 'merchant_dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _masquer = true;

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final mdp = _passwordController.text.trim();

    if (email.isEmpty || mdp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }
    if (mdp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Le mot de passe doit faire au moins 6 caractères.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // La création du compte connecte déjà l'utilisateur automatiquement
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: mdp);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const MerchantDashboardScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(messageAuth(e))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F0),
        foregroundColor: const Color(0xFF0F4D3A),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: vertPrincipal,
                child: Icon(Icons.storefront, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Créer un compte commerçant',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Rendez votre commerce visible près de chez vous',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: champ('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _masquer,
                decoration: champ('Mot de passe (6 caractères min.)',
                        Icons.lock_outline)
                    .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                        _masquer ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _masquer = !_masquer),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vertPrincipal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Créer mon compte",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Déjà un compte ? Se connecter',
                  style: TextStyle(
                      color: vertPrincipal, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}