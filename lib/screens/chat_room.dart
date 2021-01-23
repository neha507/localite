import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localite/services/shared_pref.dart';
import 'package:localite/widgets/toast.dart';

import '../constants.dart';

final _firestore = FirebaseFirestore.instance;
User loggedUser;

class ChatRoom extends StatefulWidget {
  final String roomId;
  final messageReceiverUID;

  ChatRoom({this.roomId, this.messageReceiverUID});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  String message;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedUser = user;
        print(user.email);
        MyToast().getToastBottom(user.email.toString());
      } else {
        MyToast().getToastBottom('failed!');
      }
    } catch (e) {
      MyToast().getToastBottom(e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe3f2fd),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ChatStream(id: widget.roomId),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        message = value;
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: kMessageTextFieldDecoration.copyWith(
                        hintStyle: TextStyle(color: Colors.grey),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  FlatButton(
                    height: 48,
                    onPressed: () {
                      //Implement send functionality.
                      messageTextController.clear();
                      if (message != null) {
                        // var a = Random().nextInt(3).toString();
                        _firestore
                            .collection('chatRoom')
                            .doc(widget.roomId)
                            .collection('chat')
                            .add({
                          'text': message,
                          'sender': loggedUser.email,
                          'timestamp': Timestamp.now(),
                        });

                        message = null;

                        addUIDs(widget.messageReceiverUID);
                      }
                    },
                    color: Colors.white,
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

class ChatStream extends StatelessWidget {
  final String id;
  ChatStream({this.id});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chatRoom')
          .doc(id)
          .collection('chat')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data.docs.reversed;
          List<MessageBubble> msgBubbles = [];

          for (var message in messages) {
            final currentUser = loggedUser.email;
            final sender = message.data()['sender'];
            final bubble = MessageBubble(
              text: message.data()['text'],
              sender: sender,
              isMe: sender == currentUser,
              timestamp: message.data()['timestamp'],
            );

            msgBubbles.add(bubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15),
              children: msgBubbles,
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;
  final Timestamp timestamp;

  MessageBubble({this.text, this.sender, this.isMe, this.timestamp});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          SizedBox(
            height: 2,
          ),
          Material(
            color: isMe ? Colors.lightBlueAccent[200] : Colors.white,
            elevation: 4.0,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
              topRight: isMe ? Radius.circular(7) : Radius.circular(30),
              topLeft: isMe ? Radius.circular(30) : Radius.circular(7),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Text(timestamp.toDate().hour.toString() +
              ':' +
              timestamp.toDate().minute.toString()),
        ],
      ),
    );
  }
}

void addUIDs(String messageReceiverUID) {
  bool isServiceProvider = SharedPrefs.preferences.getBool('isServiceProvider');

  if (isServiceProvider == true) {
    var docRefUser = _firestore
        .collection('Service Providers')
        .doc(loggedUser.uid)
        .collection('listOfChats')
        .doc(messageReceiverUID);

    docRefUser.get().then((value) {
      if (value.exists) {
        docRefUser.update({'lastMsg': Timestamp.now()});
      } else {
        docRefUser.set({'uid': messageReceiverUID, 'lastMsg': Timestamp.now()});
      }
    });

    var docRefSP = _firestore
        .collection('Users')
        .doc(messageReceiverUID)
        .collection('listOfChats')
        .doc(loggedUser.uid);

    docRefSP.get().then((value) {
      if (value.exists) {
        docRefSP.update({'lastMsg': Timestamp.now()});
      } else {
        docRefSP.set({'uid': loggedUser.uid, 'lastMsg': Timestamp.now()});
      }
    });
  } else {
    var docRefUser = _firestore
        .collection('Users')
        .doc(loggedUser.uid)
        .collection('listOfChats')
        .doc(messageReceiverUID);

    docRefUser.get().then((value) {
      if (value.exists) {
        docRefUser.update({'lastMsg': Timestamp.now()});
      } else {
        docRefUser.set({'uid': messageReceiverUID, 'lastMsg': Timestamp.now()});
      }
    });

    var docRefSP = _firestore
        .collection('Service Providers')
        .doc(messageReceiverUID)
        .collection('listOfChats')
        .doc(loggedUser.uid);

    docRefSP.get().then((value) {
      if (value.exists) {
        docRefSP.update({'lastMsg': Timestamp.now()});
      } else {
        docRefSP.set({'uid': loggedUser.uid, 'lastMsg': Timestamp.now()});
      }
    });
  }
}
