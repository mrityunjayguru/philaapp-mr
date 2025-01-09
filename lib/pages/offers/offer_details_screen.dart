import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/model/offer_list_model.dart';

import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';

import 'package:flutter/material.dart';

class OfferDetailsscreen extends StatefulWidget {
  OfferDetailsscreen({Key? key, required this.offer}) : super(key: key);
  final OfferModel offer;
  @override
  State<OfferDetailsscreen> createState() => _OfferDetailsscreenState();
}

class _OfferDetailsscreenState extends State<OfferDetailsscreen> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      // ignore: prefer_const_constructors
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBarForMap(),
      ),
      body: Container(
          // padding: EdgeInsets.only(top: 0, left: 0, right: 0),
          height: height,
          width: width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(
                  height,
                  width,
                ),
                SizedBox(
                  height: 40,
                ),
                _buildDescriptionCard(),
                // _buildBottomCard(snapshot.data!.data)
              ],
            ),
          )),
    );
  }

  Container _buildDescriptionCard() {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: ThemeClass.blackColor.withOpacity(0.20),
          blurRadius: 1.0, // soften the shadow
          spreadRadius: -6.0, //extend the shadow
          offset: const Offset(
            -1.0, // Move to right 10  horizontally
            8.0, // Move to bottom 10 Vertically
          ),
        )
      ]),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: ThemeClass.whiteColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.offer.description.toString(),
                style: TextStyle(fontWeight: FontWeight.w300)),
            SizedBox(
              height: 10,
            ),
            Text(
              "Read more",
              style: TextStyle(
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  color: ThemeClass.redColor,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Container _buildHeader(
    double height,
    double width,
  ) {
    return Container(
      height: height * 0.35,
      width: width,
      child: Stack(
        children: [
          CachedNetworkImage(
            height: height * 0.35,
            width: width,
            imageUrl: widget.offer.image.toString(),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                Center(child: Icon(Icons.error)),
          ),
          Container(
            decoration: BoxDecoration(
              // color: Colors.transparent,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.1, 0.5, 0.9],
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            // left: 20,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: width,
                child: Column(
                  children: [
                    Text(
                      "${widget.offer.title.toString()}",
                      style: TextStyle(
                          fontSize: 18,
                          color: ThemeClass.whiteColor,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Text(
                    //   widget.offer.description.toString(),
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     color: ThemeClass.whiteColor,
                    //     fontWeight: FontWeight.w300,
                    //     fontSize: 12,
                    //   ),
                    // ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: width,
                child: _builfTwobutton(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Transform _builfTwobutton() {
    return Transform.translate(
      offset: Offset(0, 36.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // padding: EdgeInsets.all(200),
            height: 70,
            width: 70,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fav_round_icon.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          InkWell(
            onTap: () {
              // Navigator.pushNamed(context, Routes.mapshortDetailsScreen);
            },
            child: Container(
              // padding: EdgeInsets.all(200),
              height: 70,
              width: 70,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/location_round_icon.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
