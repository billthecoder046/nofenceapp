import 'package:crimebook/pages/phoneAuthScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crimebook/models/article.dart';
import 'package:crimebook/pages/article_details.dart';
import 'package:crimebook/pages/video_article_details.dart';

import '../models/notification.dart';
import '../pages/custom_notification_details.dart';
import '../pages/post_notification_details.dart';

void nextScreen (context, page){
  Navigator.push(context, MaterialPageRoute(
    builder: (context) => page));
}
Future<bool> nextScreenSignUp2 (context, page) async{
  bool value = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => page));
  return value;
}

Future<String> nextScreenWithReturnValue (context, page) async{
  String value =await Navigator.push(context, MaterialPageRoute(
      builder: (context) => page));
  return value;
}


void nextScreeniOS (context, page){
  Navigator.push(context, CupertinoPageRoute(
    builder: (context) => page));
}


void nextScreenCloseOthers (context, page){
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => page), (route) => false);
}

void nextScreenReplace (context, page){
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
}


void nextScreenPopup (context, page){
  Navigator.push(context, MaterialPageRoute(
    fullscreenDialog: true,
    builder: (context) => page),
  );
}
Future<String?> nextScreenCriminalDetails (context, page) async{
  String? criminalId = await Navigator.push(context, MaterialPageRoute(

      builder: (context) => page),
  );
  return criminalId;
}



void navigateToDetailsScreen (context, Article article, String? heroTag){
  if(article.contentType == 'video'){
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => VideoArticleDetails(data: article)),
    );
    
  }else{
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ArticleDetails(data: article, tag: heroTag,)),
    );
  }
}


void navigateToDetailsScreenByReplace (context, Article article, String? heroTag, bool? replace){
  if(replace == null || replace == false){
    navigateToDetailsScreen(context, article, heroTag);
  }else{
    if(article.contentType == 'video'){
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => VideoArticleDetails(data: article)),
      );
    
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ArticleDetails(data: article, tag: heroTag,)),
      );
    }
  }
}


void navigateToNotificationDetailsScreen (context, NotificationModel notificationModel){
  if(notificationModel.postId == null){
    nextScreen(context, CustomNotificationDeatils(notificationModel: notificationModel));
  }else{
    nextScreen(context, PostNotificationDetails(postID: notificationModel.postId!));
  }
}