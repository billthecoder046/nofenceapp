import 'package:flutter/material.dart';
import 'package:crimebook/models/all_crime_models/crime.dart';
import 'package:crimebook/models/all_crime_models/witness.dart';
import 'package:crimebook/models/all_crime_models/evidence.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:crimebook/screens/crime_details/components/crime_feedback_widget.dart'; // Add your CrimeFeedbackWidget component
import 'package:crimebook/screens/crime_details/components/judge_remark_widget.dart'; // Add your JudgeRemarkWidget component
import 'package:crimebook/screens/crime_details/components/evidence_card.dart'; // Add your EvidenceCard component
import 'package:crimebook/screens/crime_details/components/witness_card.dart'; // Add your WitnessCard component
import 'package:crimebook/screens/crime_details/components/criminal_card.dart';
import 'package:provider/provider.dart';
import 'package:widget_marker_google_map/widget_marker_google_map.dart';

import '../../blocs/sign_in_bloc.dart';
import '../../models/userModel.dart'; // Add your CriminalCard component

class CrimeDetailsScreen extends StatefulWidget {
  final Crime crime;

  CrimeDetailsScreen({Key? key, required this.crime}) : super(key: key);

  @override
  State<CrimeDetailsScreen> createState() => _CrimeDetailsScreenState();
}

class _CrimeDetailsScreenState extends State<CrimeDetailsScreen> {
  late var cafePosition;

  late var shibuya;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    shibuya = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(
          widget.crime.location!['l'][0], widget.crime.location!['l'][1]),
      zoom: 15.151926040649414,
    );
     print("My run time type is: ${widget.crime.location!['l'][0].runtimeType}");
    cafePosition = LatLng(
        widget.crime.location!['l'][0], widget.crime.location!['l'][1]);
  }

  @override
  Widget build(BuildContext context) {
    final signInBloc = Provider.of<SignInBloc>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crime.userTitle ?? "Crime Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crime Title
            Text(
              widget.crime.userTitle ?? "Crime Details",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Crime Category
            Text(
              "Category: ${widget.crime.crimeCategory?.name ?? 'Unknown'}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),

            // Posted By
            widget.crime.hideUserIdentity
                ? Text("Posted By:  Unknown")
                : FutureBuilder(
                future: signInBloc.getUserObjectfromFirebase(widget.crime.postedBy),
                builder: (context, AsyncSnapshot<MyUser> snapshot) {
                  print(
                      "My snapshot runtime type: ${snapshot.data.toString()}");

                  print("My snapshot runtime type: ${snapshot.data}");
                  if (snapshot.hasData) {
                    MyUser? user = snapshot.data;
                    print("My name: ${user!.name}");
                    return Text("Posted By:  ${snapshot.data!.name}");
                  }
                  return Center(
                    child:
                    SizedBox(width: 32.0, height: 32.0, child: Text('b')),
                  );
                }
            ),

            // Address
            if (widget.crime.address != null)
              Text(
                "Address: ${widget.crime.address}",
                style: const TextStyle(fontSize: 16),
              ),

            // Crime Date
            Text(
              "Crime Date: ${DateFormat('dd/MM/yyyy').format(
                  widget.crime.crimeDate ?? DateTime.now())}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Crime Location
            if (widget.crime.location != null && widget.crime.location!['l'] != null)
              Text(
                "Location:",
                style: const TextStyle(fontSize: 16),
              ),
            SizedBox(
              height: 150,width: 400,
              child: WidgetMarkerGoogleMap(
                initialCameraPosition: shibuya,
                mapType: MapType.normal,
                widgetMarkers: [
                  WidgetMarker(
                    position: cafePosition,
                    markerId: 'cafe',
                    widget: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(2),
                      child:   SizedBox(
                        height: 52,
                        width: 52,
                        child: Image.asset(
                          'assets/images/splash.png',

                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            // Description
            const SizedBox(height: 16),
            Text(
              "Description:",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.crime.userDescription ?? "No description available.",
              style: const TextStyle(fontSize: 16),
            ),

            // Witnesses
            const SizedBox(height: 16),
            Text(
              "Witnesses:",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.crime.witnesses != null && widget.crime.witnesses!.isNotEmpty)
              WitnessCard(witnessIds: widget.crime.witnesses!, crimeId: widget.crime.id!, evidenceIds: widget.crime.evidence??[],)
            else
              const Text(
                "No witnesses reported.",
                style: TextStyle(fontSize: 16),
              ),

            // Evidence
            const SizedBox(height: 16),
            Text(
              "Evidence:",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.crime.evidence != null && widget.crime.evidence!.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.crime.evidence!.length,
                itemBuilder: (context, index) {
                  return EvidenceCard(evidenceId: widget.crime.evidence![index]);
                },
              )
            else
              const Text(
                "No evidence submitted.",
                style: TextStyle(fontSize: 16),
              ),

            // Criminals
            const SizedBox(height: 16),
            Text(
              "Criminals:",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.crime.criminalIds != null && widget.crime.criminalIds!.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.crime.criminalIds!.length,
                itemBuilder: (context, index) {
                  return CriminalCard(criminalId: widget.crime.criminalIds![index]);
                },
              )
            else
              const Text(
                "No criminals associated with this case.",
                style: TextStyle(fontSize: 16),
              ),

            // Crime Status
            const SizedBox(height: 16),
            Text(
              "Status: ${widget.crime.crimeStatus?.name ?? 'Unknown'}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),

            // Conclusion
            if (widget.crime.conclusion != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Conclusion:",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.crime.conclusion!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),

            // Judge Details
            if (widget.crime.assignedJudgeId != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Judge's Remarks:",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.crime.judgeDescription != null)
                    Text(
                      widget.crime.judgeDescription!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  if (widget.crime.judgeRemarks != null &&
                      widget.crime.judgeRemarks!.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.crime.judgeRemarks!.length,
                      itemBuilder: (context, index) {
                        return JudgeRemarkWidget(
                            remark: widget.crime.judgeRemarks![index]);
                      },
                    ),
                ],
              ),

            // Feedback
            if (widget.crime.feedback != null)
              CrimeFeedbackWidget(crimeId: widget.crime.id!),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}