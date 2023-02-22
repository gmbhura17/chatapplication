import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Chats extends StatefulWidget {

   String? txtname="";
   String? txtemail="";
   String? txtphoto="";
   String? receiverid="";
   Chats({this.txtname,this.txtemail,this.txtphoto,this.receiverid});
  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
   File? imagefile;
   ImagePicker _imagePicker = ImagePicker();

   bool isloading=false;
  var senderid="";
  getdata() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState((){
      senderid = prefs.getString("senderid").toString();
    });
  }


  @override
  void initState(){
    //TODO: implement initstate
    super.initState();
    getdata();
  }
  TextEditingController _msg = TextEditingController();
  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: [
            CircleAvatar(
              child:
                Image.network(widget.txtphoto!),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.txtname!,style: TextStyle(fontSize: 20),),
                  Text(widget.txtemail!,style: TextStyle(fontSize: 10),),
                ],
              ),
            ),
          ],
        ),

      ),
      body:  (senderid!="")?(isloading)?CircularProgressIndicator():Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("GoogleAuth").doc(senderid).collection("Chats")
                  .doc(widget.receiverid).collection("message").orderBy("timestamp",descending: true).snapshots(),
              builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                if(snapshot.hasData)
                  {
                    if(snapshot.data!.size<=0)
                      {
                        return Center(child: Text("No Chats!"),);
                      }
                    else
                      {
                        return ListView(
                          controller: _scrollController,
                          reverse: true,
                          children: snapshot.data!.docs.map((document){
                            if(document["senderid"]==senderid)
                              {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    margin: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10.0)
                                    ),
                                    child: (document["type"]=="image")?Image.network(document["message"],width: 100,):Text(document["message"].toString(),style: TextStyle(color: Colors.white),),
                                  ),
                                );
                              }
                            else
                              {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    margin: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                        color: Colors.red.shade700,
                                        borderRadius: BorderRadius.circular(10.0)
                                    ),
                                    child: (document["type"]=="image")?Image.network(document["message"],width: 100,):Text(document["message"].toString(),style: TextStyle(color: Colors.white),),
                                  ),
                                );
                              }
                          }).toList(),
                        );
                      }
                  }
                else
                  {
                    return Center(child: CircularProgressIndicator(),);
                  }
              }
            ),
          ),
          Container(
            margin: const EdgeInsets.all(2.0),
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35.0),
                      // boxShadow: const [
                      //   BoxShadow(
                      //       offset: Offset(0, 2),
                      //       blurRadius: 7,
                      //       color: Colors.blue)
                      // ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: (){
                            // setState(() {
                            //   emojiShowing = !emojiShowing;
                            // });
                          },
                          icon: Icon(Icons.emoji_emotions,size: 30,),
                        ),

                        Expanded(
                          child: TextField(
                            controller: _msg,
                            cursorColor: Colors.green,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: ()async{ XFile? photo = await _imagePicker.pickImage(source: ImageSource.gallery);
                                imagefile = File(photo!.path);
                                setState((){
                                  isloading=true;
                                });
                                var uuid = new Uuid();
                                String filename = uuid.v1().toString();
                                await FirebaseStorage.instance.ref(filename).putFile(imagefile!).whenComplete((){}).then((filedata) async{
                                  await filedata.ref.getDownloadURL().then((fileurl) async{
                                    await FirebaseFirestore.instance.collection("GoogleAuth")
                                        .doc(senderid).collection("Chats").doc(widget.receiverid)
                                        .collection("message").add({
                                      "message":fileurl,
                                      "senderid":senderid,
                                      "receiverid":widget.receiverid,
                                      "type":"image",
                                      "timestamp":DateTime.now().millisecondsSinceEpoch.toString()
                                    }).then((value) async{
                                      await FirebaseFirestore.instance.collection("GoogleAuth")
                                          .doc(widget.receiverid).collection("Chats").doc(senderid)
                                          .collection("message").add({
                                        "message":fileurl,
                                        "senderid":senderid,
                                        "receiverid":widget.receiverid,
                                        "type":"image",
                                        "timestamp":DateTime.now().millisecondsSinceEpoch.toString()
                                      }).then((value){
                                        setState((){
                                          isloading=false;
                                        });
                                      });
                                    });
                                  });
                                });

                                  },
                                icon: Icon(Icons.attach_file,size: 30,color: Colors.grey,),
                              ),
                              hintText: "Message",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0,left: 2.0),
                          child: GestureDetector(
                            child: Icon(Icons.camera_alt,size: 30,color: Colors.grey,),
                            onTap: () async{
                              XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
                              imagefile = File(photo!.path);
                              setState((){
                                isloading=true;
                              });
                              var uuid = new Uuid();
                              String filename = uuid.v1().toString();
                              await FirebaseStorage.instance.ref(filename).putFile(imagefile!).whenComplete((){}).then((filedata) async{
                                await filedata.ref.getDownloadURL().then((fileurl) async{
                                  await FirebaseFirestore.instance.collection("GoogleAuth")
                                      .doc(senderid).collection("Chats").doc(widget.receiverid)
                                      .collection("message").add({
                                    "message":fileurl,
                                    "senderid":senderid,
                                    "receiverid":widget.receiverid,
                                    "type":"image",
                                    "timestamp":DateTime.now().millisecondsSinceEpoch.toString()
                                  }).then((value) async{
                                    await FirebaseFirestore.instance.collection("GoogleAuth")
                                        .doc(widget.receiverid).collection("Chats").doc(senderid)
                                        .collection("message").add({
                                      "message":fileurl,
                                      "senderid":senderid,
                                      "receiverid":widget.receiverid,
                                      "type":"image",
                                      "timestamp":DateTime.now().millisecondsSinceEpoch.toString()
                                    }).then((value){
                                      setState((){
                                        isloading=false;
                                      });
                                    });
                                  });
                                });
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: GestureDetector(
                                onTap: (){},
                                child: Icon(Icons.currency_rupee_outlined,color: Colors.grey,),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // SizedBox(width: 15),
                GestureDetector(
                  onTap: () async{
                    _scrollController.animateTo(
                      0.0,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 300),
                    );
                    var msg = _msg.text.toString();
                    await FirebaseFirestore.instance.collection("GoogleAuth")
                        .doc(senderid).collection("Chats").doc(widget.receiverid)
                        .collection("message").add({
                      "message":msg,
                      "senderid":senderid,
                      "receiverid":widget.receiverid,
                      "type":"text",
                      "timestamp":DateTime.now().millisecondsSinceEpoch.toString()
                    }).then((value) async{
                      await FirebaseFirestore.instance.collection("GoogleAuth")
                          .doc(widget.receiverid).collection("Chats").doc(senderid)
                          .collection("message").add({
                        "message":msg,
                        "senderid":senderid,
                        "receiverid":widget.receiverid,
                        "type":"text",
                        "timestamp":DateTime.now().millisecondsSinceEpoch.toString()
                      }).then((value){
                        _msg.text="";
                      });
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: CircleAvatar(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Icon(Icons.send,color: Colors.white,size: 25.0,),
                      ),
                      backgroundColor: Colors.green,
                      radius: 25.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ):CircularProgressIndicator(),

    );
  }
}



// Container(
//             margin: const EdgeInsets.all(12.0),
//             height: 60,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(35.0),
//                       boxShadow: const [
//                         BoxShadow(
//                             offset: Offset(0, 2),
//                             blurRadius: 7,
//                             color: Colors.grey)
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         moodIcon(),
//                         const Expanded(
//                           child: TextField(
//                             decoration: InputDecoration(
//                                 hintText: "Message",
//                                 hintStyle: TextStyle(color: Color(0xFF00BFA5)),
//                                 border: InputBorder.none),
//                           ),
//                         ),
//                         attachFile(),
//                         camera(),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 15),
//                 Container(
//                   padding: const EdgeInsets.all(15.0),
//                   decoration: const BoxDecoration(
//                       color: Color(0xFF00BFA5), shape: BoxShape.circle),
//                   child: InkWell(
//                     child: voiceIcon(),
//                     onLongPress: () => callVoice(),
//                   ),
//                 )
//               ],
//             ),
//           )),