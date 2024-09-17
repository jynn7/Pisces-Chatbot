import 'model/chat_list_model.dart';
import 'model/conversation_model.dart';
import 'package:path_provider/path_provider.dart';
import 'objectbox.g.dart';
import 'package:path/path.dart' as p;

class ObjectBox{
  late final Store store;
  late final Box<ConversationModel> conversationModelBox;
  late final Box<ChatListModel>chatListBox;

  ObjectBox._create(this.store){
    conversationModelBox=Box<ConversationModel>(store);
    chatListBox=Box<ChatListModel>(store);
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: p.join(docsDir.path, "pisces_db"));
    return ObjectBox._create(store);
  }
}