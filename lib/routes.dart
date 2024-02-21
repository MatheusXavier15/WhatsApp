import 'package:flutter/material.dart';
import 'package:whatsapp/model/user.dart';
import 'package:whatsapp/modules/auth/login.dart';
import 'package:whatsapp/modules/auth/sign_up.dart';
import 'package:whatsapp/modules/chat/chat_page.dart';
import 'package:whatsapp/modules/home/home.dart';
import 'package:whatsapp/modules/settings/settings.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {

    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => const Login());
      case "/login":
        return MaterialPageRoute(builder: (_) => const Login());
      case "/signUp":
        return MaterialPageRoute(builder: (_) => const SignUp());
      case "/home":
        return MaterialPageRoute(builder: (_) => const Home());
      case "/settings":
        return MaterialPageRoute(builder: (_) => const Settings());
      case "/chat":
        return MaterialPageRoute(builder: (_) => ChatPage(args as UserModel));
      default:
        return MaterialPageRoute(builder: (_) => const Login());
    }
  }
}
