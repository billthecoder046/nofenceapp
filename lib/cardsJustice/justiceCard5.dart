import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crimebook/widgets/video_icon.dart';

import '../models/all_crime_models/crime.dart';
import '../utils/cached_image.dart';

class JusticeCard5 extends StatelessWidget {
  final Crime d;
  final String heroTag;
  const JusticeCard5({Key? key, required this.d, required this.heroTag})
      : super(key: key);


  final String noImage = "https://static.vecteezy.com/system/resources/previews/004/141/669/original/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg";

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Theme.of(context).shadowColor, blurRadius: 10, offset: Offset(0, 3))
              ]),
          child: Wrap(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 160,
                    width: MediaQuery.of(context).size.width,
                    child: Hero(
                      tag: heroTag,
                      child: CustomCacheImage(
                        imageUrl: d.evidence?[0]??noImage,
                        radius: 5.0,
                        circularShape: false,
                      ),
                    ),
                  ),
                  VideoIcon(contentType: d.crimeCategory.toString(), iconSize: 80,)
                ],
              ),
              Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.userTitle!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.time,
                          size: 16,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          d.userDescription!,
                          style: TextStyle(fontSize: 12, color: Theme.of(context).secondaryHeaderColor),
                        ),
                        Spacer(),
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          0.toString(),
                          style: TextStyle(fontSize: 12, color: Theme.of(context).secondaryHeaderColor),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          // navigateToDetailsScreen(context, d, heroTag);
        }
    );
  }
}
