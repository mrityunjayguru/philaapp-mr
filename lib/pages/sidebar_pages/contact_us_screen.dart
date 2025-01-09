import 'package:city_sightseeing/service/provider/initial_data_service.dart';
import 'package:city_sightseeing/themedata.dart';

import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  ContactUsScreen({Key? key}) : super(key: key);

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  void _launchURL(String _url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBarForMap(title: "Contact us"),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 0, left: 20, right: 25),
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              GestureDetector(
                onTap: () {
                  _launchURL("tel://(215) 922-2300");
                },
                child: CircleAvatar(
                  backgroundColor: ThemeClass.redColor,
                  radius: 40,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Image.asset(
                      "assets/images/call_icon.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  _launchURL("tel://(215) 922-2300");
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Call: ",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "(215) 922-2300",
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 25,
                          color: ThemeClass.redColor),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 100,
              ),
              GestureDetector(
                onTap: () {
                  var url =
                      Provider.of<InitialDataService>(context, listen: false)
                          .globalCmsData!
                          .chatUrl;

                  _launchURL(url.toString());
                },
                child: CircleAvatar(
                  backgroundColor: ThemeClass.redColor,
                  radius: 40,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Image.asset(
                      "assets/images/chat_icon2.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Chat",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
