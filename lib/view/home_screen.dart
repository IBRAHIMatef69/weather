import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:wether/models/temp.dart';
import 'package:wether/view/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String weather = "clear";
  String abbr = "c";
  String location = "cairo";
  int tempre = 0;
  var woeid = 0;


  Future<void> fitchPositionCity() async {
    final position = await Geolocator.getCurrentPosition();
    var pLat = position.latitude;
    var pLong = position.longitude;
    var url = Uri.parse(
        "https://www.metaweather.com/api/location/search/?lattlong=$pLat,$pLong");
    var searchResult = await http.get(url);
    var resultBody = jsonDecode(searchResult.body)[0];

    setState(() {
      location = resultBody["title"];
      woeid = resultBody["woeid"];
    });
    print("dfffffffffffffffffffffffffffffffffff$pLong");
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
    await fitchPositionCity();
    await fitchTemp();
  }

  late Position locationMesssage;

  Future getPosition() async {
    LocationPermission per;
    //هنا بوليان علشان نعرف التطبيق اليوزر مديله صلاحيات الموقع وال لا
    bool services;
    //هنا بنعمل بوليان نعرف بيه  الابلكيشن واخد واصل  للموقع ولا لاء

    services = await Geolocator.isLocationServiceEnabled();


    per = await Geolocator.checkPermission();
    //هنا بنتشيك ع البيرميشن
    if (per == LocationPermission.denied) {
//هنا لو مفيش بيرميشن نتا بتديله البيرميشن
      per = await Geolocator.requestPermission();
    }

    if (per == LocationPermission.always) {}
    getLAtAndLand();
    locationMesssage = await getLAtAndLand();

    print("========================$per");
  }

  Future<Position> getLAtAndLand() async {
    return await Geolocator.getCurrentPosition().then((value) => value);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPosition();

    getLAtAndLand();
    fitchPositionCity();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/$weather.png"), fit: BoxFit.cover)),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            title: Text(
              "Weather",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,fontStyle: FontStyle.italic),
            ),
            actions: [IconButton(onPressed: () { Navigator.push(context,
                MaterialPageRoute(builder: (context) => SearchScreen()));}, icon: Icon(Icons.search))],
          ),
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureBuilder(
                future: fitchTempList(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                            fontSize: 60,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "$location",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  } else {
                    return Center(
                        child: CircularProgressIndicator(
                      color: Colors.white70,
                    ));
                  }
                },
              ),
              Column(
                children: [
                  // Container(
                  //   width: MediaQuery.of(context).size.width * .9,
                  //   child: TextField(
                  //     onSubmitted: (String input) {
                  //       textFieldSupmitt(input);
                  //     },
                  //     style: TextStyle(color: Colors.white, fontSize: 24),
                  //     decoration: InputDecoration(
                  //         hintText: "Search",
                  //         hintStyle:
                  //             TextStyle(color: Colors.white70, fontSize: 18),
                  //         prefixIcon: Icon(
                  //           Icons.search,
                  //           color: Colors.white70,
                  //           size: 30,
                  //         )),
                  //   ),
                  // ),
                  Container(
                    height: MediaQuery.of(context).size.height * .25,
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
                                  width:
                                      MediaQuery.of(context).size.height * .18,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
      ),
    );
  }
}
