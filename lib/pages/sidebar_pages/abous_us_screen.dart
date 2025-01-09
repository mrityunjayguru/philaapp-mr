import 'package:city_sightseeing/service/provider/initial_data_service.dart';

import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AboutUsScreen extends StatefulWidget {
  AboutUsScreen({Key? key}) : super(key: key);

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBarForMap(title: "About us"),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 0, left: 20, right: 25),
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
              ),
              Consumer<InitialDataService>(
                  builder: (context, initialService, child) {
                return Text(
                  initialService.globalCmsData!.about.toString(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
