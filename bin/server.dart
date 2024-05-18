import 'dart:convert';
import 'dart:io';

import 'package:demo_api/local_data.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:hive/hive.dart';

void main() async {
  Hive.init("/home/soumshahid/Flutter Projects/demo_api/local_data");
  var state = LocalDatabase();
  ////////////////////////////////////// Start Routes ////////////////////////////////////
  final app = Router()
    ..get("/", (Request req) {
      return Response.ok("Welcome",
          headers: {HttpHeaders.contentTypeHeader: "application/json"});
    })
    ..get("/intro", (Request request) {
      return Response.ok(jsonEncode(
          {"Intoduction": "My name is Soum Shahid. I am flutter developer"}));
    })
    ..get("/api/", (Request req) {
      return Response.ok(
          jsonEncode({
            "status": 200,
            "message": "Welcome to Dart API",
            "creator": "Soum Shahid",
          }),
          headers: {HttpHeaders.contentTypeHeader: "application/json"});
    })
    ..get("/api", (Request req) {
      return Response.ok(
          jsonEncode({
            "status": 200,
            "message": "Welcome to Dart API",
            "creator": "Soum Shahid",
          }),
          headers: {HttpHeaders.contentTypeHeader: "application/json"});
    })
    ..get("/api/users", state.getUsers)
    ..post("/api/users", state.createUser)
    ..get("/api/users/<id>", state.getSpecificUser)
    ..delete("/api/users/delete/<id>", state.deleteUser)
    ..post("/api/users/edit/<id>/<name>", state.editUserName);

  ////////////////////////////////////// End Routes ////////////////////////////////////
  final ip = InternetAddress.anyIPv4;

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app.call);

  final port = int.parse(Platform.environment['PORT'] ?? '5000');

  final server = await serve(handler, ip, port, poweredByHeader: "Soum Shahid");
  print('Server Turn on PORT == ${server.port}');
}
