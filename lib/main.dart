import 'package:chatbot_gemini_official/view/chatbot_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'objectbox.dart';
import 'objectbox.g.dart';
import 'package:msix/msix.dart';

late final Store store;
late ObjectBox objectbox;

Future<void> main() async {
  await dotenv.load(fileName: 'key.env');
  store=await openStore();
  objectbox = await ObjectBox.create();
  runApp(const ChatbotMain());
}

class ChatbotMain extends StatelessWidget {
  const ChatbotMain({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatbotView(),
    );
  }
}


