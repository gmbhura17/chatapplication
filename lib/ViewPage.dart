import 'package:chatapplication/Chatapp.dart';
import 'package:chatapplication/Chats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewPage extends StatefulWidget {

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {


  var name="";
  var email="";


  getdata() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   setState((){
     name = prefs.getString("Name").toString();
     email = prefs.getString("Email").toString();
     print("Emaillll : "+email);
   });
  }
  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      actions: [
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: GestureDetector(
            onTap: () async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              final GoogleSignIn googleSignIn = GoogleSignIn();
              googleSignIn.signOut();
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context)=>Chatapp())
              );
            },
            child: Icon(Icons.login_outlined,size: 35)
          ),
        )
      ],
      title: Text("Welcome,"+((name!="")?name:"Guest")),
    ),
    body: (email!="")?StreamBuilder(
      stream: FirebaseFirestore.instance.collection("GoogleAuth").where("Emailid",isNotEqualTo: email).snapshots(),
      builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
        if(snapshot.hasData)
          {
            if(snapshot.data!.size<=0)
              {
                return Center(
                  child: Text("No Google auth found"),
                );
              }
            else{
              return Container(
                color: Colors.lightBlueAccent,
                child: ListView(
                  children: snapshot.data!.docs.map((document){
                    return Container(
                      color: Colors.cyanAccent,
                      child: Card(
                        elevation: 10,
                        child: Container(
                          color: Colors.greenAccent,
                          child: ListTile(
                            onTap: (){
                             Navigator.of(context).push(
                               MaterialPageRoute(builder: (context)=> Chats(
                                   txtname: document["Name".toString()],
                                   txtemail: document["Emailid".toString()],
                                   txtphoto: document["Photo".toString()],
                                   receiverid: document.id.toString(),
                               ) ));
                            },
                            leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.account_circle,
                                  color: Colors.black,
                                ),
                              ),

                            trailing: Image.network(document["Photo"].toString()),
                            title: Text(document["Name"].toString(),style: TextStyle(fontSize: 20),),
                            subtitle: Column(
                              children: [
                                 Text(document["Emailid"].toString()),
                                // Text(document["Gid"].toString()),

                              ],
                            ),

                          ),

                        ),
                      ),

                    );
                  }).toList(),
                ),
              );
            }
          }
        else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      }
    ):CircularProgressIndicator(),
    );
  }
}
