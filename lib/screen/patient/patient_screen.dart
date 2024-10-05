import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorspoint/screen/patient/patient_doctor_home_screen.dart';
import 'package:doctorspoint/screen/patient/patient_appointment_schedule_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doctorspoint/screen/auth/login_screen.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  int _selectedIndex = 0;
  String? _selectedSpecialty;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSpecialtySelected(String specialty) {
    setState(() {
      _selectedSpecialty = specialty;
      _selectedIndex = 0; // Go to HomeScreen
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final doctors = snapshot.data!.docs;
            final specialties = doctors
                .map((doc) => doc['specialty'] as String)
                .toSet()
                .toList();

            return ListView.builder(
              itemCount: specialties.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(specialties[index]),
                  onTap: () {
                    _onSpecialtySelected(specialties[index]);
                  },
                );
              },
            );
          },
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          PatientDoctorHomeScreen(specialty: _selectedSpecialty),
          const PatientAppointmentScheduleScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Selected Doctor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointment Schedule',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
