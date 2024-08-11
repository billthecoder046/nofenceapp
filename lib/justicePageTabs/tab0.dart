import 'package:flutter/material.dart';
import 'package:crimebook/blocs/all_crime_bloc/crime_bloc.dart';
import 'package:crimebook/blocs/justice_bloc.dart';
import 'package:crimebook/widgets/justice_post_issue.dart';
import 'package:provider/provider.dart';

import '../widgets/all_issues.dart';

class JusticeTab0 extends StatefulWidget {
  String? category;
  JusticeTab0({Key? key,this.category}) : super(key: key);

  @override
  _JusticeTab0State createState() => _JusticeTab0State();
}

class _JusticeTab0State extends State<JusticeTab0> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(this.mounted && widget.category != null){
      context.read<CrimeBloc>().getCrimesByCategory(widget.category!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: ()async {
        if(widget.category !=null){
          context.read<CrimeBloc>().getCrimesByCategory(widget.category!, refresh: true);
        }else{
          context.read<CrimeBloc>().fetchAllCrimes(refresh: true);
        }

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