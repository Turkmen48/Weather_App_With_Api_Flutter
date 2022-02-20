import 'dart:convert';

import 'package:aesthetic_dialogs/aesthetic_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController myController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: myController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    hintText: "Şehir seçiniz",
                  ),
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  var response = await http.get(Uri.parse(
                      "https://www.metaweather.com/api/location/search/?query=${myController.text}"));

                  jsonDecode(response.body).isEmpty
                      ? AestheticDialogs.showDialog(
                          title: "Hata",
                          message: "Girdiğiniz Şehir Bulunamadı",
                          cancelable: true,
                          darkMode: true,
                          dialogType: DialogType.ERROR,
                          dialogStyle: DialogStyle.EMOJI,
                          dialogGravity: DialogGravity.CENTER,
                          dialogAnimation: DialogAnimation.IN_OUT)
                      : Navigator.pop(context, myController.text);
                  print(myController.text);
                },
                child: Text(
                  "Şehri Seç",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent)),
              )
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/search.jpg"),
        ),
      ),
    );
  }
}
