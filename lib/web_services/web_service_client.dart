import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as Http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skoller/constants/BaseUtilities.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/constants/log.dart';

enum HttpMethod { HTTP_GET, HTTP_POST, HTTP_PUT }

enum RequestBodyType { TYPE_XX_URLENCODED_FORMDATA, TYPE_JSON, TYPE_MULTIPART }

enum TokenType {
  TYPE_BASIC,
  TYPE_BEARER,
  TYPE_NONE,
  TYPE_DEVICE_TOKEN,
}



enum WebError {
  INTERNAL_SERVER_ERROR,
  ALREADY_EXIST,
  UNAUTHORIZED,
  INVALID_JSON,
  NOT_FOUND,
  UNKNOWN,
  BAD_REQUEST,
  FORBIDDEN
}

///this class handles api calls
class WebServiceClient {
  static const BASE_URL = "https://api-staging.skoller.co/api/v1/";

  /// Get All Plans for payment
  static Future<dynamic> AllPlans() async {
    var url = BASE_URL + "stripe/all-plans";
    var response;
    await _hitService(url, HttpMethod.HTTP_GET, RequestBodyType.TYPE_JSON,
            TokenType.TYPE_BEARER)
        .then((value) {
      response = value;
    }).catchError((onError) {
      print(onError);
    });
    return response;
  }

  /// save card and create subscription
  static Future<dynamic> saveCarAndSub(Map<String, dynamic> params) async {
    var url = BASE_URL + "stripe/save-card-and-subscription";
    var response;
    await _hitService(url, HttpMethod.HTTP_POST, RequestBodyType.TYPE_JSON,
            TokenType.TYPE_BASIC,
            fieldMap: params)
        .then((value) => {response = value});
    return response;
  }

  static Future<dynamic> updateSub(Map<String, dynamic> params) async {
    var url = BASE_URL + "stripe/update-subscription";
    var response;
    await _hitService(url, HttpMethod.HTTP_POST, RequestBodyType.TYPE_JSON,
            TokenType.TYPE_BASIC,
            fieldMap: params)
        .then((value) => {response = value});
    return response;
  }

  /// get Subscriptions List
  static Future<dynamic> mySub() async {
    var url = 'https://api-staging.skoller.co/api/v1/' + "users/token-login";
    var response;
    await _hitService(url, HttpMethod.HTTP_POST, RequestBodyType.TYPE_JSON,
            TokenType.TYPE_BEARER)
        .then((value) {
      response = value;
    }).catchError((onError) {
      print(onError);
    });
    return response;
  }

  /// cancel Subscriptions List
  static Future<dynamic> cancelSub(Map<String, dynamic> params) async {
    var url = BASE_URL + "stripe/cancellation-reasons";
    var response;
    await _hitService(url, HttpMethod.HTTP_POST, RequestBodyType.TYPE_JSON,
            TokenType.TYPE_BEARER,
            fieldMap: params, isCancelSubscription: true)
        .then((value) {
      response = value;
    }).catchError((onError) {
      print(onError);
    });
    return response;
  }

  ///this method will actually hit the service based on method(GET,PUT,POST
  static Future<dynamic> _hitService(
      String url, HttpMethod method, RequestBodyType type, TokenType tokenType,
      {Map<String, dynamic>? fieldMap,
      Map<String, File>? files,
      bool isCancelSubscription = false}) async {
    if (await Utilities.checkInternet()) {
      var response;
      var headerMap = Map<String, String>();
      if (tokenType == TokenType.TYPE_BASIC) {
        var sp = await SharedPreferences.getInstance();
        var token = sp.getString(PreferencesKeys.kSharedToken);
        Log.d("$token");
        // var deviceToken = sp.getString(DEVICE_TOKEN);

        // headerMap['fcm_token'] = deviceToken;
        // headerMap['device_type'] = Platform.isIOS?"ios":"android";
        headerMap["Authorization"] = "Bearer $token";
      } else {
        var sp = await SharedPreferences.getInstance();
        var token = await sp.get(PreferencesKeys.kSharedToken);
        /* var deviceToken = await sp.getString(DEVICE_TOKEN);
        headerMap['fcm_token'] = deviceToken;
        headerMap['device_type'] = Platform.isIOS?"ios":"android";*/
        headerMap["Authorization"] = "Bearer $token";
      }
      switch (method) {
        case HttpMethod.HTTP_GET:
          {
            Log.d("Sending Request:: GET $url headers $headerMap");
            response = await Http.get(Uri.parse(url), headers: headerMap);
          }
          break;
        case HttpMethod.HTTP_POST:
          {
            if (type == RequestBodyType.TYPE_XX_URLENCODED_FORMDATA) {
              headerMap["Content-Type"] = "application/x-www-form-urlencoded";
              Log.d("Sending Request:: POST $url body $fieldMap");
              response = await Http.post(Uri.parse(url),
                  headers: headerMap,
                  body: fieldMap,
                  encoding: convert.Utf8Codec());
            } else if (type == RequestBodyType.TYPE_MULTIPART) {
              headerMap["Content-Type"] = "multipart/form-data";
              var request = Http.MultipartRequest("POST", Uri.parse(url));
              if (fieldMap != null) {
                Map<String, String> map = fieldMap.cast<String, String>();
                request.fields.addAll(map);
              }
              print("file null or not >>>>>> $files");
              if (files != null && files.isNotEmpty) {
                files.forEach((key, file) async {
                  Http.MultipartFile multipartFile =
                      await Http.MultipartFile.fromPath(key, file.path,
                          contentType: file.path.endsWith("*.png")
                              ? MediaType('image', 'x-png')
                              : MediaType('image', 'jpeg'));
                  debugPrint(
                      "file is ${multipartFile.contentType} ${multipartFile.filename} ${multipartFile.length}");
                  request.files.add(multipartFile);
                });
              }
              request.headers.addAll(headerMap);
              response = await request.send();
            } else {
              if (!isCancelSubscription)
                headerMap["Content-Type"] = "application/json";
              var json;
              if (!isCancelSubscription)
                json = convert.jsonEncode(fieldMap);
              else
                json = fieldMap;

              Log.d("Sending Request:: POST $url body $json");
              response = await Http.post(Uri.parse(url),
                  headers: headerMap, body: json);
              print(response.body);
            }
          }
          break;
        case HttpMethod.HTTP_PUT:
          if (type == RequestBodyType.TYPE_XX_URLENCODED_FORMDATA) {
            headerMap["Content-Type"] = "application/x-www-form-urlencoded";
            Log.d("Sending Request:: PUT $url body $fieldMap");
            response = await Http.put(Uri.parse(url),
                headers: headerMap,
                body: fieldMap,
                encoding: convert.Utf8Codec());
          } else if (type == RequestBodyType.TYPE_MULTIPART) {
            headerMap["Content-Type"] = "multipart/form-data";
            var request = await Http.MultipartRequest("PUT", Uri.parse(url));
            Map<String, String> map = fieldMap!.cast<String, String>();
            request.fields.addAll(map);
            if (files != null && files.isNotEmpty) {
              files.forEach((key, file) async {
                Http.MultipartFile multipartFile =
                    await Http.MultipartFile.fromPath(
                  key,
                  file.path,
                );
                request.files.add(multipartFile);
              });
            }
            request.headers.addAll(headerMap);
            response = await request.send();
          } else {
            headerMap["Content-Type"] = "application/json";
            var json = convert.jsonEncode(fieldMap);
            Log.d("Sending Request:: PUT $url body $json");
            response =
                await Http.put(Uri.parse(url), headers: headerMap, body: json);
          }
          break;
      }
      var statusCode = response.statusCode;
      Log.d("Response Code  :: $statusCode");
      //Log.d("Response  :: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (type == RequestBodyType.TYPE_MULTIPART) {
          var res = await Http.Response.fromStream(response);
          Log.d("Response is :: " + res.body);
          return res.body;
        } else
          Log.d("Response is :: " + response.body);
        return response.body;
      } else {
        switch (response.statusCode) {
          case 400:
            return WebError.BAD_REQUEST;
            break;
          case 403:
            return WebError.BAD_REQUEST;
            break;
          case 500:
            return WebError.INTERNAL_SERVER_ERROR;
            break;
          case 404:
            return WebError.NOT_FOUND;
            break;
          case 401:
            return WebError.UNAUTHORIZED;
            break;
          case 409:
            return WebError.ALREADY_EXIST;
            break;
          default:
            return WebError.UNKNOWN;
            break;
        }
      }
    } else {
      return WebError.INTERNAL_SERVER_ERROR;
    }
  }
}
