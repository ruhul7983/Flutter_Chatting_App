
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/APIs/apis.dart';
import 'package:chatapp/helper/my_data_util.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/modals/chat_users.dart';
import 'package:chatapp/modals/message.dart';
import 'package:chatapp/widgets/message_cart.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];

  bool _showEmoji = false, _isUploading = false;
  final _textcontroller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: ()=>FocusScope.of(context).unfocus(),
        child: WillPopScope(
          onWillPop: (){
            if(_showEmoji){
              setState(() {
                _showEmoji=!_showEmoji;
              });
              return Future.value(false);

            }else{
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.blue.shade50,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appbar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        return SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data?.map((e) => Message.fromJson(e.data())).toList()??[];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                physics: BouncingScrollPhysics(),
                                itemCount: _list.length,
                                itemBuilder: (context, index) {
                                // if(index == _list.length){return Container(height: mq.height*0.02,);}
                                  //return chatUserCart(user: _isSearching?_search[index]: list[index],);
                                  return messageCart(message: _list[index]);
                                });
                          } else {
                            return Center(
                              child: Text("Say, Hi!"),
                            );
                          }
                      }
                    },
                  ),
                ),
                if(_isUploading)
                Align(
                  alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18,bottom: 15),
                      child: CircularProgressIndicator(strokeWidth: 2,),
                    )),
                _chatinput(),

                if(_showEmoji)
                SizedBox(
                  height: mq.height * 0.35,
                  child: EmojiPicker(
                    textEditingController: _textcontroller,
                    config: Config(
                      columns: 7,
                      initCategory: Category.SMILEYS,
                      bgColor: Colors.blue.shade50,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appbar() {
    return InkWell(
      onTap: () {},
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot){
          final data  = snapshot.data?.docs;
          final list = data?.map((e)=>ChatUser.fromJson(e.data())).toList()??[];
          return Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back)),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  height: mq.height * 0.11,
                  width: mq.width * 0.11,
                  imageUrl: list.isNotEmpty?list[0].image: widget.user.image,
                  errorWidget: (context, url, error) =>
                      CircleAvatar(child: Icon(Icons.person)),
                ),
              ),
              SizedBox(
                width: mq.width * 0.05,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    list.isNotEmpty ?
                    list[0].isOnline?'Online':
                    MyDataUtil.getLastActiveTime(context: context, lastActive: list[0].lastactive)
                        :MyDataUtil.getLastActiveTime(context: context, lastActive: widget.user.lastactive),
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chatinput() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji =! _showEmoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.blueAccent,
                      )),
                  //Textform
                  Expanded(
                      child: TextField(
                        onTap: (){
                          if(_showEmoji)
                          setState(() {
                              _showEmoji =! _showEmoji;
                          });
                        },
                        controller: _textcontroller,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      border: InputBorder.none,
                    ),
                  )),
                  IconButton(
                      onPressed: () async {

                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final List<XFile>? images =
                            await picker.pickMultiImage(imageQuality: 80);
                        for(var i in images!){
                          setState(() {
                            _isUploading = true;
                          });
                          await APIs.sendChatImage(widget.user,File(i.path!));
                          setState(() {
                            _isUploading = false;
                          });
                        }

                      },
                      icon: Icon(
                        Icons.photo_size_select_actual_outlined,
                        color: Colors.blueAccent,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera,imageQuality: 80);
                        if(image!=null){
                          setState(() {
                            _isUploading = true;
                          });
                         await APIs.sendChatImage(widget.user,File(image.path!));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.blueAccent,
                      )),
                ],
              ),
            ),
          ),
          MaterialButton(
            shape: CircleBorder(),
            color: Colors.greenAccent,
            padding: EdgeInsets.all(10),
            onPressed: () {
              if(_textcontroller.text.isNotEmpty){
                if(_list.isEmpty){
                  APIs.sendMessage(
                      widget.user, _textcontroller.text, Type.text);
                }else {
                  APIs.sendMessage(
                      widget.user, _textcontroller.text, Type.text);
                }
                  _textcontroller.text = '';
              }
            },
            minWidth: 0,
            child: Icon(
              Icons.send,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }
}
