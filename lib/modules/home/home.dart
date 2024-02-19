import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/modules/home/pages/chats.dart';
import 'package:whatsapp/modules/home/pages/contacts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  TabController? _tabController;
  List<String> itensMenu = ["Configurações", "Sair"];

  _selectedMenuItem(String selectedItem) async {
    switch (selectedItem) {
      case "Configurações":
        Navigator.of(context).pushNamed('/settings');
        break;
      default:
        await _signOutUser();
    }
  }

  _signOutUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WhatsApp"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          labelStyle:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(
              text: "Conversas",
            ),
            Tab(
              text: "Contatos",
            )
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _selectedMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((item) {
                return PopupMenuItem(value: item, child: Text(item));
              }).toList();
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ChatsPage(),
          ContactsPage(),
        ],
      ),
    );
  }
}
