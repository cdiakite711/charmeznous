import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String userId;

  const ChatScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat avec $userId')),
      body: Center(child: Text('Écran de chat en construction')),
    );
  }
}