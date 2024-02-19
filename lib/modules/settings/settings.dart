import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _controllerName = TextEditingController();
  late File _image;
  late User _currentUser;
  String _fetchedUrlImage = "";
  bool _uploadingImage = false;

  Future<void> _recoverImage(String origin) async {
    XFile? selectedImage;
    switch (origin) {
      case "camera":
        selectedImage =
            await ImagePicker().pickImage(source: ImageSource.camera);
        break;
      default:
        selectedImage =
            await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    if (selectedImage != null) {
      File imageFile = File(selectedImage.path);
      setState(() {
        _image = imageFile;
        _uploadingImage = true;
        _uploadImage();
      });
    }
  }

  Future<void> _uploadImage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference rootPaste = storage.ref();
    Reference doc = rootPaste.child("profile").child("${_currentUser.uid}.jpg");

    UploadTask task = doc.putFile(_image);
    task.then((snapshot) {
      _fetchUrlUploadedImage(snapshot);
      setState(() {
        _uploadingImage = false;
      });
    });
  }

  Future<void> _fetchUrlUploadedImage(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    setState(() {
      _fetchedUrlImage = url;
    });
  }

  Future<void> _recoverUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    _currentUser = auth.currentUser!;
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference rootPaste = storage.ref();
    Reference doc = rootPaste.child("profile").child("${_currentUser.uid}.jpg");
    try {
      final url = await doc.getDownloadURL();
      setState(() {
        _fetchedUrlImage = url;
      });
    } catch (e) {
      _fetchedUrlImage = "";
    }
  }

  @override
  void initState() {
    _recoverUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _uploadingImage
                    ? const CircularProgressIndicator()
                    : CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(_fetchedUrlImage)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await _recoverImage("camera");
                      },
                      child: const Text("Câmera"),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _recoverImage("gallery");
                      },
                      child: const Text("Galeria"),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerName,
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      hintText: "Nome",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF25D366)),
                    ),
                    onPressed: () {},
                    child: const Text("Salvar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
