import 'dart:convert';

import 'package:flutter/material.dart';

import 'main.dart';
import 'package:intl/intl.dart';

// Memo 데이터의 형식을 정해줍니다. 추후 isPinned, updatedAt 등의 정보도 저장할 수 있습니다.
class Memo {
  Memo({
    required this.content,
    required this.edtdt,
    required this.isCheck,
  });

  String content;
  String edtdt;
  bool isCheck;

  Map toJson() {
    //return {'content': content};
    return {'content': content, 'edtdt': edtdt, 'isCheck': isCheck};
  }

  factory Memo.fromJson(json) {
    //return Memo(content: json['content']);
    return Memo(
        content: json['content'],
        edtdt: json['edtdt'],
        isCheck: json['isCheck']);
  }
}

// Memo 데이터는 모두 여기서 관리
class MemoService extends ChangeNotifier {
  MemoService() {
    loadMemoList();
  }

  List<Memo> memoList = [
    Memo(
      content: '장보기 목록: 사과, 양파',
      edtdt: DateFormat('yy/MM/dd HH:mm:ss').format(DateTime.now()),
      isCheck: false,
    ), // 더미(dummy) 데이터
    Memo(
      content: '새 메모',
      edtdt: DateFormat('yy/MM/dd HH:mm:ss').format(DateTime.now()),
      isCheck: false,
    ), // 더미(dummy) 데이터
  ];

  createMemo({required String content}) {
    Memo memo = Memo(
      content: content,
      edtdt: DateFormat('yy/MM/dd HH:mm:ss').format(DateTime.now()),
      isCheck: false,
    );
    memoList.add(memo);
    notifyListeners(); // Consumer<MemoService>의 builder 부분을 호출해서 화면 새로고침
    saveMemoList();
  }

  updateMemo({required int index, required String content}) {
    Memo memo = memoList[index];
    memo.content = content;
    memo.edtdt = DateFormat('yy/MM/dd - HH:mm:ss').format(DateTime.now());
    notifyListeners();
    saveMemoList();
  }

  deleteMemo({required int index}) {
    memoList.removeAt(index);
    notifyListeners();
    saveMemoList();
  }

  checkMemo({required int index, required bool isCheck}) {
    Memo memo = memoList[index];
    memo.isCheck = isCheck;

    memoList.sort(
      (a, b) {
        if (a.isCheck) {
          if (b.isCheck)
            return 0;
          else
            return -1;
        } else {
          if (b.isCheck)
            return 1;
          else
            return 0;
        }
      },
    );

    notifyListeners();
    saveMemoList();
  }

  saveMemoList() {
    List memoJsonList = memoList.map((memo) => memo.toJson()).toList();
    // [{"content": "1"}, {"content": "2"}]

    String jsonString = jsonEncode(memoJsonList);
    // '[{"content": "1"}, {"content": "2"}]'

    prefs.setString('memoList', jsonString);
  }

  loadMemoList() {
    String? jsonString = prefs.getString('memoList');
    // '[{"content": "1"}, {"content": "2"}]'

    if (jsonString == null) return; // null 이면 로드하지 않음

    List memoJsonList = jsonDecode(jsonString);
    // [{"content": "1"}, {"content": "2"}]

    memoList = memoJsonList.map((json) => Memo.fromJson(json)).toList();
  }
}
