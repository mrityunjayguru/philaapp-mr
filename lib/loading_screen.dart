import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    _navigat();
    super.initState();
  }

  _navigat() async {
    // try {
    //   bool? isSplash = await SharedPrefService.getSplashData();
    //   if (isSplash == null) {
    //     Navigator.pushAndRemoveUntil<void>(
    //       context,
    //       MaterialPageRoute<void>(
    //           builder: (BuildContext context) => const SplashScreen()),
    //       ModalRoute.withName('/main'),
    //     );
    //   } else if (!isSplash) {
    //     // Navigator.pushAndRemoveUntil<void>(
    //     //   context,
    //     //   MaterialPageRoute<void>(
    //     //       builder: (BuildContext context) => const LoginScreen()),
    //     //   ModalRoute.withName('/main'),
    //     // );
    //   } else {
    //     Navigator.pushAndRemoveUntil<void>(
    //       context,
    //       MaterialPageRoute<void>(
    //           builder: (BuildContext context) => SplashScreen()),
    //       ModalRoute.withName('/main'),
    //     );
    //   }
    // } catch (e) {
    //   Navigator.pushAndRemoveUntil<void>(
    //     context,
    //     MaterialPageRoute<void>(
    //         builder: (BuildContext context) => SplashScreen()),
    //     ModalRoute.withName('/'),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    // ignore: sized_box_for_whitespace
    return Container(
      height: height,
      width: width,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
