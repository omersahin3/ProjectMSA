// @dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

/// Email / Şifre ile kayıt sayfası
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _success = true;
  String _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kayıt Ol"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //? E-Mail
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "E-Mail",hintText: "Enter your email"),
                    validator: (String mail) {
                      if (mail.isEmpty) {
                        return "Lütfen bir mail yazın";
                      }
                      return null;
                    },
                  ),
                  //? Şifre
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: "Şifre"),
                    validator: (String password) {
                      if (password.isEmpty) {
                        return "Lütfen bir şifre yazın";
                      }
                      return null;
                    },
                    obscureText: true, //! Şifrenin görünmesini engeller.
                  ),
                  //? Kayıt ol buttonu
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    child: SignInButtonBuilder(
                      icon: Icons.person_add,
                      backgroundColor: Colors.blueGrey,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _register();
                        }
                      },
                      text: "Kayıt ol",
                    ),
                  ),
                  //? Geri bildirim
                  Container(
                    alignment: Alignment.center,
                    child: Text(_success == null ? '' : _message ?? ''),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    //! Widget kapatıldığında controllerları temizle
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Kayıt işlemi için
  void _register() async {
    try {
      final User user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
      if (user != null) {
        setState(() {
          _success = true;
          _message = "Kayıt başarılı ${user.email}";
        });
      } else {
        setState(() {
          _success = false;
          _message = "Kayıt başarısız.";
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _success = false;
        _message = "Kayıt başarısız.\n\n$e";
      });
    }
  }
}
