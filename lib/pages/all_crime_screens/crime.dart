import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:nofence/blocs/all_crime_bloc/crime_bloc.dart';
import 'package:nofence/blocs/justice_bloc.dart';
import 'package:nofence/blocs/tab_index_bloc.dart';
import 'package:nofence/config/config.dart';
import 'package:nofence/pages/search.dart';
import 'package:nofence/utils/app_name.dart';
import 'package:nofence/utils/next_screen.dart';
import 'package:nofence/widgets/drawer.dart';
import 'package:nofence/widgets/tab_medium_crime.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../notifications.dart';

class Crime extends StatefulWidget {
  Crime({Key? key}) : super(key: key);

  @override
  _CrimeState createState() => _CrimeState();
}

class _CrimeState extends State<Crime>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;


  List<Tab> _tabs = [
    Tab(
      text: "crime".tr(),
    ),
    Tab(
      text: CrimeType.Murders.name,
    ),
    Tab(
          text: CrimeType.Theft.name,
    ),
    Tab(
      text: CrimeType.Robbery.name,
    ),
    Tab(
      text: CrimeType.Violence.name,
    ),
    // Tab(
    //   text: CrimeType.Fraud.name,
    // ),
    // Tab(
    //   text: CrimeType.Destruction.name,
    // ),
    // Tab(
    //   text: CrimeType.Accident.name,
    // ),
    // Tab(
    //   text: CrimeType.FireRaising.name,
    // ),
    // Tab(
    //   text: CrimeType.Kidnapping.name,
    // ),
    // Tab(
    //   text: CrimeType.SexualAssault.name,
    // ),
    // Tab(
    //   text: CrimeType.DrugTrafficking.name,
    // ),
    // Tab(
    //   text: CrimeType.DomesticViolence.name,
    // ),
    // Tab(
    //   text: CrimeType.Harassment.name,
    // ),
    // Tab(
    //   text: CrimeType.cybercrime.name,
    // ),
    // Tab(
    //   text: CrimeType.moneyLaundering.name,
    // ),
    // Tab(
    //   text: CrimeType.other.name,
    // ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController!.addListener(() {
      context.read<TabIndexBloc>().setTabIndex(_tabController!.index);
    });
    Future.delayed(Duration(milliseconds: 0)).then((value) {
      context.read<CrimeBloc>().fetchAllCrimes();
      // context.read<JusticeBloc>().fetchAllEvidence();
      // context.read<JusticeBloc>().fetchAllJudgeDecisions();
      // context.read<JusticeBloc>().fetchAllJudges();
      // context.read<JusticeBloc>().fetchAllWitnesses();
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      drawer: DrawerMenu(),
      key: scaffoldKey,
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          new SliverAppBar(
            automaticallyImplyLeading: false,
            centerTitle: false,
            titleSpacing: 0,
            title: AppName(fontSize: 19.0),
            leading: IconButton(
              icon: Icon(
                Feather.menu,
                size: 25,
              ),
              onPressed: () {
                scaffoldKey.currentState!.openDrawer();
              },
            ),
            elevation: 1,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  AntDesign.search1,
                  size: 22,
                ),
                onPressed: () {
                  nextScreen(context, SearchPage());
                },
              ),
              IconButton(
                icon: Icon(
                  LineIcons.bell,
                  size: 25,
                ),
                onPressed: () {
                  nextScreen(context, Notifications());
                },
              ),
              SizedBox(
                width: 5,
              )
            ],
            pinned: true,
            floating: true,
            forceElevated: innerBoxIsScrolled,
            bottom: TabBar(
              labelStyle: TextStyle(
                  fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600),
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Color(0xff5f6368),
              //niceish grey
              isScrollable: true,
              indicator: MD2Indicator(
                //it begins here
                indicatorHeight: 3,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorSize: MD2IndicatorSize.normal,
              ),
              tabs: _tabs,
            ),
          ),
        ];
      }, body: Builder(
        builder: (BuildContext context) {
          final innerScrollController = PrimaryScrollController.of(context);
          return TabMediumCrime(
            sc: innerScrollController,
            tc: _tabController,
          );
        },
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
