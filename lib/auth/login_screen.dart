import 'dart:io';

import 'package:chatapp/APIs/apis.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class loginScreen extends StatefulWidget {
  const loginScreen({Key? key}) : super(key: key);

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  bool _isAnimated = false;

  _handleGoogleSignin() {
      dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if(user!=null){
        if((await APIs.userExist())){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>homescreen()));
        }else{
          await APIs.createUser().then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>homescreen())));
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
      try{
        await InternetAddress.lookup("google.com");
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        // Once signed in, return the UserCredential
        return await APIs.auth.signInWithCredential(credential);
      }catch(e){
        dialogs.showSnackbar(context, "Something wents wrong");
        return null;
      }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(microseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      //appBar here
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Welcome to SnapSpeak",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * .15,
              right: _isAnimated ? mq.width * .25 : -mq.width * .5,
              width: mq.width * .5,
              duration: Duration(seconds: 1),
              child: Image.asset(
                "images/icon.png",
                color: Colors.blue,
              )),
          Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .06,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: StadiumBorder(),
                  ),
                  onPressed: () {
                    _handleGoogleSignin();
                  },
                  icon: Image.asset(
                    "images/google.png",
                    height: mq.height * 0.03,
                  ),
                  label: Text(
                    "Sign in with Google",
                    style: TextStyle(fontSize: 19),
                  ))),
        ],
      ),
    );
  }
}
