import 'package:city_sightseeing/pages/audio/download_language_screen.dart';
import 'package:city_sightseeing/service/provider/initial_data_service.dart';
import 'package:city_sightseeing/widgets/app_bar_audio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums.dart';
import '../../model/language_list_model.dart';
import '../../screen/main_screen.dart';
import '../../service/provider/play_audio_service.dart';
import '../../service/shared_pred_service.dart';
import '../../themedata.dart';

class LanguageSelectScreen extends StatefulWidget {

  VoidCallback? callback;
  String? fromPage;
  final String? pageId;
  LanguageSelectScreen({Key? key,  this.callback, this.fromPage, this.pageId}) : super(key: key);

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
   List<LanguageModel> languageList=[];
  // final Map<String, String> languageMap = {
  //   'English': 'US',
  //   'Deutsch': 'German',
  //   'Español': 'Spanish',
  //   'Francesa': 'French',
  //   '中国人': 'Japanese',
  //   '한국인': 'Korean',
  //   'Italian': 'Italian',
  //   'हिंदी': 'Hindi',
  //   'Русский': 'Russian',
  //   '日本語': 'Chinese',
  //   'Português': 'Portuguese',
  //   'Tiếng Việt': 'Vietnamese',
  // };
  late double widthScreen;
  late double heightScreen;
  String selectedLanguage ="English";
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      Provider.of<InitialDataService>(context, listen: false).getLanguageData(pageId: widget.pageId);
      Provider.of<InitialDataService>(context, listen: false).getSelectedLanguage();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    languageList= Provider.of<InitialDataService>(context).languagesList.where((data)=>data.status.toString()=="active").toList();
    selectedLanguage= Provider.of<InitialDataService>(context).selectedlanguage;
    widthScreen = MediaQuery.of(context).size.width;
    heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60), child: AppBarAudio()),
      body: Padding(
        padding: const EdgeInsets.all(42),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose Audio Language",
              style: TextStyle(
                  color: ThemeClass.redColor,
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.w900),
            ),
            Container(
              height: 1,
              color: ThemeClass.redColor,
              padding: EdgeInsets.only(top: 10, bottom: 20),
            ),
            SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: languageListView())
            )],
        ),
      ),
    );
  }

  Widget languageListView() {
    return ListView.builder(
      itemCount: languageList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        String languageName = languageList[index].languages;
        String languageCode = languageList[index].tag;
        return Column(
          children: [
            InkWell(
              onTap: () async {
                 var currLanguage= await SharedPrefService().getLanguage();
                 if(currLanguage.toString() == languageName.toString()){
                    if(widget.fromPage!=null && widget.fromPage=="home"){
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            DownloadLanguageScreen(pageId: widget.pageId,),
                      ));
                      return ;
                    }
                   Navigator.of(context).pop();
                   return ;
                 }
                 await SharedPrefService().setLanguageState(LanguageState.noLangSelected);
                 await SharedPrefService().setLanguage(languageCode);
                 await SharedPrefService().setLanguageName(languageName);
                 Provider.of<PlayAudioService>(context, listen: false)
                     .releasePlayer("", context);
                 Navigator.pushAndRemoveUntil<void>(
                   context,
                   MaterialPageRoute<void>(
                       builder: (BuildContext context) =>
                           MainScreen()),
                   ModalRoute.withName('/main'),
                 );
                 Navigator.of(context).push(MaterialPageRoute<void>(
                   builder: (BuildContext context) =>
                       LanguageSelectScreen(fromPage:"home",pageId: widget.pageId,),
                 ));
                 Navigator.of(context).push(MaterialPageRoute<void>(
                   builder: (BuildContext context) =>
                       DownloadLanguageScreen(pageId: widget.pageId,),
                 ));
              },
              child: Container(
                width: widthScreen,
                height: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      languageCode,
                      style: TextStyle(
                          color: selectedLanguage == languageCode ? ThemeClass.redColor : ThemeClass.blackColor,
                          fontFamily: 'Lato',
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      languageName,
                      style: TextStyle(
                          color:  selectedLanguage == languageCode ? ThemeClass.redColor : ThemeClass.greyColor,
                          fontFamily: 'Lato',
                          fontSize: 18,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: ThemeClass.lightgreyColor,
              height: 1,
              width: widthScreen,
            )
          ],
        );
      },
    );
  }
}
