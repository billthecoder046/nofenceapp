import 'package:cached_network_image/cached_network_image.dart';
import 'package:crimebook/blocs/getxLogics/user_logic.dart';
import 'package:flutter/material.dart';
import 'package:crimebook/blocs/sign_in_bloc.dart';
import 'package:crimebook/pages/profile.dart';
import 'package:crimebook/utils/next_screen.dart';
import 'package:get/get.dart' hide Trans;
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../pages/all_crime_screens/postIssueScreen.dart';


class JusticePostIssue extends StatelessWidget {
  const JusticePostIssue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    final uC = Get.find<UserLogic>();
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 10),
      height: 65,
      //color: Colors.green,
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
        InkWell(
            child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey[400],
            backgroundImage: sb.guestUser
              ? CachedNetworkImageProvider(sb.defaultUserImageUrl)
              : CachedNetworkImageProvider(uC.currentUser.value!.profilePicUrl.toString())
          ),
          onTap: (){
            nextScreen(context, ProfilePage());
          },
        ),
        SizedBox(width: 10,),
        Expanded(
                  child: InkWell(

            child: Container(
            
            padding: EdgeInsets.only(left: 20, right: 10),
            height: 40,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.centerLeft,
            
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              border: Border.all(color: Colors.grey[400]!, width: 0.5),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
                    'Post Crime'.tr(),
                    style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
            
      ),
      onTap: (){
          nextScreen(context, CrimeFormScreen());
      },
          ),
        ),
        ],
      ),
    );
  }
}