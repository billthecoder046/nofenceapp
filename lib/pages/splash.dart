import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crimebook/config/config.dart';
import 'package:crimebook/pages/welcome.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:provider/provider.dart';
import '../blocs/getxLogics/user_logic.dart';
import '../blocs/sign_in_bloc.dart';
import '../utils/next_screen.dart';
import 'home.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  initializeControllers() async {
    await Get.put(UserLogic());
  }

  afterSplash() {
    final SignInBloc sb = context.read<SignInBloc>();
    Future.delayed(Duration(milliseconds: 1500)).then((value) {
      sb.isSignedIn == true || sb.guestUser == true ? gotoHomePage() : gotoSignInPage();
    });
  }

  gotoHomePage() async {
    print('in home page');
    final SignInBloc sb = context.read<SignInBloc>();
    if (sb.isSignedIn == true) {
      await sb.getDataFromSp();
      var uC = Get.find<UserLogic>();
      if (uC.currentUser.value!.profilePicUrl == null) {
        uC.currentUser.value =
            await uC.getUserDetails(sb.uid!);
        print("My details");
        print(uC.currentUser.value!.toJSON());
      }
    }

    nextScreenReplace(context, HomePage());
  }

  gotoSignInPage() {
    nextScreenReplace(context, WelcomePage());
  }

  @override
  void initState() {
    afterSplash();
    initializeControllers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        body: Center(
            child: Image(
          image: AssetImage(Config().splashIcon),
          height: 120,
          width: 120,
          fit: BoxFit.contain,
        )));
  }
}
