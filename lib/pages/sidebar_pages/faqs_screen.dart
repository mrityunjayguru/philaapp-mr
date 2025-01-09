import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:city_sightseeing/model/faqs_model.dart';
import 'package:city_sightseeing/service/http_service.dart';
import 'package:city_sightseeing/themedata.dart';
import 'package:city_sightseeing/widgets/app_bar_for_map_widget.dart';

import 'package:flutter/material.dart';

class FAQsSCreen extends StatefulWidget {
  FAQsSCreen({Key? key}) : super(key: key);

  @override
  _FAQsSCreenState createState() => _FAQsSCreenState();
}

class _FAQsSCreenState extends State<FAQsSCreen> {
  Future<FaQsModel> getfaqdata() async {
    try {
      var response = await HttpService.httpGetWithoutToken("faqs");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        FaQsModel places = FaQsModel.fromJson(body);

        return places;

        // return coupon;
      } else {
        throw "internal server error";
      }
    } catch (e) {
      if (e is SocketException) {
        debugPrint("socket exception screen :------ $e");

        throw "Socket exception";
      } else if (e is TimeoutException) {
        debugPrint("time out exp :------ $e");

        throw "Time out exception";
      } else {
        debugPrint("home screen :------ $e");

        throw e.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBarForMap(title: "FAQs"),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 0, left: 20, right: 25),
        height: height,
        width: width,
        child: SingleChildScrollView(
            child: FutureBuilder(
                future: getfaqdata(),
                builder: (context, AsyncSnapshot<FaQsModel> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        if (snapshot.data!.data != null &&
                            snapshot.data!.data!.isNotEmpty) {
                          return ListView.builder(
                            padding: EdgeInsets.only(bottom: 40),
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: snapshot.data!.data!.length,
                            itemBuilder: (context, index) {
                              var placescart = snapshot.data!.data![index];
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    placescart.title.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: ThemeClass.redColor,
                                        fontSize: 20),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  ...placescart.list!
                                      .map((listItem) => _buildContainer(
                                          listItem.question.toString(),
                                          listItem.description.toString()))
                                      .toList(),
                                ],
                              );
                            },
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 100),
                            child: _buildDataNotFound("Data Not Found!"),
                          );
                        }
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: _buildDataNotFound("Data Not Found!"),
                        );
                      }
                    } else if (snapshot.hasError) {
                      // return Center(child: Text(snapshot.error.toString()));
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: _buildDataNotFound(snapshot.error.toString()),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: _buildDataNotFound("Data Not Found!"),
                      );
                    }
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 300),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // return Text("data");
                })),
      ),
    );
  }

  Center _buildDataNotFound(String text) {
    return Center(child: Text("$text"));
  }

  Column _buildContainer(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ThemeClass.blackColor.withOpacity(0.75),
              fontSize: 16),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          subtitle,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: ThemeClass.blackColor.withOpacity(0.75),
              fontSize: 14),
        ),
        Divider(
          color: ThemeClass.greyColor.withOpacity(0.7),
          height: 30,
        )
      ],
    );
  }
}
