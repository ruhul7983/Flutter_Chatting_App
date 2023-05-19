import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/APIs/apis.dart';
import 'package:chatapp/helper/my_data_util.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/modals/chat_users.dart';
import 'package:chatapp/modals/message.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class chatUserCart extends StatefulWidget {
  final ChatUser user;
  const chatUserCart({Key? key, required this.user}) : super(key: key);


  @override
  State<chatUserCart> createState() => _chatUserCartState();
}

class _chatUserCartState extends State<chatUserCart> {
  @override
  Widget build(BuildContext context) {
    Message? _message;


    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: mq.width *0.04,vertical: mq.width *0.01),
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_)=>ChatScreen(user: widget.user,)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessages(widget.user),
          builder: (context,snapshot){
            final data  = snapshot.data?.docs;
            final list = data?.map((e) => Message.fromJson(e.data())).toList()??[];
            if (list.isNotEmpty) _message = list[0];
            return ListTile(
              title: Text(widget.user.name),
                subtitle: Text(
                  _message != null ? _message!.type==Type.image?'Sent a photo': _message!.msg : widget.user.about,
                  maxLines: 1,
                ),
                //leading: CircleAvatar(child: Icon(Icons.person)),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  height: mq.height * 0.11,
                  width: mq.width * 0.11,
                  imageUrl: widget.user.image,
                  errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.person)),
                ),
              ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.auth.currentUser!.uid
                        ? Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade400,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          )
                        : Text(
                            MyDataUtil.getLastMessageTime(context: context, time: _message!.sent)
                          ),
              );
          },

        )
      ),
    );
  }
}
