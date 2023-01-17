import 'dart:convert';

import 'package:http/http.dart' as http;

class Req {
  static Future<void> get(String url, Function callback,
      {Map<String, dynamic> params,
      Map<String, String> headers,
      Function errorCallback}) async {
    if (params != null && params.isNotEmpty) {
      StringBuffer sb = new StringBuffer('?');
      params.forEach((key, value) {
        sb.write('$key' + '=' + '$value' + '&');
      });
      String paramStr = sb.toString();
      paramStr = paramStr.substring(0, paramStr.length - 1);
      url += paramStr;
    }
    try {
      http.Response res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        if (callback != null) callback(res.body);
      } else {
        print('$url >> StatusCode: ${res.statusCode} >>Body: ${res.body}');
      }
    } catch (exception) {
      if (errorCallback != null) {
        errorCallback(exception);
      }
    }
  }

  static Future<String> get2(String url,
      {Map<String, dynamic> params, Map<String, String> headers}) async {
    if (params != null && params.isNotEmpty) {
      StringBuffer sb = new StringBuffer('?');
      params.forEach((key, value) {
        sb.write('$key' + '=' + '$value' + '&');
      });
      String paramStr = sb.toString();
      paramStr = paramStr.substring(0, paramStr.length - 1);
      url += paramStr;
    }
    try {
      http.Response res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        return res.body;
      } else {
        print('$url >> StatusCode: ${res.statusCode}');
        return null;
      }
    } catch (exception) {
      print(exception.toString());
      return null;
    }
  }

  static Future<String> post(String url,
      {Map<String, dynamic> params, Map<String, String> headers}) async {
    try {
      http.Response res = await http.post(url,
          body: jsonEncode(params), headers: headers, encoding: Utf8Codec());
      if (res.statusCode == 200) {
        return res.body;
      } else {
        print('$url >> StatusCode: ${res.statusCode}');
        return null;
      }
    } catch (exception) {
      print(exception.toString());
      return null;
    }
  }

  static Future<String> post2(String url,
      {String params, Map<String, String> headers}) async {
    try {
      http.Response res = await http.post(url,
          body: params, headers: headers, encoding: Utf8Codec());
      if (res.statusCode == 200) {
        return res.body;
      } else {
        print('$url >> StatusCode: ${res.statusCode}');
        return null;
      }
    } catch (exception) {
      print(exception.toString());
      return null;
    }
  }
}
