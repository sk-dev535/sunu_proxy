import 'package:firebase_auth/firebase_auth.dart';

String messageAuth(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return "L'adresse email n'est pas valide.";
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email ou mot de passe incorrect.';
    case 'email-already-in-use':
      return 'Un compte existe déjà avec cet email.';
    case 'weak-password':
      return 'Mot de passe trop court (6 caractères minimum).';
    case 'network-request-failed':
      return 'Pas de connexion internet.';
    case 'too-many-requests':
      return 'Trop de tentatives. Réessayez plus tard.';
    default:
      return e.message ?? 'Une erreur est survenue.';
  }
}