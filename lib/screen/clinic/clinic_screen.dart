import 'package:doctorspoint/screen/clinic/add_doctor_screen.dart';
import 'package:doctorspoint/screen/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ClinicScreen extends StatefulWidget {
  const ClinicScreen({super.key});

  @override
  State<ClinicScreen> createState() => _ClinicScreenState();
}

class _ClinicScreenState extends State<ClinicScreen> {
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
      _selectedIndex = 0; // Go to ClinicDoctorHomeScreen
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic'),
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
          stream:
              FirebaseFirestore.instance.collection('specialties').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final specialties = snapshot.data!.docs;

            return ListView.builder(
              itemCount: specialties.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(specialties[index]['name']),
                  onTap: () {
                    setState(() {
                      _selectedSpecialty = specialties[index]['name'];
                      _selectedIndex = 0; // Go to ClinicDoctorHomeScreen
                    });
                    Navigator.pop(context); // Close the drawer
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
          ClinicDoctorHomeScreen(specialty: _selectedSpecialty),
          const ClinicAppointmentScreen(),
          const AddDoctorScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Doctor',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ClinicDoctorHomeScreen extends StatelessWidget {
  final String? specialty;

  const ClinicDoctorHomeScreen({super.key, this.specialty});

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
            );
          },
        );
      },
    );
  }
}

class ClinicAppointmentScreen extends StatelessWidget {
  const ClinicAppointmentScreen({super.key});

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
            final appointment = appointments[index];
            final date = (appointment['date'] as Timestamp).toDate();
            final formattedDate = DateFormat.yMMMd().format(date);
            final patientEmail = appointment['patientEmail'] ?? 'Unknown';

            return ListTile(
              title: Text('Appointment with Dr. ${appointment['doctorName']}'),
              subtitle:
                  Text('Patient Email: $patientEmail\nDate: $formattedDate'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('appointments')
                      .doc(appointment.id)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment deleted')),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
