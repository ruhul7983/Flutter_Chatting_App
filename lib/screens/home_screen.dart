import 'package:chatapp/APIs/apis.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:chatapp/modals/chat_users.dart';
import 'package:chatapp/screens/profileScreen.dart';
import 'package:chatapp/widgets/chat_user_cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class homescreen extends StatefulWidget {
  const homescreen({Key? key}) : super(key: key);

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  List<ChatUser> list = [];
  final List<ChatUser> _search = [];
  bool _isSearching = false;


  @override
  void initState() {
    APIs.userSelfData();
    APIs.updateActiveStatus(true);
    super.initState();
    SystemChannels.lifecycle.setMessageHandler((message){
      if(message.toString().contains('resume')) APIs.updateActiveStatus(true);
      if(message.toString().contains('pause')) APIs.updateActiveStatus(false);
      return  Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(_isSearching){
            setState(() {
              _isSearching=!_isSearching;
            });
            return Future.value(false);

          }else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          //appBar here
          appBar: AppBar(
            leading: Icon(Icons.home),
            title: _isSearching?TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Name, Email...",
              ),
              autofocus: true,
              style: TextStyle(fontSize: 17,letterSpacing: 1),
              onChanged: (val){
                //search logic
                _search.clear();
                      for (var i in list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _search.add(i);
                        }
                        setState(() {
                          _search;
                        });
                      }
                    },
            ):Text("SnapSpeak",style: TextStyle(color: Colors.black),),
            actions: [
              //search Icon and three dots
              IconButton(onPressed: (){
                setState(() {
                  _isSearching=!_isSearching;
                });
              }, icon: Icon(_isSearching?CupertinoIcons.clear_circled:Icons.search)),
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>profileScreen(user: APIs.me,)));
              }, icon: Icon(Icons.more_vert)),
            ],
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder:(context,snapshot){
              switch(snapshot.connectionState){
                case ConnectionState.none:
                case ConnectionState.waiting:
                  //return Center(child: CircularProgressIndicator(),);
                case ConnectionState.active:
                case ConnectionState.done:
               return StreamBuilder(
                 stream: APIs.getAllUsers( snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                 builder: (context, snapshot){
                   switch(snapshot.connectionState){
                     case ConnectionState.none:
                     case ConnectionState.waiting:
                       //return Center(child: CircularProgressIndicator(),);
                     case ConnectionState.active:
                     case ConnectionState.done:

                       final data = snapshot.data?.docs;
                       list = data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];
                       if(list.isNotEmpty){
                         return ListView.builder(
                             physics: BouncingScrollPhysics(),
                             itemCount: _isSearching?_search.length: list.length,
                             itemBuilder: (context,index){
                               return chatUserCart(user: _isSearching?_search[index]: list[index],);
                               //return chatUserCart(user: APIs.me,);
                             });
                       }else{
                         return Center(child: Text("No User Found"),);
                       }
                   }


                 },
               );
             }
            },

          ),

          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(onPressed: (){
              _addUser();
            },child: Icon(Icons.message),),
          ),
        ),
      ),
    );
  }

  void _addUser() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(
              left: 24, right: 24, top: 20, bottom: 10),

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),

          //title
          title: Row(
            children: const [
              Icon(
                Icons.person_add,
                color: Colors.blue,
                size: 28,
              ),
              Text('  Add user')
            ],
          ),

          //content
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
              hintText: 'Email id',
                prefixIcon: Icon(Icons.email,color: Colors.blue,),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),

          //actions
          actions: [
            //cancel button
            MaterialButton(
                onPressed: () {
                  //hide alert dialog
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                )),

            //update button
            MaterialButton(
                onPressed: () async {
                  //hide alert dialog
                  Navigator.pop(context);
                  if(email.isNotEmpty){
                   await APIs.addChatUser(email).then((value) {
                      if(!value){
                        dialogs.showSnackbar(context,'User not exits');
                      }
                    });
                  };
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ))
          ],
        ));
  }

}
