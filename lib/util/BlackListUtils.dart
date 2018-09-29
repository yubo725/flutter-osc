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

  // 字符串转化为整型数组
  static List<int> _str2intList(String str) {
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
    return null;
  }

  // 整型数组转化为字符串
  static String _intList2Str(List<int> list) {
    if (list == null || list.isEmpty) {
      return null;
    }
    StringBuffer sb = new StringBuffer();
    for (int id in list) {
      sb.write("$id,");
    }
    String result = sb.toString();
    return result.substring(0, result.length - 1);
  }

  // 保存黑名单的id
  static Future<String> saveBlackListIds(List<int> list) async {
    String str = _intList2Str(list);
    if (str != null) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString(SP_BLACK_LIST, str);
    } else {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString(SP_BLACK_LIST, "");
    }
    return str;
  }

  // 获取本地保存的黑名单id数据
  static Future<List<int>> getBlackListIds() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String str = sp.getString(SP_BLACK_LIST);
    if (str != null && str.length > 0) {
      return _str2intList(str);
    }
    return null;
  }

  // 向黑名单中添加一个id
  static Future<List<int>> addBlackId(int id) async {
    List<int> list = await getBlackListIds();
    if (list != null && list.isNotEmpty) {
      if (!list.contains(id)) {
        list.add(id);
        String str = await saveBlackListIds(list);
        return _str2intList(str);
      } else {
        return list;
      }
    } else {
      List<int> l = new List();
      l.add(id);
      String str = await saveBlackListIds(l);
      return _str2intList(str);
    }
  }

  // 向黑名单中移除一个id
  static Future<List<int>> removeBlackId(int id) async {
    List<int> list = await getBlackListIds();
    if (list != null && list.isNotEmpty) {
      if (list.contains(id)) {
        list.remove(id);
        String str = await saveBlackListIds(list);
        return _str2intList(str);
      }
    }
    return list;
  }

}