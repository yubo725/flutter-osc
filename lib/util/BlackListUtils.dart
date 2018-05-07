import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// 黑名单工具类，用于在本地操作黑名单
class BlackListUtils {

  static final String SP_BLACK_LIST = "blackList";

  // 将对象数组转化为整型数组
  static List<int> convert(List objList) {
    if (objList == null || objList.isEmpty) {
      return new List<int>();
    }
    List<int> intList = new List();
    for (var obj in objList) {
      intList.add(obj['authorid']);
    }
    return intList;
  }

  // 保存黑名单的id
  static void saveBlackListIds(List<int> list) async {
    if (list != null && list.isNotEmpty) {
      StringBuffer sb = new StringBuffer();
      for (int id in list) {
        sb.write("$id,");
      }
      String result = sb.toString();
      result = result.substring(0, result.length - 1);
      // 保存到本地
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString(SP_BLACK_LIST, result);
    }
  }

  // 获取本地保存的黑名单id数据
  static Future<List<int>> getBlackListIds() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String str = sp.getString(SP_BLACK_LIST);
    if (str != null && str.length > 0) {
      List<String> list = str.split(",");
      if (list != null && list.isNotEmpty) {
        List<int> intList = new List();
        for (String s in list) {
          intList.add(int.parse(s));
        }
        return intList;
      }
    }
    return new List<int>();
  }

  // 向黑名单中添加一个id
  static Future<Null> addBlackId(int id) async {
    getBlackListIds().then((list) {
      if (list != null && list.isNotEmpty) {
        if (!list.contains(id)) {
          list.add(id);
          saveBlackListIds(list);
        }
      } else {
        List<int> l = new List();
        saveBlackListIds(l);
      }
    });
  }

  // 向黑名单中移除一个id
  static Future<Null> removeBlackId(int id) async {
    getBlackListIds().then((list) {
      if (list != null && list.isNotEmpty && list.contains(id)) {
        list.remove(id);
        saveBlackListIds(list);
      }
    });
  }

}