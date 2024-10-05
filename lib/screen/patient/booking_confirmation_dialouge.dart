import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorspoint/payment/stripe_chekout_webview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      const stripeCheckoutUrl =
          'https://buy.stripe.com/test_14k148av7bniaE8dQS';
      try {
        // Launch Stripe checkout web view
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const StripeCheckoutWebView(url: stripeCheckoutUrl),
          ),
        );
        if (result == 'success') {
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
        }

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
