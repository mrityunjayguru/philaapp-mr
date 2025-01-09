import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/generated/assets.dart';
import 'package:city_sightseeing/model/audio_view_model.dart';
import 'package:city_sightseeing/pages/audio/play_audio_screen.dart';
import 'package:city_sightseeing/strings.dart';
import 'package:flutter/material.dart';

class MapAudioItem extends StatelessWidget {
  final AudioViewModel audioData;
  final String? pageId;

  MapAudioItem({Key? key, required this.audioData, this.pageId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => PlayAudioScreen(pageId: pageId,),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 3, 15, 3),
        width: MediaQuery.of(context).size.width,
        // width: double.infinity,
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(75),
              child: CachedNetworkImage(
                width: 75,
                height: 75,
                imageUrl: "${ConstantStrings.base}${audioData.image}",
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
                errorWidget: (context, url, error) => Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    color: Color(0xFF220220),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nearest Trigger Point",
                    style: TextStyle(
                      color: Color(0xFFCD001C),
                      fontSize: 13,
                      fontFamily: 'lato',
                    ),
                  ),
                  Text(
                    "${audioData.title}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'lato',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 35,
              alignment: Alignment.center,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    Assets.imagesIcMapAudioListen,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
