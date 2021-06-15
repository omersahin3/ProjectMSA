// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projectmsa/signin_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SeriesPage extends StatelessWidget {
  // Eskiden Firestore'du.
  final Query query = FirebaseFirestore.instance
      .collection("series")
      .orderBy('title', descending: false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("               Series"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async => {
              showDialog(
                  context: context,
                  builder: (_) => new AlertDialog(
                    actions: <Widget>[
                      _Dialog(),
                    ],
                  )),
            },
          ),
          //! Builder eklemezsek Scaffold.of() hata verecektir!
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.login),
              onPressed: () async {
                final User user = _auth.currentUser; // Eskiden asenkrondu
                if (user == null) {
                  Scaffold.of(context).showSnackBar(const SnackBar(
                    content: Text("Henüz giriş yapılmamış"),
                  ));
                  return;
                }

                await _auth.signOut();
                if (await GoogleSignIn().isSignedIn()) {
                  debugPrint("Google User");
                  await GoogleSignIn().disconnect();
                  await GoogleSignIn().signOut();
                } // Çıkış yapma kodu

                final String uid = user.uid;
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("$uid başarıyla çıkış yaptı"),
                ));

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInPage(),
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: query.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Icon(Icons.error,size: 120,color: Colors.red,),
              );
            }
            final QuerySnapshot querySnapshot = snapshot.data;
            return ListView.builder(
                itemCount: querySnapshot.size,
                itemBuilder: (context, index) {
                  final map = querySnapshot.docs[index].data();
                  return Dismissible(
                    key: Key(querySnapshot.docs[index].id),
                    onDismissed: (direction) {
                      querySnapshot.docs[index].reference.delete();
                    },
                    child: ListTile(
                        onTap: () {
                          var isWatched = true;
                          if (querySnapshot.docs[index].data()['isWatched'] == true) {
                            isWatched = false;
                          }
                          querySnapshot.docs[index].reference.update({'isWatched': isWatched});
                        },
                        leading: map['image'] != null
                            ? Image.network(map['image'])
                            : SizedBox.shrink(),
                        title: Text(map['title']),
                        subtitle:
                        map['year'] != null ? Text("${map['year']}") : null,
                        trailing: map['isWatched'] == true
                            ? Icon(
                          Icons.check_box,
                          color: Colors.green,
                        )
                            : SizedBox.shrink()),
                  );
                });
          },
        ),
      ),
    );
  }
}
class _Dialog extends StatefulWidget {
  @override
  __DialogState createState() => __DialogState();
}

class __DialogState extends State<_Dialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _yearController = TextEditingController();

  final TextEditingController _imageController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Dizi Adı"),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Lütfen bir Dizi adı giriniz";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(labelText: "Yıl"),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Lütfen bir yıl giriniz";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: "Resim"),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Lütfen bir resim url giriniz";
                  }
                  return 'null';
                },
              ),
              RaisedButton(
                color: Colors.orangeAccent,
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _saveSeries(context);
                  }
                },
                child: Text("Kaydet"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSeries(BuildContext context) async {
    try {
      final String title = _titleController.text;
      final int year = int.parse(_yearController.text);
      final String image = _imageController.text;

      Map<String, dynamic> map = {
        'title': title,
        'year': year,
        'image': image,
      };

      FirebaseFirestore.instance.collection("series").add(map);

      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
