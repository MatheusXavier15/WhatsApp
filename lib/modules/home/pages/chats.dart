import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/model/user.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final _streamController = StreamController<QuerySnapshot>.broadcast();

  final FirebaseFirestore db = FirebaseFirestore.instance;

  final User currentUser = FirebaseAuth.instance.currentUser!;

  _addChatListner() {
    final stream = db
        .collection("chats")
        .doc(currentUser.uid)
        .collection("lastChat")
        .snapshots();

    stream.listen((data) {
      _streamController.add(data);
    });
  }

  @override
  void initState() {
    _addChatListner();
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _streamController.stream,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasData) {
            QuerySnapshot<Object?>? querySnapshot = snap.data;

            if (querySnapshot != null && querySnapshot.docs.isEmpty) {
              return const Center(
                child: Text("Nenhuma conversa disponível ainda!"),
              );
            }

            final chats = querySnapshot!.docs.toList();
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                DocumentSnapshot chat = chats[index];
                return ListTile(
                  onTap: () {
                    final user = UserModel();
                    user.id = chat["_receiverId"];
                    user.name = chat["_name"];
                    user.imageProfileUrl = chat["_photoPath"];
                    Navigator.of(context).pushNamed('/chat', arguments: user);
                  },
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  leading: CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage: chat["_photoPath"] != null
                        ? NetworkImage(chat["_photoPath"])
                        : null,
                  ),
                  title: Text(
                    chat["_name"],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat["_type"] == "text"
                            ? chat["_message"]
                            : "📷 imagem",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        DateFormat.Hm()
                            .format((chat["_createdAt"] as Timestamp).toDate()),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return Container();
        });
  }
}
