import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wether/models/temp.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:wether/models/temp.dart';
import 'package:wether/view/search_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var searchController = TextEditingController();
  String weather = "clear";
  String abbr = "c";
  String location = "cairo";
  int tempre = 0;
  var woeid = 0;

  latest() {
    setState(() {
      vv = searchController.text;
    });
  }

  String vv = "";

  Future<void> fitchCity(String input) async {
    var url = Uri.parse(
        "https://www.metaweather.com/api/location/search/?query=$input");
    var searchResult = await http.get(url);
    var resultBody = jsonDecode(searchResult.body)[0];

    setState(() {
      location = resultBody["title"];
      woeid = resultBody["woeid"];
    });
  }

  Future<void> fitchTemp() async {
    var url = Uri.parse("https://www.metaweather.com/api/location/$woeid/");
    var searchResult = await http.get(url);
    var resultBody = jsonDecode(searchResult.body)["consolidated_weather"][0];

    setState(() {
      abbr = resultBody["weather_state_abbr"];
      weather =
          resultBody["weather_state_name"].replaceAll(" ", "").toLowerCase();
      tempre = resultBody["the_temp"].round();
    });
  }

  Future<List<temp>> fitchTempList() async {
    List<temp> list = [];
    var url = Uri.parse("https://www.metaweather.com/api/location/$woeid/");
    var searchResult = await http.get(url);
    var resultBody = jsonDecode(searchResult.body)["consolidated_weather"];
    for (var i in resultBody) {
      temp x = temp(i["applicable_date"], i["max_temp"], i["min_temp"],
          i["weather_state_abbr"]);
      list.add(x);
    }
    return list;
  }

  Future<void> textFieldSupmitt() async {
    await fitchTemp();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/$weather.png"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * .05,
                  right: MediaQuery.of(context).size.width * .05,
                 ),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .06,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(7)),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      fitchCity(value);
                      fitchTempList();
                      fitchTemp();
                      print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk$vv");
                      vv = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Search is Empty";
                    }
                  },
                  cursorColor: Color(0xFF000000),
                  keyboardType: TextInputType.text,
                  controller: searchController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF000000).withOpacity(0.5),
                      ),
                      hintText: "Search",
                      border: InputBorder.none),
                ),
              ),
            ),
            FutureBuilder(
              future: fitchTempList(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Center(
                        child: Image.network(
                          "https://www.metaweather.com/static/img/weather/png/$abbr.png",
                          width: 100,
                        ),
                      ),
                      Text(
                        "${snapshot.data[0].min_temp.round()}°",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "$location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 55,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                } else {
                  return Center(
                      child: Text(
                    "Enter city name",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        color: Colors.white54),
                  ));
                }
              },
            ),
            Column(
              children: [

                Container(
                  height: MediaQuery.of(context).size.height * .22,
                  child: FutureBuilder(
                    future: fitchTempList(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * .22,
                                width: MediaQuery.of(context).size.height * .18,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${snapshot.data[index].applicable_date}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Image.network(
                                      "https://www.metaweather.com/static/img/weather/png/${snapshot.data[index].weather_state_abbr}.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    Text(
                                      "$location",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      "${snapshot.data[index].min_temp.round()}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      "${snapshot.data[index].max_temp.round()}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return Text("");
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
