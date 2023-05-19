class ChatUser {
  ChatUser({
    required this.image,
    required this.about,
    required this.id,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.email,
    required this.pushToken,
    required this.lastactive,
  });
  late String image;
  late String about;
  late String id;
  late String name;
  late String createdAt;
  late bool isOnline;
  late String email;
  late String pushToken;
  late String lastactive;

  ChatUser.fromJson(Map<String, dynamic> json){
    image = json['image']??'';
    about = json['about']??'';
    id = json['id']??'';
    name = json['name']??'';
    createdAt = json['created_at']??'';
    isOnline = json["is_online"];
    email = json['email']??'';
    pushToken = json['push_token']??'';
    lastactive = json['last_active']??'';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['image'] = image;
    _data['about'] = about;
    _data['id'] = id;
    _data['name'] = name;
    _data['created_at'] = createdAt;
    _data['is_online'] = isOnline;
    _data['email'] = email;
    _data['push_token'] = pushToken;
    _data['last_active'] = lastactive;
    return _data;
  }
}