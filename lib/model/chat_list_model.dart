import 'package:objectbox/objectbox.dart';
//import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

@Entity()
class ChatListModel{
  @Id()
  int id=0;

  String conversationId;
  DateTime addedAt;

  ChatListModel({
    required this.conversationId,
    required this.addedAt,
  });
}