import 'dart:io';

import 'package:chatapp/modals/chat_users.dart';
import 'package:chatapp/modals/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  //for me
  static late ChatUser me;

  static FirebaseAuth auth = FirebaseAuth.instance;

  //for firestore
  static FirebaseFirestore Firestore = FirebaseFirestore.instance;

  //for storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for checking is user exist or not
  static Future userExist() async {
    return (await Firestore.collection("users")
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  //for self data store
  static Future userSelfData() async {
    await Firestore.collection("users")
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => {userSelfData()});
      }
    });
  }

  //for creating a new user
  static Future createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      image: auth.currentUser!.photoURL.toString(),
      about: "Hey, I am using snapspeak",
      id: auth.currentUser!.uid,
      name: auth.currentUser!.displayName.toString(),
      createdAt: time,
      isOnline: false,
      email: auth.currentUser!.email.toString(),
      pushToken: '',
      lastactive: time,
    );
    return await Firestore.collection("users")
        .doc(auth.currentUser!.uid)
        .set(chatUser.toJson());
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {

    return Firestore
        .collection('users')
        .where('id',
        whereIn: userIds.isEmpty
            ? ['']
            : userIds) //because empty list throws an error
    // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for update user
  //for checking is user exist or not
  static Future updateUser() async {
    await Firestore.collection("users").doc(auth.currentUser!.uid).update({
      "name": me.name,
      "about": me.about,
    });
  }

  //for update profile picture
  static Future updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref =
        storage.ref().child('profile_pictures/${auth.currentUser?.uid}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));

    me.image = await ref.getDownloadURL();
    await Firestore.collection("users")
        .doc(auth.currentUser!.uid)
        .update({"image": me.image});
  }

  //get messaging uid
  static String getConversationID(String id) =>
      auth.currentUser!.uid.hashCode <= id.hashCode
          ? '${auth.currentUser!.uid}_$id'
          : '${id}_${auth.currentUser!.uid}';

  //for handling all messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return Firestore.collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .snapshots();
  }

  static Future sendMessage(ChatUser user, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        toId: user.id,
        fromId: auth.currentUser!.uid,
        msg: msg,
        read: '',
        sent: time,
        type: type);
    final ref = Firestore
        .collection('chats/${getConversationID(user.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  //update user message read or not

  static Future updateMessageReadSatus(Message message)async{
    Firestore.collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }
  //get last message

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return Firestore.collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .limit(1).snapshots();
  }

  //send image from camera
  static Future sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref =
    storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));

    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

//adding my user only
  static Future<bool> addChatUser(String email) async {
    final data = await Firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();


    if (data.docs.isNotEmpty && data.docs.first.id != auth.currentUser!.uid) {
      //user exists


      Firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }
  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return Firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('my_users')
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await Firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(auth.currentUser!.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return Firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }
  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    Firestore.collection('users').doc(auth.currentUser!.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

}
