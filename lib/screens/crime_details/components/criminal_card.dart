// TODO Implement this library.
import 'package:flutter/material.dart';

class CriminalCard extends StatelessWidget {
  final String criminalId;

  const CriminalCard({Key? key, required this.criminalId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Criminal",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Details: [You can display the criminal details here based on criminalId]",
              style: const TextStyle(fontSize: 16),
            ),
            // ... (Add more criminal details if needed)
          ],
        ),
      ),
    );
  }
}