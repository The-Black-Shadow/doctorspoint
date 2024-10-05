import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorspoint/screen/patient/booking_confirmation_dialouge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientDoctorHomeScreen extends StatelessWidget {
  final String? specialty;

  const PatientDoctorHomeScreen({super.key, this.specialty});

  @override
  Widget build(BuildContext context) {
    final query = specialty != null
        ? FirebaseFirestore.instance
            .collection('doctors')
            .where('specialty', isEqualTo: specialty)
        : FirebaseFirestore.instance.collection('doctors');

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final doctors = snapshot.data!.docs;

        return ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(doctors[index]['name']),
              subtitle: Text(doctors[index]['specialty']),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => BookingConfirmationDialog(
                    doctorId: doctors[index].id,
                    doctorName: doctors[index]['name'],
                    user: FirebaseAuth.instance.currentUser!,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
