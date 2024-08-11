
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crimebook/widgets/video_icon.dart';

import '../models/all_crime_models/crime.dart';
import '../utils/cached_image.dart';

class JusticeCard4 extends StatelessWidget {
  final Crime d;
  final String heroTag;
  const JusticeCard4({Key? key, required this.d, required this.heroTag})
      : super(key: key);


  final String noImage = "https://static.vecteezy.com/system/resources/previews/004/141/669/original/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg";
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(5.0),
              ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                      height: 90,
                      width: 90,
                      child: Hero(
                        tag: heroTag,
                        child:  CustomCacheImage(imageUrl: d.evidence?[0]??noImage, radius: 5.0)
                      )
                      ),

                      VideoIcon(contentType: d.crimeCategory.toString(), iconSize: 40,)
                    ],
              ),
              Expanded(
                              child: Container(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          d.userTitle!,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 20,),


                      Row(
                        children: <Widget>[
                          Icon(
                            CupertinoIcons.time_solid,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            d.userDescription!,
                            style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 13),
                          ),
                          Spacer(),
                          Icon(
                            Icons.favorite,
                            color: Colors.grey,
                            size: 20,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(0.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor, fontSize: 13)),
                          
                          
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      
      onTap: () {
        // navigateToDetailsScreen(context, d, heroTag);
        print("Bilal Saeed");
      }
    );
  }
}
