import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/model/chat.dart';
import 'package:whatsapp/model/message.dart';
import 'package:whatsapp/model/user.dart';

class ChatPage extends StatefulWidget {
  ChatPage(this.contact, {super.key});

  UserModel contact;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controllerMessage = TextEditingController();

  late User currentUser;

  late File _image;

  String _fetchedUrlImage = "";

  bool _uploadingImage = false;

  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> _saveMessage(
      String idSender, String idReceiver, Message msg) async {
    db
        .collection("messages")
        .doc(idSender)
        .collection(idReceiver)
        .add(msg.toMap());
  }

  void _sendMessage() {
    final String messageText = _controllerMessage.text;
    if (_fetchedUrlImage != "" || messageText.trim().isNotEmpty) {
      final Message msg = Message();
      msg.messageText = messageText;
      msg.userId = currentUser.uid;
      msg.type = _fetchedUrlImage != "" ? "image" : "text";
      msg.urlImage = _fetchedUrlImage;
      msg.createdAt = DateTime.now();
      _saveMessage(currentUser.uid, widget.contact.id, msg);
      _saveMessage(widget.contact.id, currentUser.uid, msg);
      _saveChat(msg);
      _controllerMessage.clear();
      _fetchedUrlImage = "";
    }
  }

  void _saveChat(Message msg) {
    Chat chatSender = Chat();
    chatSender.senderId = currentUser.uid;
    chatSender.receiverId = widget.contact.id;
    chatSender.name = widget.contact.name;
    chatSender.message = msg.messageText;
    chatSender.photoPath = widget.contact.imageProfileUrl;
    chatSender.type = msg.type;
    chatSender.save();

    Chat chatReceiver = Chat();
    chatReceiver.senderId =  widget.contact.id;
    chatReceiver.receiverId = currentUser.uid;
    chatReceiver.name = widget.contact.name;
    chatReceiver.message = msg.messageText;
    chatReceiver.photoPath = widget.contact.imageProfileUrl;
    chatReceiver.type = msg.type;
    chatReceiver.save();
  }

  Future<void> _fetchUrlUploadedImage(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    setState(() {
      _fetchedUrlImage = url;
      _sendMessage();
    });
  }

  _sendPhoto() async {
    final selectedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      File imageFile = File(selectedImage.path);
      setState(() {
        _image = imageFile;
        _uploadingImage = true;
        _uploadImage();
      });
    }
  }

  _uploadImage() {
    String imgName = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference rootPaste = storage.ref();
    Reference doc = rootPaste
        .child("messages")
        .child(currentUser.uid)
        .child("$imgName.jpg");

    UploadTask task = doc.putFile(_image);
    task.then((snapshot) {
      _fetchUrlUploadedImage(snapshot);
      setState(() {
        _uploadingImage = false;
      });
    });
  }

  @override
  void initState() {
    FirebaseAuth auth = FirebaseAuth.instance;
    currentUser = auth.currentUser!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    StreamBuilder messagesList = StreamBuilder<QuerySnapshot>(
        stream: db
            .collection("messages")
            .doc(currentUser.uid)
            .collection(widget.contact.id)
            .orderBy("_createdAt", descending: false)
            .snapshots(),
        builder: (_, snap) {
          switch (snap.connectionState) {
            case ConnectionState.none:
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Nenhuma mensagem encontrada.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            case ConnectionState.waiting:
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            case ConnectionState.active:
              QuerySnapshot<Object?>? querySnapshot = snap.data;
              if (snap.hasError) {
                return const Expanded(
                  child: Text("Erro ao carregar dados"),
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: querySnapshot?.docs.length,
                  itemBuilder: (_, index) {
                    List<QueryDocumentSnapshot<Object?>> messages =
                        querySnapshot!.docs.toList();
                    QueryDocumentSnapshot msg = messages[index];

                    Alignment messageAlign = msg["_userId"] == currentUser.uid
                        ? Alignment.centerRight
                        : Alignment.centerLeft;
                    Color messageColor = msg["_userId"] == currentUser.uid
                        ? const Color(0xffd2ffa5)
                        : Colors.white;

                    return Align(
                      alignment: messageAlign,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: messageColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: msg["_type"] == "image"
                              ? Image.network(msg["_urlImage"] as String)
                              : Column(
                                  crossAxisAlignment:
                                      msg["_userId"] == currentUser.uid
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg["_messageText"],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      DateFormat.Hm().format(
                                          (msg["_createdAt"] as Timestamp)
                                              .toDate()),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                ),
              );
            case ConnectionState.done:
              return Container();
              break;
          }
        });

    final Widget messageBox = Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextField(
                controller: _controllerMessage,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  prefixIcon: _uploadingImage
                      ? SizedBox(
                          height: 10,
                          width: 10,
                          child: Center(
                            child: Transform.scale(
                              scale: 0.5,
                              child: const CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _sendPhoto,
                        ),
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  hintText: "Digite uma mensagem...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.5),
                  ),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: const Color(0xFF075E54),
            mini: true,
            onPressed: _sendMessage,
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 20,
            ),
          )
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 90,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CircleAvatar(
              maxRadius: 20,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(widget.contact.imageProfileUrl),
            ),
          ],
        ),
        title: Align(
            alignment: Alignment.centerLeft, child: Text(widget.contact.name)),
      ),
      body: Container(
        color: Colors.blueGrey[100],
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(16),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                messagesList,
                messageBox,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
