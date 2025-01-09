import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/themedata.dart';

import 'package:flutter/material.dart';

class ImageViewScreen extends StatefulWidget {
  ImageViewScreen({Key? key, required this.title, required this.image})
      : super(key: key);
  final String title;
  final String image;
  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: Colors.black,
        // padding: EdgeInsets.only(top: 0, left: 0, right: 0),
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 35,
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          color: ThemeClass.whiteColor)),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CachedNetworkImage(
                height: 300,
                imageUrl: '${widget.image.toString()}',
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    Center(child: Icon(Icons.error)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
