import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import "package:dart_openai/openai.dart";

get_response(String text) async{
  var url = Uri.http("api.wolframalpha.com","/v1/result",{"appid":"UGA9LG-VXJQTGPT2X","i":"${text}"});
  var response= await http.post(url);
  if ((response.statusCode==501) | (response.statusCode==400)){
    print(response.body);
    Fluttertoast.showToast(msg: "something went wrong",backgroundColor: Colors.red,timeInSecForIosWeb: 3);
    return "error";
  }
  var jsonresponse= response.body;
  String finalResponses = jsonresponse;
  return finalResponses;


}

