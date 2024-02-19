import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/user.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  String _errorMessage = "";

  _validateFields() {
    final String email = _controllerEmail.text;
    final String password = _controllerPassword.text;

    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Preencha o e-mail";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = "Preencha a senha";
      });
      return;
    }

    setState(() {
      _errorMessage = "";
    });

    UserModel user = UserModel();
    user.email = email;
    user.password = password;

    _signInUser(user);
  }

  _signInUser(UserModel user) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .signInWithEmailAndPassword(email: user.email, password: user.password)
        .then((success) => {
              Navigator.pushReplacementNamed(
                context,
                '/home',
              )
            })
        .catchError((error) {
      setState(() {
        _errorMessage =
            "Não foi possível autenticar. Verifique e-mail e senha.";
      });
    });
  }

  _verifyIfUserIsLoggedIn() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
      return;
    }
  }

  @override
  void initState() {
    _verifyIfUserIsLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xff075e54)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 100,
                      height: 75,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _controllerEmail,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        hintText: "E-mail",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.5),
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _controllerPassword,
                    style: const TextStyle(fontSize: 16),
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.5),
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
                      onPressed: () {
                        _validateFields();
                      },
                      child: const Text("Entrar"),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signUp');
                    },
                    child: const Text(
                      "Não tem conta? Cadastre-se",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
