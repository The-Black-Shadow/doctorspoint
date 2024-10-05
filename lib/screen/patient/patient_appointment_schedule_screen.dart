import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientAppointmentScheduleScreen extends StatelessWidget {
  const PatientAppointmentScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('You are not logged in'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final appointments = snapshot.data!.docs;

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            final date = (appointment['date'] as Timestamp).toDate();
            final formattedDate = DateFormat.yMMMd().format(date);

            return ListTile(
              title: Text('Appointment with Dr. ${appointment['doctorName']}'),
              subtitle: Text('Date: $formattedDate'),
            );
          },
        );
      },
    );
  }
}
