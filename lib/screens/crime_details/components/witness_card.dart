// TODO Implement this library.
import 'package:crimebook/utils/next_screen.dart';
import 'package:flutter/material.dart';

import '../../../pages/all_crime_screens/witnessScreens/witnessDetailsScreen.dart';

class WitnessCard extends StatelessWidget {
  final List<String> witnessIds;
  final List<String> evidenceIds;
  final String crimeId;

  const WitnessCard({Key? key, required this.witnessIds, required this.crimeId, required this.evidenceIds}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:(){
        nextScreen(context, WitnessListScreen(witnessIds: witnessIds, crimeId:this.crimeId,evidenceIds: this.evidenceIds,));
      } ,
      child: Card(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12.0),
          child: Text(
            " See All Witness",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}