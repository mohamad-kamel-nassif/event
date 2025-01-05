import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventDetails extends StatefulWidget {
  final int eventId;

  const EventDetails({super.key, required this.eventId});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  Map<String, dynamic> event = {};
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> bookTicket() async {
    final userId = _userIdController.text;  

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter your user ID')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://fitnessm.ct.ws/bookTicket.php'),
        body: {
          'user_id': userId,  
          'event_id': widget.eventId.toString(),
          'seats_booked': _seatsController.text,
        },
      );

      final result = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Error booking ticket')),
      );

      if (result['success'] == true) {
        fetchEventDetails();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> fetchEventDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://fitnessm.ct.ws/getEventDetails.php?event_id=${widget.eventId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          event = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load event details');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event['event_name'] ?? 'Event Details'),
      ),
      body: event.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['event_name'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Date: ${event['event_date']}'),
            Text('Venue: ${event['event_venue']}'),
            Text('Available Seats: ${event['available_seats']}'),
            const SizedBox(height: 20),
            TextField(
              controller: _seatsController,
              decoration: const InputDecoration(
                labelText: 'Enter number of seats to book',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'Enter your user ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: bookTicket,
              child: const Text('Book Tickets'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Booking System',
      home: EventList(),
    );
  }
}

class EventList extends StatelessWidget {
  const EventList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventDetails(eventId: 1)),
            );
          },
          child: const Text('View Event Details'),
        ),
      ),
    );
  }
}
