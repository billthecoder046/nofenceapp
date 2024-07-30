import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ShowWidgets extends GetxController {

  RxList<XFile> selectedCriminalPics = <XFile>[].obs;

    Widget showImagesHorizontally(context) {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var mediaFile in selectedCriminalPics)
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  padding: EdgeInsets.only(right: 10),
                  height: 150,
                  width: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(mediaFile.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      color: Colors.red, borderRadius: BorderRadius.circular(10)),
                  child: IconButton(
                      onPressed: () {
                        selectedCriminalPics.remove(mediaFile);
                        selectedCriminalPics.refresh();
                      },
                      icon: Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: 20,
                      )),
                )
              ],
            ),
        ],
      ),
    );
  }

}
showMyIndicator(){
  return Center(
    child: SizedBox(
        width: 32.0,
        height: 32.0,
        child:   CupertinoActivityIndicator()),
  );
}
myLogo(height, width){
  return   Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),topRight:Radius.circular(10) ),
        color: Colors.deepOrangeAccent,
      ),
      child: Image.asset('assets/images/icon.png',scale: 1.0,height: height,width: width,));
}

