import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final appointments = snapshot.data!.docs;

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Patient: ${appointments[index]['patientName']}'),
              subtitle: Text('Doctor: ${appointments[index]['doctorName']}'),
            );
          },
        );
      },
    );
  }
}
