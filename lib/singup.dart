import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/home.dart';
import 'package:whatsapp/model/User.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  String _errorMessage = "";

  _validateFields() {
    final String name = _controllerName.text;
    final String email = _controllerEmail.text;
    final String password = _controllerPassword.text;

    if (name.isEmpty) {
      setState(() {
        _errorMessage = "Preencha o nome";
      });
      return;
    }

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

    UserModel user =  UserModel();
    user.name = name;
    user.password = password;
    user.email = email;

    _singUpUser(user);
  }

  _singUpUser(UserModel user) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .createUserWithEmailAndPassword(
            email: user.email, password: user.password)
        .then(
          (firebaseUser) {
            FirebaseFirestore db = FirebaseFirestore.instance;
            db.collection("users")
            .doc(firebaseUser.user?.uid)
            .set(user.toMap());

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const Home(),
              ),
              (Route<dynamic> route) => false,
            );
          },
        )
        .catchError(
      (onError) {
        setState(
          () {
            _errorMessage =
                "Erro ao criar usuário. Verifique os campos e tente novamente.";
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro"),
      ),
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
                      "assets/images/usuario.png",
                      width: 100,
                      height: 75,
                    ),
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
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _controllerEmail,
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
                      child: const Text("Cadastrar"),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Já possui uma conta? Entrar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.white),
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
