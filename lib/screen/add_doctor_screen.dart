import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddDoctorScreen extends StatelessWidget {
  const AddDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController specialtyController = TextEditingController();

    void addDoctor() {
      final String name = nameController.text;
      final String specialty = specialtyController.text;

      if (name.isNotEmpty && specialty.isNotEmpty) {
        FirebaseFirestore.instance.collection('doctors').add({
          'name': name,
          'specialty': specialty,
        }).then((_) {
          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doctor added successfully'),
            ),
          );

          // Clear text fields
          nameController.clear();
          specialtyController.clear();
        }).catchError((error) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add doctor: $error'),
            ),
          );
        });
      } else {
        // Show validation error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all fields'),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: specialtyController,
            decoration: const InputDecoration(labelText: 'Specialty'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: addDoctor,
            child: const Text('Add Doctor'),
          ),
        ],
      ),
    );
  }
}
