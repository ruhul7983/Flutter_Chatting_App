import 'package:chatapp/APIs/apis.dart';
import 'package:chatapp/auth/login_screen.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({Key? key}) : super(key: key);

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));
      if(APIs.auth.currentUser != null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>homescreen()));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>loginScreen()));
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .15,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset(
                "images/icon.png",
                color: Colors.blue,
              )),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: Text(
                "Made for Privacy ❤️",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              )),
        ],
      ),
    );
  }
}
