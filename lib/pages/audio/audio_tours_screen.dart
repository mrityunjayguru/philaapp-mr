
import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_sightseeing/generated/assets.dart';
import 'package:city_sightseeing/screen/wrapper/audio_coming_soon_screen.dart';
import 'package:city_sightseeing/service/provider/tour_list_service.dart';
import 'package:city_sightseeing/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/tour_list/TourData.dart';
import '../../themedata.dart';

class AudioTourScreen extends StatefulWidget {
  bool? downloadedAudio;

  AudioTourScreen({this.downloadedAudio});

  @override
  State<AudioTourScreen> createState() => _AudioTourScreenState();
}

class _AudioTourScreenState extends State<AudioTourScreen> {
  ValueNotifier<bool> isAudioDownloaded = ValueNotifier(false);
  ValueNotifier<String> language = ValueNotifier("English");

  String img = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TourListService>(context, listen : false).getTourData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isError = Provider.of<TourListService>(context).isError;
    bool loader = Provider.of<TourListService>(context).isLoading;
    List<TourData> data = Provider.of<TourListService>(context).tourData;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: ThemeClass.redColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: ThemeClass.whiteColor,
            ),
          ),
          title: Text(
            'Audio',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Stack(children: [
          SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: !isError
                  ? ListView.separated(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemBuilder: (BuildContext context, int index) => InkWell(
                        onTap: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AudioComingSoonScreen(pageId: data[index].id.toString(), codeDependency: data[index].isCodeDependency ?? false,code: data[index].code,),
                              ),
                            );

                        },
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              height: 212,
                              imageUrl:
                                  '${ConstantStrings.base}${data[index].image}',
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Image.asset(
                                Assets.imagesDummyImage,
                                width: double.infinity,
                                height: 212,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              left: 16,
                              bottom: 25,
                              child: Text(
                                data[index].title ?? ConstantStrings.hopOnOff,
                                style: TextStyle(
                                    color: ThemeClass.whiteColor,
                                    fontFamily: 'Lato',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(
                        height: 12,
                      ),
                      itemCount: data.length,
                    )
                  : Text("Error! No Tours Available"),
            ),
          ),
          if (loader == true)
            Positioned.fill(
              child: Container(
                color: Colors.black54.withOpacity(0.3),
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              ),
            ),
        ]));
  }

}
