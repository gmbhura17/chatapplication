import 'package:chatapplication/ViewPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Chatapp extends StatefulWidget {

  @override
  State<Chatapp> createState() => _ChatappState();
}

class _ChatappState extends State<Chatapp> {
  FirebaseAuth auth = FirebaseAuth.instance;

  var displayName="";
  var email="";
  var photoURL="";
  var uid="";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("chat app - login page "),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 300),
            Container(
                 child: Center(
                   child: GestureDetector(
                      onTap: () async {
                        final GoogleSignIn googleSignIn = GoogleSignIn();
                        final GoogleSignInAccount? googleSignInAccount = await googleSignIn
                            .signIn();
                        if (googleSignInAccount != null) {
                          final GoogleSignInAuthentication googleSignInAuthentication =
                          await googleSignInAccount.authentication;
                          final AuthCredential authCredential = GoogleAuthProvider
                              .credential(
                              idToken: googleSignInAuthentication.idToken,
                              accessToken: googleSignInAuthentication.accessToken);

                          // Getting users credential
                          UserCredential result = await auth.signInWithCredential(
                              authCredential);
                          User? user = result.user;

                          var name = user!.displayName.toString();
                          var emailId = user.email.toString();
                          var photo = user.photoURL.toString();
                          var gid = user.uid.toString();

                          //firebase
                          //  ------------  firebase code for viewpage (2) --------------


                          SharedPreferences prefs = await SharedPreferences
                              .getInstance();
                          prefs.setString("Name", name);
                          prefs.setString("Email", emailId);
                          prefs.setString("Photo", photo);
                          prefs.setString("GoogleID", gid);


                          await FirebaseFirestore.instance.collection("GoogleAuth").where("Emailid",isEqualTo: emailId).get().then((documents) async{
                            if(documents.size<=0)
                              {
                                await FirebaseFirestore.instance.collection("GoogleAuth").add({
                                  "Name":name,
                                  "Emailid":emailId,
                                  "Photo":photo,
                                  "Gid":gid,
                                }).then((document) {
                                  prefs.setString("senderid", document.id.toString());
                                  print("record inserted ");
                                  displayName="";
                                  email="";
                                  photoURL="";
                                  uid="";
                                });
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => ViewPage())
                                );

                              }
                            else
                              {
                                prefs.setString("senderid", documents.docs.first.id.toString());
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => ViewPage())
                                );

                              }
                          });


                          //firebase

                          //-----------------shared preference in homepage (1) --------------

                          // SharedPreferences prefs = await SharedPreferences
                          //     .getInstance();
                          // prefs.setString("Name", name);
                          // prefs.setString("Email", emailid);
                          // prefs.setString("Photo", photo);
                          // prefs.setString("GoogleID", gid);


                          //--------------------print --------------

                          // print("Name  : "+name);
                          // print("Email  : "+emailid);
                          // print("Photo  : "+photo);
                          // print("Gid  : "+gid);
                        }
                      },
                        child: Container(
                            width: 300,
                            height: 100,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue,width: 3)
                            ),
                            child: Center(child: Text("Login With Google",style: TextStyle(fontSize: 25,color: Colors.blue.shade800),)))),
                 ),

            ),
          ],
        ),
      ),

    );
  }
}
