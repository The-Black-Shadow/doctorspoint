import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doctorspoint/screen/login_screen.dart';

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
          HomeScreen(specialty: _selectedSpecialty),
          const AppointmentScheduleScreen(),
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

class HomeScreen extends StatelessWidget {
  final String? specialty;

  const HomeScreen({super.key, this.specialty});

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

class BookingConfirmationDialog extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final User user;

  const BookingConfirmationDialog({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.user,
  });

  @override
  _BookingConfirmationDialogState createState() =>
      _BookingConfirmationDialogState();
}

class _BookingConfirmationDialogState extends State<BookingConfirmationDialog> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMd().format(picked);
      });
    }
  }

  void _bookAppointment() async {
    if (_selectedDate != null) {
      try {
        await FirebaseFirestore.instance.collection('appointments').add({
          'doctorId': widget.doctorId,
          'doctorName': widget.doctorName,
          'date': _selectedDate,
          'patientId': widget.user.uid,
          'patientName': widget.user.displayName ?? 'Unknown',
          'patientEmail': widget.user.email ?? 'Unknown',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment successfully booked')),
        );

        Navigator.of(context).pop();
      } catch (e) {
        print('Error booking appointment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to book appointment')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Book Appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Doctor: ${widget.doctorName}'),
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(labelText: 'Select Date'),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _bookAppointment,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class AppointmentScheduleScreen extends StatelessWidget {
  const AppointmentScheduleScreen({super.key});

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
