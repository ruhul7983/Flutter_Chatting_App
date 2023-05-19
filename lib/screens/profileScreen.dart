

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/APIs/apis.dart';
import 'package:chatapp/auth/login_screen.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/modals/chat_users.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class profileScreen extends StatefulWidget {
  final ChatUser user;
  const profileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<profileScreen> createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile",style: TextStyle(color: Colors.black),),
        ),
        body: Form(
          key: _formkey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .3),
                              child: Image.file(
                                height: mq.height * 0.2,
                                width: mq.width * 0.4,
                                fit: BoxFit.cover,
                                File(_image!),
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .3),
                              child: CachedNetworkImage(
                                height: mq.height * 0.2,
                                width: mq.width * 0.4,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(child: Icon(Icons.person)),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showButtomSheet();
                          },
                          child: Icon(Icons.edit),
                          color: Colors.white,
                          shape: CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: mq.width,height: mq.height*0.03,),
                  Text(widget.user.email,style: TextStyle(color: Colors.black54,fontSize: 20),),
                  SizedBox(width: mq.width,height: mq.height*0.05,),
                  TextFormField(
                    onSaved: (val)=>APIs.me.name = val ??'',
                    validator: (val)=> val!=null && val.isNotEmpty?null:'Required Field',
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person,color: Colors.blue ,),
                        hintText: 'eg. Ruhul',
                        label: Text("Name"),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  SizedBox(width: mq.width,height: mq.height*0.05,),
                  TextFormField(
                    onSaved: (val)=>APIs.me.about = val ??'',
                    validator: (val)=> val!=null && val.isNotEmpty?null:'Required Field',
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.info,color: Colors.blue ,),
                        hintText: 'Details',
                        label: Text("About"),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  SizedBox(width: mq.width,height: mq.height*0.03,),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      shape: StadiumBorder(),
                      padding: EdgeInsets.only(left: 20,right: 20),
                    ),
                    onPressed: (){
                      if(_formkey.currentState!.validate()){
                        _formkey.currentState!.save();
                        APIs.updateUser().then((value) => dialogs.showSnackbar(context, 'Updated Successfully'));
                      }
                    }, icon: Icon(Icons.edit),label: Text("Update"),)
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              onPressed: () async {
                dialogs.showProgressBar(context);
                await APIs.auth
                    .signOut()
                    .then((value) async =>
                await GoogleSignIn().signOut().then((value){
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>loginScreen()));
                }
                ));
              },
              icon: Icon(Icons.logout),
              label: Text("Logout")),
        ),
      ),
    );
  }

  void _showButtomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: mq.height * 0.03,bottom: mq.height*0.05),
            children: [
              Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: Size(mq.width * 0.3, mq.height * 0.08),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image =
                      await picker.pickImage(source: ImageSource.camera,imageQuality: 80);
                      if(image!=null){
                        setState(() {
                          _image=image.path;
                        });
                        APIs.updateProfilePicture(File(_image!));
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset("images/camera.png"),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: Size(mq.width * 0.3, mq.height * 0.08),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery,imageQuality: 80);
                      if(image!=null){
                        setState(() {
                          _image=image.path;
                        });
                        APIs.updateProfilePicture(File(_image!));
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset("images/gallery.png"),
                  ),
                ],
              ),
            ],
          );
        });
  }
}
