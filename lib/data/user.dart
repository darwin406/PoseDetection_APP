import 'package:firebase_database/firebase_database.dart';

class Userinfor {
  String id;
  String pw;
  String createTime;

  Userinfor(this.id, this.pw, this.createTime);

  Userinfor.fromSnapshot(DataSnapshot snapshot)
      :
        id = (snapshot.value! as Map)['id'],
        pw = (snapshot.value! as Map)['pw'],
        createTime = (snapshot.value! as Map)['createTime'];

  toJson() {
    return {
      'id': id,
      'pw': pw,
      'createTime': createTime,
    };
  }
}
