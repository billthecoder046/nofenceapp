import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:crimebook/blocs/featured_bloc.dart';
import 'package:crimebook/blocs/popular_articles_bloc.dart';
import 'package:crimebook/blocs/recent_articles_bloc.dart';
import 'package:crimebook/blocs/tab_index_bloc.dart';
import 'package:crimebook/config/config.dart';
import 'package:crimebook/pages/search.dart';
import 'package:crimebook/utils/app_name.dart';
import 'package:crimebook/utils/next_screen.dart';
import 'package:crimebook/widgets/drawer.dart';
import 'package:crimebook/widgets/tab_medium.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'notifications.dart';







class Explore extends StatefulWidget {
  Explore({Key? key}) : super(key: key);

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with  AutomaticKeepAliveClientMixin, TickerProviderStateMixin {


  var scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;

  List<Tab> _tabs = [
    Tab(
      text: "explore".tr(),
    ),
    Tab(
      text: Config().initialCategories[0],
    ),
    Tab(
      text: Config().initialCategories[1],
    ),
    Tab(
      text: Config().initialCategories[2],
    ),
    Tab(
      text: Config().initialCategories[3],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController!.addListener(() { 
      context.read<TabIndexBloc>().setTabIndex(_tabController!.index);
    });
    Future.delayed(Duration(milliseconds: 0)).then((value) {
      context.read<FeaturedBloc>().getData();
      context.read<PopularBloc>().getData();
      context.read<RecentBloc>().getData(mounted);
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
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Color(0xff5f6368), //niceish grey
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
            return TabMedium(
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

