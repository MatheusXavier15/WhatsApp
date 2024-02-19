import 'package:flutter/material.dart';
import 'package:whatsapp/model/chat.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  List<Chat> chatList = [
    Chat("Matheus Xavier", "Olá tudo bem?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-projeto-e20df.appspot.com/o/profile%2Fperfil1.jpg?alt=media&token=4f14e473-61f9-47e6-8e17-401af6487d11"),
    Chat("Welinys", "Olá tudo bem?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-projeto-e20df.appspot.com/o/profile%2Fperfil4.jpg?alt=media&token=29bc2237-c057-4805-874f-852a6f690633"),
    Chat("Thamires", "Olá tudo bem?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-projeto-e20df.appspot.com/o/profile%2Fperfil2.jpg?alt=media&token=e3ce0afa-7006-4d08-90b2-2eb7fb325ad8"),
    Chat("Vinícius", "Olá tudo bem?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-projeto-e20df.appspot.com/o/profile%2Fperfil2.jpg?alt=media&token=e3ce0afa-7006-4d08-90b2-2eb7fb325ad8"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        Chat chat = chatList[index];
        return ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          leading: CircleAvatar(
            maxRadius: 30,
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(chat.photoPath),
          ),
          title: Text(
            chat.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            chat.message,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        );
      },
    );
  }
}
