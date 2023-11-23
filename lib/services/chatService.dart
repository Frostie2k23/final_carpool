import 'package:car_pool/models/chatRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  String? chatRoomID;
  String? myID;
  String? recipientID;
  ChatService({this.chatRoomID, this.myID, this.recipientID});

  //chat collection reference
  final CollectionReference chat =
      FirebaseFirestore.instance.collection('chat');

  //chatRoom from snapshot
  ChatRoomModel _chatRoomFromSnapshot(DocumentSnapshot snapshot) {
    return ChatRoomModel(
      chatRoomID: chatRoomID,
      myID: (snapshot.data() as dynamic)[myID],
      recipientID: (snapshot.data() as dynamic)[recipientID],
    );
  }

  Stream<ChatRoomModel> get chatRoomDetails {
    return chat.doc(chatRoomID).snapshots().map(_chatRoomFromSnapshot);
  }
}
