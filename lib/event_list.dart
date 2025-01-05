import 'package:flutter/material.dart';
import 'event_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventList extends StatefulWidget {
  const EventList({super.key});

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  List<dynamic> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final response = await http.get(
        Uri.parse('http://fitnessm.ct.ws/getEvents.php'),
      );

      if (response.statusCode == 200) {
        List<dynamic> fetchedEvents = json.decode(response.body);

        setState(() {
          events = fetchedEvents;
        });
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Events')),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : events.isEmpty
          ? const Center(
        child: Text('No events available'),
      )
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(event['event_name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${event['event_date']}'),
                  Text('Venue: ${event['event_venue']}'),
                  Text('Seats: ${event['available_seats']}'),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetails(
                      eventId: int.parse(event['event_id']),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
