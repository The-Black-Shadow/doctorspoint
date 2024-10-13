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
      backgroundColor: Colors.cyan[100],
      appBar: AppBar(
        backgroundColor: Colors.cyan[100],
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
        backgroundColor: Colors.cyan,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
        ),
        child: Column(
          children: [
            // Drawer Header with user info or app logo
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.cyan,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CircleAvatar(
                  //   radius: 30,
                  //   backgroundImage: NetworkImage(
                  //     FirebaseAuth.instance.currentUser?.photoURL ??
                  //         'https://via.placeholder.com/150', // Default image
                  //   ),
                  // ),
                  const Icon(Icons.person, color: Colors.white, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    FirebaseAuth.instance.currentUser?.displayName ??
                        'Patient Email',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ??
                        'patient@example.com',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // List of specialties
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .snapshots(),
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
                        leading: const Icon(Icons.local_hospital,
                            color: Colors.blue),
                        title: Text(
                          specialties[index],
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          _onSpecialtySelected(specialties[index]);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
