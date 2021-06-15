// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projectmsa/series_page.dart';
import 'package:projectmsa/signin_page.dart';

import 'anime_page.dart';
import 'movie_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent[200],
      appBar: AppBar(
        title: Text("Movies & Series & Anime"),
        actions: [
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.blueAccent,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MoviePage(),
              ),
            ),
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 40.0),
              color: Colors.blue[100],
              child: ListTile(
                leading: Icon(
                  Icons.movie_filter_outlined,
                  color: Colors.blue,
                ),
                title: Text(
                  'Movies',
                  style: TextStyle(color: Colors.blue, fontSize: 20.0),
                ),
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.greenAccent,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SeriesPage(),
              ),
            ),
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 40.0),
              color: Colors.green[100],
              child: ListTile(
                leading: Icon(
                  Icons.supervised_user_circle_outlined,
                  color: Colors.green,
                ),
                title: Text(
                  'Series',
                  style: TextStyle(color: Colors.green, fontSize: 20.0),
                ),
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.purpleAccent,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AnimePage(),
              ),
            ),
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 40.0),
              color: Colors.purple[100],
              child: ListTile(
                leading: Icon(
                  Icons.animation,
                  color: Colors.purple,
                ),
                title: Text(
                  'Anime',
                  style: TextStyle(color: Colors.purple, fontSize: 20.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

