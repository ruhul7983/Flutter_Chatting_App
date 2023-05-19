import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/APIs/apis.dart';
import 'package:chatapp/helper/my_data_util.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/modals/message.dart';
import 'package:flutter/material.dart';

class messageCart extends StatefulWidget {
  final Message message;
  const messageCart({Key? key, required this.message}) : super(key: key);

  @override
  State<messageCart> createState() => _messageCartState();
}

class _messageCartState extends State<messageCart> {
  @override
  Widget build(BuildContext context) {
    return APIs.auth.currentUser!.uid == widget.message.fromId?_greenMessage():_blueMessage();
  }
  //sender message
  Widget _blueMessage(){
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadSatus(widget.message);
    }

    return Row(
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * 0.05),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              border: Border.all(color: Colors.lightBlue),
            ),
            child: widget.message.type == Type.text ? Text(widget.message.msg,
              style: TextStyle(fontSize: 18, color: Colors.black87),)
                : ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: CachedNetworkImage(
                height: mq.height * 0.11,
                width: mq.width * 0.11,
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) =>
                    CircleAvatar(child: Icon(Icons.image)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            MyDataUtil.getFormattedTime(context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
  //my message
  Widget _greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if(widget.message.read.isNotEmpty)
          Icon(Icons.done_all,color: Colors.lightBlue,),
        SizedBox(width: mq.width *0.01,),
        Text(
          MyDataUtil.getFormattedTime(context: context, time: widget.message.sent),
          style: TextStyle(fontSize: 13),
        ),
        //msg showing
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * 0.05),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              border: Border.all(color: Colors.lightGreen),
            ),
            child: widget.message.type == Type.text ? Text(widget.message.msg,
              style: TextStyle(fontSize: 18, color: Colors.black87),)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          CircleAvatar(child: Icon(Icons.image)),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
