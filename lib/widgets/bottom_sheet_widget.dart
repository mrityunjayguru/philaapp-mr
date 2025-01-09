import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/model/places_list_model.dart';

import 'package:city_sightseeing/pages/map/attraction_details_screen.dart';

import 'package:city_sightseeing/widgets/general_widget.dart';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_2/persistent_tab_view.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomSheetforMapDetails extends StatefulWidget {
  BottomSheetforMapDetails({Key? key, required this.routesData})
      : super(key: key);
  final PlacesListData routesData;
  @override
  State<BottomSheetforMapDetails> createState() =>
      _BottomSheetforMapDetailsState();
}

class _BottomSheetforMapDetailsState extends State<BottomSheetforMapDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildCard(), _builfTwobutton()],
      ),
    );
  }

  Card _buildCard() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              height: 149,
              width: 149,
              imageUrl: '${widget.routesData.image.toString()}',
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
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.routesData.title.toString(),
                    // maxLines: 2,
                    // overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  Text(widget.routesData.description.toString(),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      )),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Transform _builfTwobutton() {
    return Transform.translate(
      offset: Offset(0, -30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              // Navigator.pushNamed(context, Routes.mapLongDetailsScreen)
              // ;

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: AttractionDetailScreen(
                    placeid: widget.routesData.id.toString()),
                withNavBar: false,
                // withNavBar: true, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            child: Container(
              // padding: EdgeInsets.all(200),
              height: 61,
              width: 61,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/details_rounded_red.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              // Navigator.pushNamed(context, Routes.mapFullScreen);
              _openGoogleMap(
                  widget.routesData.latitude.toString(),
                  widget.routesData.longitude.toString(),
                  widget.routesData.title.toString(),
                  widget.routesData.googleBusinessUrl.toString());
            },
            child: Container(
              // padding: EdgeInsets.all(200),
              height: 61,
              width: 61,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/location_red_rounded.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _openGoogleMap(
      String latitude, String longitude, String title, String googleUrl) async {
    // String googleUrl =
    //     'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      showSnackbarMessageGlobal("Could not open google map.", context);
    }
  }
}
