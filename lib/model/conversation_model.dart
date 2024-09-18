import 'package:objectbox/objectbox.dart';
import 'package:msix/msix.dart';
//import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

@Entity()
class ConversationModel{
  @Id()
  int id;

  String conversationId;
  String text;
  bool sendByAi;
  bool sendByUser;

  @Property(type: PropertyType.date) // Timestamp for ordering
  DateTime timestamp;

  ConversationModel({
    this.id=0,
    required this.conversationId,
    required this.text,
    required this.sendByAi,
    required this.sendByUser,
    required this.timestamp,
  });

}