import 'package:crimebook/pages/all_crime_screens/witnessScreens/showWitnessDetails.dart';
import 'package:crimebook/utils/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../blocs/all_crime_bloc/witness_bloc.dart';
import 'addWitness.dart';

class WitnessListScreen extends StatefulWidget {
  final List<String> witnessIds; // Pass witness IDs from previous screen
  final List<String> evidenceIds; // Pass Evidence IDs from previous screen
  final String crimeId;

   WitnessListScreen({Key? key, required this.witnessIds, required this.crimeId, required this.evidenceIds,}) : super(key: key);

  @override
  _WitnessListScreenState createState() => _WitnessListScreenState();
}

class _WitnessListScreenState extends State<WitnessListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch witnesses based on the provided IDs
    context.read<WitnessBloc>().fetchWitnessesByIds(widget.witnessIds);
  }

  @override
  Widget build(BuildContext context) {
    final witnessBloc = context.watch<WitnessBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Witness List'),
        actions: [
          TextButton(onPressed: (){}, child: TextButton(
            onPressed: (){
              ///Add witness code
              nextScreen(context, WitnessFormScreen(crimeId: widget.crimeId, witnessesList: widget.witnessIds,evidenceList: widget.evidenceIds));
            },
            child: Text("Add Witness"),
          ))
        ],
      ),
      body: witnessBloc.isLoadingWitnesses
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView.builder(
        itemCount: witnessBloc.witnesses.length,
        itemBuilder: (context, index) {
          if(witnessBloc.witnesses.isEmpty){
            return Center(child: Text("No witness found"),);
          }
          final witness = witnessBloc.witnesses[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(witness.profilePicUrl ??
                  'https://www.w3schools.com/howto/img_avatar.png'), // Placeholder image if null
            ),
            title: Text(witness.name ?? 'Unknown Witness'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (witness.cnic != null)
                  Text('CNIC: ${witness.cnic}'),
                // Display mobile number if available
                if (witness.mobileNumber != null)
                  Text('Mobile: ${witness.mobileNumber}'),
                // Display truth/false counters
                Text('Trustworthy: ${witness.truthCounter} / ${witness.falseCounter}'),
              ],
            ),
            onTap: (){
              nextScreen(context, WitnessDetailsScreen(witness: witness));
            },
          );
        },
      ),
    );
  }
}