import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crimebook/blocs/all_crime_bloc/crime_bloc.dart';
import 'package:crimebook/blocs/justice_bloc.dart';
import 'package:crimebook/cardsJustice/justiceCard2.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../cardsJustice/justiceCard4.dart';
import '../cardsJustice/justiceCard5.dart';

class AllIssues extends StatefulWidget {
  AllIssues({Key? key}) : super(key: key);

  @override
  _AllIssuesState createState() => _AllIssuesState();
}

class _AllIssuesState extends State<AllIssues> {
  @override
  Widget build(BuildContext context) {
    final rb = context.watch<CrimeBloc>();

    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(left: 15, top: 15, bottom: 10, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 22,
                  width: 4,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10)),
                ),
                SizedBox(
                  width: 6,
                ),
                Text('Recent Crimes in your Area',
                    style: TextStyle(
                        fontSize: 18,
                        letterSpacing: -0.6,
                        wordSpacing: 1,
                        fontWeight: FontWeight.bold)).tr(),
                
              ],
            )),

        ListView.separated(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
          physics: NeverScrollableScrollPhysics(),
          itemCount: rb.crimes.length != 0 ? rb.crimes.length + 1 : 1,
          separatorBuilder: (BuildContext context, int index) => SizedBox(height: 15,),
          
          shrinkWrap: true,
          itemBuilder: (_, int index) {

            if (index < rb.crimes.length) {
              if(index %3 == 0 && index != 0) return JusticeCard5(d: rb.crimes[index], heroTag: 'recent$index');
              if(index %5 == 0 && index != 0) return JusticeCard4(d: rb.crimes[index], heroTag: 'recent$index');
              else return JusticeCard2(d: rb.crimes[index], heroTag: 'recent$index',);
            }
            return Opacity(
                opacity: rb.isLoadingCrimes ? 1.0 : 0.0,
                child: Center(
                  child: SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: new CupertinoActivityIndicator()),
                ),
              
            );
          },
        )
      ],
    );
  }
}

