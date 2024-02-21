import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/user.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  Future<List<UserModel>> _fetchContacts() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await db.collection("users").get();
    List<UserModel> users = [];
    FirebaseAuth auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    for (QueryDocumentSnapshot item in snapshot.docs) {
      var data = item.data() as Map?;
      UserModel user = UserModel();
      user.id = item.id;
      user.email = data?["_email"];
      user.name = data?["_name"];
      user.imageProfileUrl = data?["urlImage"] ?? "";
      if (user.email == currentUser?.email) {
        continue;
      }
      users.add(user);
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _fetchContacts(),
      builder: (_, snap) {
        switch (snap.connectionState) {
          case ConnectionState.none:
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Nenhum usuário cadastrado.",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            );
          case ConnectionState.active:
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            );
          case ConnectionState.waiting:
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            );
          case ConnectionState.done:
            return snap.data!.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Nenhum usuário cadastrado.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: snap.data!.length,
                    itemBuilder: (_, index) {
                      UserModel user = snap.data![index];
                      return ListTile(
                        onTap: (){
                          Navigator.of(context).pushNamed('/chat', arguments: user);
                        },
                        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(user.imageProfileUrl),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      );
                    },
                  );
          default:
            return const Text(
              "Nenhum usuário cadastrado.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            );
        }
      },
    );
  }
}
