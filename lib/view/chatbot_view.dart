import 'dart:ui';

import 'package:chatbot_gemini_official/controller/conversation_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/conversation_model.dart';


class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  late ConversationController conversationController;
  TextEditingController chatNameController=TextEditingController();
  TextEditingController chatOriNameController=TextEditingController();
  TextEditingController keySettingController=TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool showLatestButton=false;
  bool showOldestButton=false;
  bool isAtBottom = false;
  bool isAtTop=false;
  //late List<ConversationModel> messagesList;
  TextEditingController questionController=TextEditingController();
  final SharedPreferencesAsync settings=SharedPreferencesAsync();
  String currentConversationId='';
  String currentGeminiKey='';


  static const TextStyle fontStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    //fontFamily: 'NotoSansSC',
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w700,
    //fontFamily: 'NotoSansSC',
  );



  @override
  void initState() {
    super.initState();
    conversationController = ConversationController();
    initProcess();
    scrollController.addListener(() {
      // Check if the user is scrolling
      if (scrollController.hasClients) {
        setState(() {
          showLatestButton = scrollController.offset > 10;
          showOldestButton=scrollController.offset>10;
          isAtBottom= scrollController.offset > scrollController.position.maxScrollExtent - 100;
          isAtTop=scrollController.offset<scrollController.position.minScrollExtent+100;
          if(isAtBottom || isAtTop){
            showLatestButton=false;
            showOldestButton=false;
          }
        });
      }
    });
  }

  Future<void>initProcess() async{
    //set settings of key and default chat
    final String? tempId = await settings.getString('Default-chat-conversation');
    final String? geminiKey = await settings.getString('Gemini-Key');
    currentGeminiKey=geminiKey.toString();
    currentConversationId=tempId.toString();
    if(currentConversationId=='' || currentConversationId== 'null'){
      DateTime dateTime=DateTime.now();
      // Extract components
      String chatNameTemp=dateTime.year.toString()+'_'+dateTime.hour.toString()+':'+dateTime.minute.toString()+':'+dateTime.second.toString();
      currentConversationId='chat_$chatNameTemp';
    }

    conversationController.initialize(currentConversationId);
    //conversationId=conversationController.chatLists.last.conversationId;
    setState(() {});
    //messagesList = conversationController.returnLatestConversation();

  }

  void scrollToBottom(){
    scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
    );
  }

  void scrollToTop(){
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    //settings.setString('Default-chat-conversation',currentConversationId);
    chatOriNameController.dispose();
    chatNameController.dispose();
    questionController.dispose();
    super.dispose();
  }

  //edit the chat name
  Future<void>editChat(int index,String oldChatName)async{
    //show orginal chat name in list tile
    chatOriNameController.text=conversationController.chatLists[index].conversationId.toString();
    return showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('New Chat name'),
          content: TextField(
            controller:chatOriNameController,
            decoration: InputDecoration(
                hintText: 'Must be unique name'
            ),

          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                if(chatOriNameController.text.length<=18){
                  Navigator.of(context).pop();
                  var isDefault=false;
                  if(currentConversationId==oldChatName){
                    isDefault=true;
                  }
                  bool editChatStatues=await conversationController.editChatToDatabase(chatOriNameController.text,conversationController.chatLists[index].id,index);
                  if(editChatStatues==true){
                    //if is default chat then need to update to it
                    if(isDefault){
                      currentConversationId=chatOriNameController.text;
                      await settings.setString('Default-chat-conversation',currentConversationId);
                    }
                    Fluttertoast.showToast(
                        msg: 'Chat name change successfully',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.purple[50],
                        textColor: Colors.blue[500],
                        fontSize: 16.0
                    );

                  }
                  else{
                    Fluttertoast.showToast(
                        msg: 'Chat creation fail as the chat name is not unique',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.purple[50],
                        textColor: Colors.blue[500],
                        fontSize: 16.0
                    );
                  }
                }
                else{
                  Fluttertoast.showToast(
                      msg: 'Chat creation fail as the chat name is more than 18 words',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.purple[50],
                      textColor: Colors.blue[500],
                      fontSize: 16.0
                  );

                }
              },
            ),
          ],

        );
      },
    );

  }

  Future<void>addChat()async {
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Chat name'),
            content: TextField(
              controller: chatNameController,
              decoration: InputDecoration(
                hintText: 'Must be unique name'
              ),

            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () async {
                  if(chatNameController.text.length<=18){
                    Navigator.of(context).pop();
                    bool addChatStatues=await conversationController.addChatToDatabase(chatNameController.text);
                    if(addChatStatues==true){
                      chatNameController.text='';
                      Fluttertoast.showToast(
                          msg: 'Chat creation success',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.purple[50],
                          textColor: Colors.blue[500],
                          fontSize: 16.0
                      );

                    }
                    else{
                      Fluttertoast.showToast(
                          msg: 'Chat creation fail as the chat name is not unique',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.purple[50],
                          textColor: Colors.blue[500],
                          fontSize: 16.0
                      );
                    }
                  }
                  else{
                    Fluttertoast.showToast(
                        msg: 'Chat creation fail as the chat name is more than 18 words',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.purple[50],
                        textColor: Colors.blue[500],
                        fontSize: 16.0
                    );

                  }
                },
              ),
            ],

          );
        },
    );

  }

  Future<void>addKey()async {
    final String? geminiKey = await settings.getString('Gemini-Key');
    if(geminiKey!=null && geminiKey.isNotEmpty){
      keySettingController.text=geminiKey.toString();
    }
    return showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Input Gemini Key'),
          content: TextField(
            controller: keySettingController,
            decoration: InputDecoration(
                hintText: 'Must be generated by Google'
            ),

          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.of(context).pop();
                await settings.setString('Gemini-Key', keySettingController.text.toString());
                final String? tempKey=await settings.getString('Gemini-Key');
                currentGeminiKey=tempKey!;
              },
            ),
          ],

        );
      },
    );

  }

  Future<void>addKeyToSharePref(String key)async{
    settings.setString('Gemini-Key', key);
  }

  //submit button
  Future<void> submitQuestion()async{
    FocusScope.of(context).unfocus();
    settings.setString('Default-chat-conversation', currentConversationId);
    await conversationController.writeConversation(currentGeminiKey,questionController.text, false, true,currentConversationId);
    questionController.clear();
    setState(() {});

  }

  //change to another conversation
  Future<void>changeConversation(int index)async {
    currentConversationId=conversationController.chatLists[index].conversationId;
    conversationController.messagesLists.clear();
    await settings.setString('Default-chat-conversation',currentConversationId);
    await conversationController.fetchDataFromDatabase(currentConversationId);
    Navigator.of(context).pop();
  }

  void errorPrint()async{
    Fluttertoast.showToast(
        msg: 'Please dont send empty text and Gemini key must not empty',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.purple[50],
        textColor: Colors.blue[500],
        fontSize: 16.0
    );

  }

  void errorOfDefault()async{
    Fluttertoast.showToast(
        msg: 'You cannot delete the active chat',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.purple[50],
        textColor: Colors.blue[500],
        fontSize: 16.0
    );

  }

  bool isDefault(int index){
    String temp=conversationController.chatLists[index].conversationId;
    if(temp==currentConversationId){
      return true;
    }
    return false;

  }


  @override
  Widget build(BuildContext context) {
    final screenWidth=MediaQuery.of(context).size.width;
    final screenHeight=MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Row(
          children: [
            SizedBox(width: screenWidth*0.03), // Add some spacing between the icon and the text
            Text(
              currentConversationId.isEmpty?'emptyy':currentConversationId,
              style: titleStyle,
            ),
            SizedBox(width: screenWidth*0.03),
            IconButton(
              icon: Icon(Icons.delete,size: 30),
              color: Colors.red[500],

              onPressed: (){
                conversationController.deleteAllInDatabase(currentConversationId);
                setState(() {});
              },
            ),
          ],
        ),

        actions: [
          Builder(
            builder: (context)=>IconButton(
              onPressed: (){
                Scaffold.of(context).openEndDrawer();
              },
              icon: Icon(Icons.menu),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: screenWidth*0.8,
        elevation: 10,
        child: SingleChildScrollView(  // Wrap the ListView with SingleChildScrollView
          child: Column(
            children: [
              SizedBox(height: screenHeight*0.05),
              Container(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.key),
                  onPressed: addKey,
                  label: Text('Gemini API key'),
                ),
              ),

              ListView.builder(
                shrinkWrap: true,  // Takes only the space it needs
                physics: NeverScrollableScrollPhysics(),// Disable inner scrolling
                itemCount: conversationController.chatLists.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                conversationController.chatLists[index].conversationId.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,  // Important to make sure buttons are tightly packed
                            children: [

                              IconButton(
                                onPressed: () async {
                                  String oldChatName=conversationController.chatLists[index].conversationId.toString();
                                  await editChat(index,oldChatName);
                                  setState(() {});
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: isDefault(index)? null : () async {
                                  await conversationController.deleteSpecifyChat(conversationController.chatLists[index].conversationId, index);
                                  setState(() {});
                                  },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
                          onTap: () async {
                            await changeConversation(index);
                            setState(() {});
                          },
                        ),
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() async {
                    // Define the action to be performed when the button is pressed
                    await addChat();
                  });

                },
                icon: Icon(Icons.add, size: 24), // The icon to be displayed
                label: Text("Add Item"), // The label (text) next to the icon
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Button padding
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  //padding: const EdgeInsets.fromLTRB(0.0,10.0,0.0,0.0),
                  child: ListView.builder(
                    controller: scrollController,
                    //padding: const EdgeInsets.fromLTRB(0.0,10.0,0.0,0.0),
                    itemCount: conversationController.conversationSize(),
                    itemBuilder: (context,index){
                      return ListTile(
                        title: Align(
                          //even == user odd == AI
                          alignment: conversationController.messagesLists[index].sendByUser == true ? Alignment.centerRight : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth*0.7,
                            ),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(10.0,10.0,10.0,10.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: conversationController.messagesLists[index].sendByUser == true ? Colors.lightBlue[200] : Colors.purple[100],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: SelectableText.rich(

                                textAlign: TextAlign.justify,
                                TextSpan(
                                  style: fontStyle,
                                  children: [
                                    TextSpan(
                                      //messagesList[index].text,
                                      text: conversationController.messagesLists[index].text,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                height: screenHeight*0.3,
                width: screenWidth,
                child: Card(
                  elevation: 20,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    child: Column(
                      //vertical
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          //horizontal
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'android/lib/assets/images/pisces.svg',
                              width: screenWidth*0.03,
                              height: screenHeight*0.03,
                              color: Colors.purple[300],
                            ),
                            SizedBox(width: screenWidth*0.04),
                            const Text(
                              'Good Morning',
                              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.purple),
                            ),
                          ],
                        ),

                        SizedBox(height:screenHeight*0.02),
                        TextField(
                          controller: questionController,
                          maxLines: 4,
                          minLines: 4,
                          keyboardType: TextInputType.multiline,
                          style:  fontStyle,
                          //expands: true,
                          decoration: const InputDecoration(
                            hintText: 'Ask anything you doubt',
                            label: Text('Question'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,

                          child: FilledButton.icon(
                            onPressed:()async{
                              // Check if the text is not empty and perform the corresponding action
                              if (questionController.text.isNotEmpty && currentGeminiKey!='null') {
                                await submitQuestion();
                                // Call the async method
                              }
                              else {
                                errorPrint(); // Call the method to handle empty input
                              }
                              // Update the state after async operations
                              setState(() {});
                              scrollToBottom();
                            },
                            label: Text('Send'),
                            icon: Icon(Icons.send_sharp),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          if (showLatestButton)
            Positioned(
              left: screenWidth*0.4,   // Distance from the left of the screen
              bottom: screenHeight*0.32,   // Distance from the top of the screen
              child:SizedBox(
                width: screenWidth*0.2,  // Set the desired width
                height:screenHeight*0.03,
                child: FloatingActionButton(
                  backgroundColor: Colors.grey[50],
                  onPressed: scrollToBottom,
                  child: Icon(Icons.arrow_downward),
                  tooltip: 'Scroll to Bottom',
                ),
              ),
            ),// Show the button only if _showButton is true

          if (showOldestButton) // Show the button only if _showButton is true
            Positioned(
              left: screenWidth*0.4,   // Distance from the left of the screen
              top: screenHeight*0.02,   // Distance from the top of the screen
              child: SizedBox(
                width: screenWidth*0.2,  // Set the desired width
                height:screenHeight*0.03, // Set the desired height
                child: FloatingActionButton(
                  backgroundColor: Colors.grey[50],
                  onPressed: scrollToTop,
                  child: Icon(Icons.arrow_upward),
                  tooltip: 'Scroll to Bottom',
                ),
              ),
            ),
        ],
      ),
    );
  }
}