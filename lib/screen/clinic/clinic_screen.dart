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

        return GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns per row
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio:
                0.65, // Adjusted this for better image and text layout
          ),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            final imageUrl =
                doctor['imageUrl']; // Get the image URL from Firestore
            final name = doctor['name'];
            final specialty = doctor['specialty'];
            final qualification =
                doctor['qualification']; // Get the qualification from Firestore

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image Section
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      child: Image.network(
                        imageUrl,
                        height: 150, // Fixed height for the image
                        width: double.infinity,
                        fit: BoxFit
                            .cover, // Ensures the image covers the area proportionally
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),

                  // Padding for text content
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          specialty,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          qualification, // Display the qualification
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.blueGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
