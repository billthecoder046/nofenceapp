
import 'package:flutter/material.dart';
import 'package:nofence/blocs/all_crime_bloc/crime_bloc.dart';
import 'package:nofence/blocs/justice_bloc.dart';
import 'package:nofence/blocs/tab_index_bloc.dart';
import 'package:nofence/config/config.dart';
import 'package:nofence/justicePageTabs/tab0.dart';
import 'package:provider/provider.dart';

import '../justicePageTabs/justice_tab1.dart';
import '../justicePageTabs/justice_tab2.dart';
import '../justicePageTabs/justice_tab3.dart';
import '../justicePageTabs/justice_tab4.dart';



class TabMediumCrime extends StatefulWidget {
  final ScrollController? sc;
  final TabController? tc;
  TabMediumCrime({Key? key, this.sc, this.tc}) : super(key: key);

  @override
  _TabMediumCrimeState createState() => _TabMediumCrimeState();
}

class _TabMediumCrimeState extends State<TabMediumCrime> {
  
  @override
  void initState() {
    super.initState();
    this.widget.sc!.addListener(_scrollListener);
  }

  void _scrollListener() {
      final db = context.read<CrimeBloc>();
      final sb = context.read<TabIndexBloc>();

      if (sb.tabIndex == 0) {
        if (!db.isLoadingCrimes) {
          if (this.widget.sc!.offset >= this.widget.sc!.position.maxScrollExtent && !this.widget.sc!.position.outOfRange) {
            print("reached the bottom");
            // db.setLoading(true);
            db.fetchAllCrimes();
          }
        }
      } 
      else if(sb.tabIndex == 1){
        if (!db.isLoadingCrimes)  {
          if (this.widget.sc!.offset >= this.widget.sc!.position.maxScrollExtent && !this.widget.sc!.position.outOfRange) {
            print("reached the bottom -t1");
            // cb1.setLoading(true);
            // cb1.getData(mounted, Config().initialCategories[0],);
          }
        }
      }
      else if(sb.tabIndex == 2){
        if (!db.isLoadingCrimes)  {
          if (this.widget.sc!.offset >= this.widget.sc!.position.maxScrollExtent && !this.widget.sc!.position.outOfRange) {
            // print("reached the bottom -t2");
            // cb2.setLoading(true);
            // cb2.getData(mounted, Config().initialCategories[1],);
          }
        }
      }
      else if(sb.tabIndex == 3){
        if (!db.isLoadingCrimes)  {
          if (this.widget.sc!.offset >= this.widget.sc!.position.maxScrollExtent && !this.widget.sc!.position.outOfRange) {
            // print("reached the bottom -t3");
            // cb3.setLoading(true);
            // cb3.getData(mounted, Config().initialCategories[2],);
          }
        }
      }
      else if(sb.tabIndex == 4){
        if (!db.isLoadingCrimes)  {
          if (this.widget.sc!.offset >= this.widget.sc!.position.maxScrollExtent && !this.widget.sc!.position.outOfRange) {
            // print("reached the bottom -t4");
            // cb4.setLoading(true);
            // cb4.getData(mounted, Config().initialCategories[3],);
          }
        }
      }
    
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: <Widget>[
        JusticeTab0(),
        JusticeTab1(
          category: Config().initialCategories[0],
        ),
        JusticeTab2(
          category: Config().initialCategories[1],

        ),
        JusticeTab3(
          category: Config().initialCategories[2],
        ),
        JusticeTab4(
          category: Config().initialCategories[3],
        ),
      ],
      controller: widget.tc,
    );
  }
}