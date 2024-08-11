// TODO Implement this library.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crimebook/models/all_crime_models/crimefeedback.dart';

import '../../../blocs/all_crime_bloc/crime_feedback_bloc.dart'; // Import CrimeFeedback model

class CrimeFeedbackWidget extends StatefulWidget {
  final String crimeId;

  CrimeFeedbackWidget({Key? key, required this.crimeId}) : super(key: key);

  @override
  State<CrimeFeedbackWidget> createState() => _CrimeFeedbackWidgetState();
}

class _CrimeFeedbackWidgetState extends State<CrimeFeedbackWidget> {
  CrimeFeedback crimeFeedback = CrimeFeedback();

  CrimeFeedbackBloc crimeFeedbackBloc = CrimeFeedbackBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: crimeFeedbackBloc.fetchCrimeFeedbackByCrimeId(widget.crimeId),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
                width: 32.0, height: 32.0, child: new CupertinoActivityIndicator()),
          );
        }
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Feedback:",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (crimeFeedback.crimeId != null)
                Text(
                  "Crime ID is: ${crimeFeedback.crimeId!}",
                  style: const TextStyle(fontSize: 16),
                ),
// Display Judge Feedback
              if (crimeFeedback.judgeLikedConclusionCount != null ||
                  crimeFeedback.judgeDislikedConclusionCount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Judge Feedback:",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (crimeFeedback.judgeLikedConclusionCount != null)
                      Text(
                        "Liked Conclusion: ${crimeFeedback.judgeLikedConclusionCount} judges",
                        style: const TextStyle(fontSize: 14),
                      ),
                    if (crimeFeedback.judgeDislikedConclusionCount != null)
                      Text(
                        "Disliked Conclusion: ${crimeFeedback.judgeDislikedConclusionCount} judges",
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
// Display AI Feedback
              if (crimeFeedback.aiLikedConclusionCount != null ||
                  crimeFeedback.aiDislikedConclusionCount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI Feedback:",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (crimeFeedback.aiLikedConclusionCount != null)
                      Text(
                        "Liked Conclusion: ${crimeFeedback.aiLikedConclusionCount} AIs",
                        style: const TextStyle(fontSize: 14),
                      ),
                    if (crimeFeedback.aiDislikedConclusionCount != null)
                      Text(
                        "Disliked Conclusion: ${crimeFeedback.aiDislikedConclusionCount} AIs",
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
