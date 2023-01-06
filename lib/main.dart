import 'package:chatbot/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

const backgroundcolor = Color.fromARGB(255, 22, 26, 75);
const botbackgroundcolor = Color.fromARGB(255, 1, 4, 39);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late bool isLoading;
  TextEditingController _textController = TextEditingController();
  final _scrollContraller = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
  }

  Future<String> generateResponse(String prompt) async {
    final apiKey = apiSecretKey;
    var url = Uri.https("api.open.com", "/v1/completions");
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application.json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          'model': 'text-davinci-003',
          'prompt': prompt,
          'temperature': 0,
          'max_token': 2000,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }));

    Map<String, dynamic> newresponse = jsonDecode(response.body);
    return newresponse['choices'][0]['text'];
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "ChatGPT",
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: botbackgroundcolor,
        ),
        backgroundColor: backgroundcolor,
        body: Column(
          children: [
            Expanded(
              child: _buildList(),
            ),
            Visibility(
              visible: isLoading,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  //input field
                  _buildInput(),
                  //submit button
                  _buildSubmit(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(color: Colors.white),
        controller: _textController,
        decoration: InputDecoration(
          fillColor: botbackgroundcolor,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return Visibility(
        visible: !isLoading,
        child: Container(
          child: IconButton(
            icon: Icon(
              Icons.send,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () {},
          ),
        ));
  }

  ListView _buildList() {
    return ListView.builder(
      itemCount: _messages.length,
      controller: _scrollContraller,
      itemBuilder: ((context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      }),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final ChatMessageType chatMessageType;
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(16),
      color: ChatMessageType == ChatMessageType.bot
          ? botbackgroundcolor
          : backgroundcolor,
      child: Row(
        children: [
          ChatMessageType == ChatMessageType.bot
              ? Container(
                  margin: EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 73, 83, 226),
                    child: Image.asset(
                      'assets/bot2.png',
                      color: Colors.white,
                      scale: 1.5,
                    ),
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(right: 16),
                  child:
                      CircleAvatar(child: Icon(Icons.person_outline_rounded)),
                ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
