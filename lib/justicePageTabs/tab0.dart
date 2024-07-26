import 'package:flutter/material.dart';
import 'package:nofence/blocs/all_crime_bloc/crime_bloc.dart';
import 'package:nofence/blocs/justice_bloc.dart';
import 'package:nofence/widgets/justice_post_issue.dart';
import 'package:provider/provider.dart';

import '../widgets/all_issues.dart';

class JusticeTab0 extends StatefulWidget {

  JusticeTab0({Key? key}) : super(key: key);

  @override
  _JusticeTab0State createState() => _JusticeTab0State();
}

class _JusticeTab0State extends State<JusticeTab0> {


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: ()async {
        context.read<CrimeBloc>().fetchAllCrimes(refresh: true);
        },
          child: SingleChildScrollView(
            key: PageStorageKey('key0'),
              padding: EdgeInsets.all(0),
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
              children: [
                JusticePostIssue(),
                // Featured(),
                // PopularArticles(),
                AllIssues()
              ],
            ),
          ),
        
    
    );
  
  }
}