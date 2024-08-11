// TODO Implement this library.

import 'package:flutter/material.dart';

class EvidenceCard extends StatelessWidget {
  final String evidenceId;

  const EvidenceCard({Key? key, required this.evidenceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Evidence",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Details: [You can display the evidence details here based on evidenceId]",
              style: const TextStyle(fontSize: 16),
            ),
            // ... (Add more evidence details if needed)
          ],
        ),
      ),
    );
  }
}