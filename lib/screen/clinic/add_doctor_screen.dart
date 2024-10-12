import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For handling the image file

class AddDoctorScreen extends StatelessWidget {
  const AddDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController specialtyController = TextEditingController();
    final TextEditingController qualificationController =
        TextEditingController(); // New qualification controller
    File? selectedImageFile;

    // Function to pick an image from the gallery
    Future<void> pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        selectedImageFile = File(image.path); // Convert XFile to File
      } else {
        selectedImageFile = null;
      }
    }

    // Function to upload image to Firebase Storage and return the download URL
    Future<String?> uploadImage(File imageFile) async {
      try {
        // Create a reference to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child(
            'doctor_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

        // Upload the image file to Firebase Storage
        final uploadTask = storageRef.putFile(imageFile);

        // Wait until the upload completes
        final snapshot = await uploadTask.whenComplete(() {});

        // Get the download URL of the uploaded image
        final downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        print('Failed to upload image: $e');
        return null;
      }
    }

    // Function to add doctor details to Firestore
    void addDoctor() async {
      final String name = nameController.text;
      final String specialty = specialtyController.text;
      final String qualification =
          qualificationController.text; // Get qualification

      if (name.isNotEmpty &&
          specialty.isNotEmpty &&
          qualification.isNotEmpty && // Validate qualification
          selectedImageFile != null) {
        // Upload the image first and get the URL
        final String? imageUrl = await uploadImage(selectedImageFile!);

        if (imageUrl != null) {
          FirebaseFirestore.instance.collection('doctors').add({
            'name': name,
            'specialty': specialty,
            'qualification': qualification, // Save qualification to Firestore
            'imageUrl': imageUrl, // Save the image URL to Firestore
          }).then((_) {
            // Show success snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Doctor added successfully')),
            );

            // Clear text fields
            nameController.clear();
            specialtyController.clear();
            qualificationController.clear(); // Clear qualification field
          }).catchError((error) {
            // Show error snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add doctor: $error')),
            );
          });
        } else {
          // Show error snackbar if image upload fails
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
        }
      } else {
        // Show validation error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill in all fields and select an image')),
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
          TextField(
            controller: qualificationController, // Qualification TextField
            decoration: const InputDecoration(labelText: 'Qualification'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: pickImage, // Button to pick the image
            child: const Text('Select Doctor Image'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: addDoctor, // Button to add the doctor
            child: const Text('Add Doctor'),
          ),
        ],
      ),
    );
  }
}
