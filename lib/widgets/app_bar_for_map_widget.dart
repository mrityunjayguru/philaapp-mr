import 'package:city_sightseeing/pages/attractions_screen.dart';
import 'package:city_sightseeing/screen/main_screen.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_2/persistent_tab_view.dart';

class AppBarForMap extends StatelessWidget {
  const AppBarForMap(
      {Key? key,
      this.title = "",
      this.onSortingPress,
      this.showattraction = true,
      this.showSorting = false})
      : super(key: key);
  final String title;
  final bool showattraction;
  final bool showSorting;
  final Function? onSortingPress;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ThemeClass.redColor,
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new)),
      centerTitle: false,
      title: Text(title, style: TextStyle(color: Colors.white),),
      iconTheme: const IconThemeData(
          color: Colors.white, size: 30 // This isn't performing any changes
          ),
      actions: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            showSorting
                ? InkWell(
                    onTap: () {
                      onSortingPress!();
                    },
                    child: Container(
                      // padding: EdgeInsets.all(200),
                      height: 25,
                      width: 24,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/sorting_icon.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
            SizedBox(
              width: 15,
            ),
            showattraction
                ? InkWell(
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: AttrectionScreen(curIndex: 1),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Container(
                      // padding: EdgeInsets.all(200),
                      height: 25,
                      width: 26,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/images/lankmark_icon.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil<void>(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => MainScreen()),
                  ModalRoute.withName('/main'),
                );
                // Navigator.pushReplacement(context, Routes.mainRoute)
              },
              child: Container(
                // padding: EdgeInsets.all(10),
                height: 25,
                width: 26,
                child: Container(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/home_icon.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
          ],
        )
      ],
    );
  }
}
