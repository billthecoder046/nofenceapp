
import 'package:flutter/material.dart';
import 'package:crimebook/blocs/all_crime_bloc/crime_bloc.dart';
import 'package:crimebook/blocs/justice_bloc.dart';
import 'package:crimebook/blocs/tab_index_bloc.dart';
import 'package:crimebook/config/config.dart';
import 'package:crimebook/justicePageTabs/tab0.dart';
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
      else if(sb.tabIndex == 5){
        if (!db.isLoadingCrimes)  {
          if (this.widget.sc!.offset >= this.widget.sc!.position.maxScrollExtent && !this.widget.sc!.position.outOfRange) {
            // print("reached the bottom -t4");
            // cb4.setLoading(true);
            // cb4.getData(mounted, Config().initialCategories[3],);
          }
        }
      }
      else if(sb.tabIndex == 6){
        if (!db.isLoadingCrimes)  {
          if (this.widget.sc!.offset >= this.widget.sc!.position.maxScrollExtent && !this.widget.sc!.position.outOfRange) {
            // print("reached the bottom -t4");
            // cb4.setLoading(true);
            // cb4.getData(mounted, Config().initialCategories[3],);
          }
        }
      }
      else if(sb.tabIndex == 7){
        if (!db.isLoadingCrimes)  {
          if (this.widget.sc!.offset >= this.widget.sc!.position.maxScrollExtent && !this.widget.sc!.position.outOfRange) {
            // print("reached the bottom -t4");
            // cb4.setLoading(true);
            // cb4.getData(mounted, Config().initialCategories[3],);
          }
        }
      }
      else if(sb.tabIndex == 8){
        if (!db.isLoadingCrimes)  {
          if (this.widget.sc!.offset >= this.widget.sc!.position.maxScrollExtent && !this.widget.sc!.position.outOfRange) {
            // print("reached the bottom -t4");
            // cb4.setLoading(true);
            // cb4.getData(mounted, Config().initialCategories[3],);
          }
        }
      }
      else if(sb.tabIndex == 9){
        if (!db.isLoadingCrimes)  {
          if (this.widget.sc!.offset >= this.widget.sc!.position.maxScrollExtent && !this.widget.sc!.position.outOfRange) {
            // print("reached the bottom -t4");
            // cb4.setLoading(true);
            // cb4.getData(mounted, Config().initialCategories[3],);
          }
        }
      }
      else if(sb.tabIndex == 10){
        if (!db.isLoadingCrimes)  {
          if (this.widget.sc!.offset >= this.widget.sc!.position.maxScrollExtent && !this.widget.sc!.position.outOfRange) {
            // print("reached the bottom -t4");
            // cb4.setLoading(true);
            // cb4.getData(mounted, Config().initialCategories[3],);
          }
        }
      }
      else if(sb.tabIndex == 11){
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
          category: CrimeType.values[0].name,
        ),
        JusticeTab2(
          category: CrimeType.values[1].name,

        ),
        JusticeTab3(
          category: CrimeType.values[2].name,
        ),
        JusticeTab4(
          category: CrimeType.values[3].name,
        ),
        JusticeTab4(
          category: CrimeType.values[4].name,
        ),
        JusticeTab4(
          category: CrimeType.values[5].name,
        ),
        JusticeTab4(
          category: CrimeType.values[6].name,
        ),
        JusticeTab4(
          category: CrimeType.values[7].name,
        ),
        JusticeTab4(
          category: CrimeType.values[8].name,
        ),
        JusticeTab4(
          category: CrimeType.values[9].name,
        ),
        JusticeTab4(
          category: CrimeType.values[10].name,
        ),
        JusticeTab4(
          category: CrimeType.values[11].name,
        ),
      ],
      controller: widget.tc,
    );
  }
}