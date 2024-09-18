import 'package:chatbot_gemini_official/model/chat_list_model.dart';
import 'package:chatbot_gemini_official/objectbox.g.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../main.dart';
import '../model/conversation_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:objectbox/objectbox.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:msix/msix.dart';

class ConversationController{
  final SharedPreferencesAsync settings=SharedPreferencesAsync();
  List<ConversationModel> messagesLists=[];
  List<ChatListModel>chatLists=[];
  //final String? geminiKey=dotenv.env['GEMINI_API_KEY'];
  bool first=true;
  bool _isFetched = false; // A flag to track if data has been fetched
  //box
  Box<ConversationModel> get conversationModelBox => store.box<ConversationModel>();
  Box<ChatListModel>get chatListBox=>store.box<ChatListModel>();

  //settings for Gemini
  final safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
  ];


  // This ensures fetchDataFromDatabase is only called once during the first use
  Future<void> initialize(String currentConversationId) async {
    if (!_isFetched) {
      await fetchDataFromDatabase(currentConversationId);
      printAllConversations();
      _isFetched = true;
    }
  }

  //fetch data from database
  Future<void>fetchDataFromDatabase(String currentConversationId)async{
    final box=conversationModelBox;
    final query=box.query(ConversationModel_.conversationId.equals(currentConversationId))
        .order(ConversationModel_
        .timestamp).build();
    // Fetch the list of messages from the database
    List<ConversationModel> fetchedMessages = query.find();

    final chatListBox=this.chatListBox;
    chatLists=chatListBox.getAll();

    if(!fetchedMessages.isEmpty){
      messagesLists.clear();
      messagesLists.addAll(fetchedMessages);
    }

    query.close();
  }

  //write into conversation model
  Future<void> writeConversation(String geminiKey,String question, bool sendByAi, bool sendByUser, String currentConversationId) async{
    DateTime now=DateTime.now();
    //remove loading in ui
    if(sendByAi){
      messagesLists.removeLast();
    }

    //enter only if is user submit
    if(sendByUser){
      //check for conversation ID is exist or not
      final chatListBox=this.chatListBox;
      final queryChats=chatListBox.query(ChatListModel_.conversationId.equals(currentConversationId)).build();
      final resultOfChat=queryChats.find();
      //conversation ID not exist in database yet, normally is first time launched
      if(resultOfChat.isEmpty){
        final chat=ChatListModel(conversationId: currentConversationId, addedAt: now);
        chatListBox.put(chat);
        chatLists.add(chat);
      }
      queryChats.close();
    }

    //conversation adding  process
    final box=conversationModelBox;
    //add conversation details into the database
    final conversation=ConversationModel(conversationId: currentConversationId, text: question, sendByAi: sendByAi, sendByUser: sendByUser, timestamp:now);
    //put into objectbox database
    box.put(conversation);
    //add into list for current session use
    messagesLists.add(conversation);
    //returnLatestConversation();
    if(sendByUser){
      //await geminiProcessing(question);
      await geminiMultiTurn(geminiKey,question,currentConversationId);
    }

  }

  //send latest udpated conversation to view
  List<ConversationModel> returnLatestConversation(){
    return messagesLists;
  }

  //return size of conversation
  int conversationSize(){
    return messagesLists.length;
  }

  int totalChatConversation(){
    return chatLists.length;
  }

  int chatNameLenght(int index){
    return chatLists[index].conversationId.length;
  }

  //add chat into database
  Future<bool> addChatToDatabase(String addChatName) async {
    // Access the chatListBox instance variable
    final chatListBox = this.chatListBox; // Optional: remove 'this' if not necessary.

    // Check if the chat with the given name already exists
    for (ChatListModel chatListModel in chatLists) {
      if (addChatName == chatListModel.conversationId) {
        return false; // Chat already exists, return false.
      }
    }

    // If the chat doesn't exist, add it to the database
    ChatListModel chatNew=ChatListModel(
      conversationId: addChatName,
      addedAt: DateTime.now(),
    );
    await chatListBox.put(chatNew);
    chatLists.add(chatNew);
    return true; // Chat successfully added.
  }

  //edit chat into database
  Future<bool> editChatToDatabase(String newChatName,int id,int index) async {
    // Access the chatListBox instance variable
    final chatListBox = this.chatListBox; // Optional: remove 'this' if not necessary.

    // Check if the chat with the given name already exists
    for (ChatListModel chatListModel in chatLists) {
      if (newChatName == chatListModel.conversationId) {
        return false; // Chat already exists, return false.
      }
    }

    //edit conversation entities
    ChatListModel? latestChatConf=chatListBox.get(id);
    if(latestChatConf!=null){
      //update conversation history information
      final box=conversationModelBox;
      final query=box.query(ConversationModel_.conversationId.equals(latestChatConf.conversationId))
          .order(ConversationModel_
          .timestamp).build();
      // Fetch the list of messages from the database
      List<ConversationModel> messagesToUpdate = query.find();
      if(!messagesToUpdate.isEmpty){
        // Iterate through the list and update each record
        for (ConversationModel message in messagesToUpdate) {
          message.conversationId = newChatName;
        }
        // Save the updated records back into the database
        box.putMany(messagesToUpdate);
      }
      query.close();
      latestChatConf.conversationId=newChatName;
      await chatListBox.put(latestChatConf);
      chatLists[index].conversationId=newChatName;
      return true; // Chat successfully added.
    }
    return false;
  }

  //single turn conversation
  Future<void>geminiProcessing(String geminiKey,String question)async {
    if(geminiKey==null){
      return;
    }
    final geminiModel=GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: geminiKey.toString(),
    );
    final prompt=question;
    final response=await geminiModel.generateContent([Content.text(prompt)]);
    messagesLists.last.text=response.text.toString();
    //writeConversation(response.text.toString(), true, false);
  }

  //gemini multi turn without stream
  Future<void>geminiMultiTurn(String geminiKey,String question,String currentConversationId)async{
    //check gemini key
    if(geminiKey==null){
      return;
    }
    //determine gemini model
    final geminiModel=GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: geminiKey,
    );
    //prompt variable
    final prompt = Content.text(question);
    //launch chat
    final chat=geminiModel.startChat(
        history: messagesLists.map((message)=>Content.text(message.text)).toList(),
        safetySettings:safetySettings,
    );
    //print loading to ui
    messagesLists.add(ConversationModel(conversationId: 'chat-1', text: 'Loading...', sendByAi: true, sendByUser: false, timestamp:DateTime.now()));
    final response=await chat.sendMessage(prompt);
    writeConversation(geminiKey,response.text.toString(), true,false,currentConversationId);
  }

  void printAllConversations() {
    // Fetch all items from the box
    List<ConversationModel> allConversations = conversationModelBox.getAll();

    // Print each conversation
    for (var conversation in allConversations) {
      print('ID: ${conversation.id}, Conversation ID: ${conversation.conversationId}, Text: ${conversation.text}, Sent by AI: ${conversation.sendByAi}, Sent by User: ${conversation.sendByUser}, Timestamp: ${conversation.timestamp}');
    }
  }

  //delete conversation in the chat
  Future<void>deleteAllInDatabase(String currentConversationId)async {
    final box = conversationModelBox;
    final queryDeleteConversation = box.query(ConversationModel_.conversationId
        .equals(currentConversationId)).order(ConversationModel_.timestamp).build();

    // Remove all entries matching the query
    queryDeleteConversation.remove();  // Correct way to delete queried objects

    // Close the query to free resources
    queryDeleteConversation.close();

    // Clear the local messages list (if any)
    messagesLists.clear();

  }

  Future<void>deleteSpecifyChat(String conversationId,int index)async{
    final box=conversationModelBox;
    final boxChat=chatListBox;
    final queryDeleteConversation= box.query(ConversationModel_.conversationId.equals(conversationId)).order(ConversationModel_.timestamp).build();
    final queryDeleteChat=boxChat.query(ChatListModel_.conversationId.equals(conversationId)).build();
    queryDeleteChat.remove();
    queryDeleteConversation.remove();
    chatLists.remove(chatLists[index]);
    queryDeleteConversation.close();
    queryDeleteChat.close();

  }
}