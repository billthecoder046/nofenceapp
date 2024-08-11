import 'package:flutter/material.dart';

import '../../../models/all_crime_models/witness.dart';

class WitnessDetailsScreen extends StatelessWidget {
  final Witness witness;

  const WitnessDetailsScreen({Key? key, required this.witness}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(witness.name ?? 'Witness Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(witness.profilePicUrl ??
                      'https://www.w3schools.com/howto/img_avatar.png'), // Placeholder image if null
                ),
              ),
              const SizedBox(height: 20),
              Text('Name: ${witness.name ?? 'Unknown'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('CNIC: ${witness.cnic ?? 'N/A'}'),
              const SizedBox(height: 10),
              Text('Mobile Number: ${witness.mobileNumber ?? 'N/A'}'),
              const SizedBox(height: 10),
              Text('Trustworthy: ${witness.truthCounter ?? 0} / ${witness.falseCounter ?? 0}'),
              const SizedBox(height: 20),
              // Add other details here (e.g., associated crimes, reported by, etc.)
            ],
          ),
        ),
      ),
    );
  }
}