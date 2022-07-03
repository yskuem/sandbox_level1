
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sandbox_level1/Firebase/firestore_repository.dart';
import 'package:sandbox_level1/model/account.dart';
import 'package:sandbox_level1/model/message.dart';
part 'chat_page_controller.freezed.dart';
@freezed
class ChatPageState with _$ChatPageState{
  factory ChatPageState({
    @Default([]) List<Message> messageList,
    required TextEditingController newMessageController,
    String? chatRoomId,
		// 初期値
  }) = _ChatPageState;
}



class ChatPageController extends StateNotifier<ChatPageState>{
  ChatPageController(ChatPageState state) : super(state);
  final fireStoreRepo = FirestoreRepository();
  final _fireStoreInstance = FirebaseFirestore.instance;

  Future<void>getTalkRoomInfo(Account _otherAccount)async{
    final id = await fireStoreRepo.getTalkRoomID(_otherAccount);//id取得
    state = state.copyWith(chatRoomId: id);
    if(id == null)return;//talkroomが存在しない時
    await fetchMessageList(id);//メッセージ取得
  }
  Future<void> fetchMessageList(String id)async{//idをもとにメッセージをとってくる
    final Stream<QuerySnapshot>_messageStream = _fireStoreInstance.collection("talk_room").doc(id).collection("message").orderBy("sendTime",descending: true).snapshots();
    print("取得");
    _messageStream.listen((QuerySnapshot snapshot) {
      final List<Message> messageList = snapshot.docs.map((DocumentSnapshot document){
        Map<String,dynamic> data = document.data() as Map<String,dynamic>;
        Message _message = Message.fromJson(data);
        return _message;
      }).toList();
      state = state.copyWith(messageList: messageList);
    });
  }

  Future<void>createChatRoom(Account myAccount,Account otherAccount)async {
    final id = await fireStoreRepo.createTalkRoom(myAccount, otherAccount);
    state = state.copyWith(chatRoomId: id);
  }
  Future<void>addMessage(Account myAccount)async{
    final newMessage = await fireStoreRepo.addMessage(state.chatRoomId!, state.newMessageController.text, myAccount);
    //final List<Message> updateMessageList = [newMessage,...state.messageList];
    //state = state.copyWith(messageList: updateMessageList);
  }
  void clearAddMessageFiled(){
    state.newMessageController.clear();
  }
}