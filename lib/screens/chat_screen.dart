import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;
class ChatScreen extends StatefulWidget {
  static String id = 'chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController _textEditingController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool isSendEnabled;

  bool isEmpty(){
    setState(() {
          if((_textEditingController.text!=" ")&&(_textEditingController!=null)){
            isSendEnabled=true;
          }
          else{
                        isSendEnabled=false;

          }
        });
       return isSendEnabled; 
  }
  
  String messageText;

  @override
  void initState() {
    super.initState();

    
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {}
      loggedInUser = user;
      print(loggedInUser.email);
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {

              }),
        ],
        title: Text('Let\'s Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
           MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      onSubmitted: null,
                      onChanged: (value) {
                        isEmpty();
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _textEditingController.clear();
                      _fireStore.collection('messages').add({
                         'timestamp': Timestamp.now(),
                        'Sender': loggedInUser.email,
                        'Text': messageText, 
                      });
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
              stream: _fireStore.collection('messages').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlue,
                    ),
                  );
                }
                final messages = snapshot.data.documents.reversed;
                List<MessageBubble> messageWidgets = [];
                for (var message in messages) {
                  final messageText = message.data['Text'];
                  final messageSender = message.data['Sender'];

                  final currentUser = loggedInUser.email;

                  if(currentUser == messageSender) {
                    // User sent message
                  }

                  final messageWidget =
                      MessageBubble(sender: messageSender, 
                      text: messageText,
                      isMe: currentUser == messageSender,
                      );
                  messageWidgets.add(messageWidget);

                }
                return Expanded(
                    child: ListView(
                      reverse: true, 
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    children: messageWidgets,
                  ),
                );
              },
            );
  }
}


class MessageBubble extends StatelessWidget {

MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(sender, style: TextStyle(color: Colors.black54, fontSize: 12),),
          Material(
            borderRadius: isMe? BorderRadius.only(topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30) ):
            BorderRadius.only(topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30) ) ,
            elevation: 5.0,
            color: isMe? Colors.lightBlue: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  child: Text('$text', 
            style: TextStyle(fontSize: 15,
            color: isMe? Colors.white: Colors.black54),
            ),
                ),
          ),
        ],
      ),
    );

  }
}