import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doctorspoint/screen/clinic/clinic_screen.dart';
import 'package:doctorspoint/screen/patient/patient_screen.dart';
import 'package:doctorspoint/screen/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;
        if (user != null) {
          print("Authenticated User ID: ${user.uid}");
          await route();
        }

        emailController.clear();
        passwordController.clear();
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to login: ${e.code}')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: $e')));
      }
    }
  }

  Future<void> route() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("Current User ID: ${user.uid}");
      try {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (documentSnapshot.exists) {
          print("Document Data: ${documentSnapshot.data()}");
          String role = documentSnapshot.get('role');
          if (role == 'admin') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const ClinicScreen()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const PatientScreen()));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User data not found')));
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to retrieve user data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: _formkey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter your email' : null,
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter your password' : null,
            ),
            ElevatedButton(
              onPressed: () {
                login(emailController.text, passwordController.text);
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text('Don\'t have an account? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}
