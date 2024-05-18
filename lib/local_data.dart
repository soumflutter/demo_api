import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class LocalDatabase {
  Future<Response> createUser(Request request) async {
    try {
      var box = await Hive.openBox("User_Box");
      String body = await request.readAsString();
      List allUser = await box.get("User") ?? [];

      allUser.add(jsonDecode(body));
      box.put("User", allUser);

      return Response.ok(jsonEncode(body),
          headers: {HttpHeaders.contentTypeHeader: "application/json"});
    } catch (e) {
      return Response.internalServerError(
        body: e.toString(),
        headers: {HttpHeaders.contentTypeHeader: "application/json"},
      );
    }
  }

  Future<Response> getUsers(Request request) async {
    var box = await Hive.openBox("User_Box");
    List allUser = await box.get("User") ?? [];

    return Response.ok(
        jsonEncode({
          "Users": allUser,
        }),
        headers: {HttpHeaders.contentTypeHeader: "application/json"});
  }

  Future<Response> getSpecificUser(Request request) async {
    try {
      var box = await Hive.openBox("User_Box");
      var getId = request.params["id"];
      Map getUserData = {};
      List allUser = await box.get("User") ?? [];

      for (int i = 0; i < allUser.length; i++) {
        String userId = allUser[i]["id"].toString();

        if (getId == userId) {
          getUserData = allUser[i];
          break;
        } else {
          getUserData = {
            "status": 404,
            "message": "user not found",
          };
        }
      }
      return Response.ok(jsonEncode(getUserData),
          headers: {HttpHeaders.contentTypeHeader: "application/json"});
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  }

  Future<Response> deleteUser(Request request) async {
    try {
      var box = await Hive.openBox("User_Box");
      var getId = request.params["id"];
      List allUsers = await box.get("User");
      Map message = {};

      for (int i = 0; i < allUsers.length; i++) {
        String userId = allUsers[i]["id"].toString();

        if (getId == userId) {
          allUsers.removeAt(i);
          message = {
            "status": 200,
            "message": "user deleted",
          };
        } else {
          message = {
            "status": 404,
            "message": "user not found",
          };
        }
      }
      await box.put("User", allUsers);
      return Response.ok(jsonEncode(message),
          headers: {HttpHeaders.contentTypeHeader: "application/json"});
    } catch (e) {
      return Response.internalServerError(
          body: e.toString(),
          headers: {HttpHeaders.contentTypeHeader: "application/json"});
    }
  }

  Future<Response> editUserName(Request request) async {
    try {
      var box = await Hive.openBox("User_Box");
      var getId = request.params["id"];
      var userName = request.params["name"];
      List allUsers = await box.get("User") ?? [];
      Map message = {};

      for (int i = 0; i < allUsers.length; i++) {
        String userId = allUsers[i]["id"].toString();

        if (getId == userId) {
          allUsers[i]["name"] = userName;
          message = {"status": 200, "message": "user edited"};
          break;
        } else {
          message = {"status": 404, "message": "user not found"};
        }
      }

      await box.put("User", allUsers);
      return Response.ok(jsonEncode(message));
    } catch (e) {
      return Response.internalServerError(
        body: e.toString(),
        headers: {HttpHeaders.contentTypeHeader: "application/json"},
      );
    }
  }
}
