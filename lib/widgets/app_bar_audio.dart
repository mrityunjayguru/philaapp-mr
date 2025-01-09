import 'package:city_sightseeing/themedata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screen/main_screen.dart';
import '../service/provider/play_audio_service.dart';

class AppBarAudio extends StatelessWidget {
  const AppBarAudio({
    Key? key,
    this.onLanguagePress,
    this.onHomePress,
    this.action,
  }) : super(key: key);

  final Function? onLanguagePress;
  final Function? onHomePress;
  final Widget? action;


  @override
  Widget build(BuildContext context) {
    return AppBar(
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
      actions: [
        if (action != null) action!,
        Row(
          children: [
            if (onLanguagePress != null)
              OutlinedButton(
                onPressed: () {
                  onLanguagePress?.call();
                },
                style: OutlinedButton.styleFrom(
                  fixedSize: Size(100, 20),
                  side: BorderSide(color: ThemeClass.whiteColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 4, vertical: 0),
                ),
                child: Text(
                  "Change language",
                  style: TextStyle(
                    color: ThemeClass.whiteColor,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Lato',
                    fontSize: 11,
                  ),
                ),
              ),
          /*    IconButton(
                  onPressed: () {
                    onLanguagePress?.call();
                  },
                  icon: Image.asset(
                    "assets/images/lang_switch_img.png",
                    height: 25,
                    width: 26,
                  )),*/
            IconButton(
                padding: EdgeInsets.symmetric(horizontal: 20),
                onPressed: () {
                  Provider.of<PlayAudioService>(context, listen: false)
                      .releasePlayer("", context);
                  Navigator.pushAndRemoveUntil<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => MainScreen()),
                    ModalRoute.withName('/main'),
                  );
                },
                icon: Image.asset(
                  "assets/images/home_nav_icon.png",
                  height: 25,
                  width: 26,
                )),
          ],
        )
      ],
    );
  }
}
