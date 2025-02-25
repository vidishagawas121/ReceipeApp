import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'sign_up.dart';
import 'explorer_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maharashtrian Recipes',
      home: AuthWrapper(), // Redirects based on authentication state
      routes: {
        '/signup': (context) => SignupPage(),
        '/explorer': (context) => ExplorerPage(),
      },
    );
  }
}

// Decides whether to show ExplorerPage or LoginPage
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ExplorerPage(); // Show home if logged in
        } else {
          return LoginPage(); // Show login if not logged in
        }
      },
    );
  }
}
