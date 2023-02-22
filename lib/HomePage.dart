import 'package:chatapplication/Chatapp.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var name="";
  var emailid="";
  var photo="";
  var googleid="";
  getdata() async
  {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     setState((){
       name = prefs.getString("Name")!;
       emailid = prefs.getString("Email")!;
       photo = prefs.getString("Photo")!;
       googleid = prefs.getString("GoogleID")!;
     });
  }
  @override
  void initState() {
    // TODO: implement initstate
    super.initState();
    getdata();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("home page ' (1) display in mobile '"),
      ),
      body: Container(
        color: Colors.blue.shade100,
        child: Center(
          child:  Container(
            width: 320,
            height: 380,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue,width: 3)
            ),
            child: Column(
              children: [
                SizedBox(height: 40),
                Text(name,style: TextStyle(fontSize: 20),),
                SizedBox(height: 30),
                Text(emailid,style: TextStyle(fontSize: 20)),
                SizedBox(height: 30),
                Image.network(photo,width: 100),
                SizedBox(height: 30),
                Text(googleid,style: TextStyle(fontSize: 19)),
                SizedBox(height: 10,),
                ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.clear();
                      final GoogleSignIn googleSignIn = GoogleSignIn();
                      googleSignIn.signOut();
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Chatapp())
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text("Logout")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
