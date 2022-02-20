import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu/daily_weather_cards.dart';
import 'package:hava_durumu/searchpage.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = "Ankara";
  var sicaklik;
  var locationData;
  var woeid;
  var weatherAbbr = "c";
  Position? position;
  List temps = List.filled(5, 22);
  List images = List.filled(5, "c");
  List dates = List.filled(5, "d");
  List gunler = [
    "Pazartesi",
    "Salı",
    "Çarşamba",
    "Perşembe",
    "Cuma",
    "Cumartesi",
    "Pazar"
  ];
  Future<void> getDevicePosition() async {
    try {
      // print("get device position çalıştı");
      await Geolocator.requestPermission();
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      // print(position);
    } catch (error) {
      print("hata oluştu hata kodu $error");
    }
  }

  Future<void> getLocationData() async {
    locationData = await http.get(Uri.parse(
        "https://www.metaweather.com/api/location/search/?query=$sehir"));
    var locationDataParsed = jsonDecode(locationData.body)[0];
    woeid = await locationDataParsed['woeid'];
  }

  Future<void> getLocationDataLatLong() async {
    locationData = await http.get(Uri.parse(
        "https://www.metaweather.com/api/location/search/?lattlong=${position?.latitude},${position?.longitude}"));
    var locationDataParsed = jsonDecode(utf8.decode(locationData.bodyBytes))[0];
    woeid = await locationDataParsed['woeid'];
    sehir = await locationDataParsed['title'];
  }

  Future<void> getLocationTemperature() async {
    var response = await http
        .get(Uri.parse("https://www.metaweather.com/api/location/$woeid/"));
    var temperatureDataParsed = jsonDecode(response.body);

    setState(() {
      sicaklik =
          temperatureDataParsed['consolidated_weather'][0]['the_temp'].round();
      weatherAbbr = temperatureDataParsed['consolidated_weather'][0]
          ['weather_state_abbr'];
      for (int i = 0; i < temps.length; i++) {
        temps[i] = temperatureDataParsed['consolidated_weather'][i + 1]
                ['the_temp']
            .round();
      }
      for (int i = 0; i < images.length; i++) {
        images[i] = temperatureDataParsed['consolidated_weather'][i + 1]
            ['weather_state_abbr'];
      }
      for (int i = 0; i < dates.length; i++) {
        dates[i] = temperatureDataParsed['consolidated_weather'][i + 1]
            ['applicable_date'];
        dates[i] = DateTime.parse(dates[i]);
      }

      // print(sicaklik);
      // print(weatherAbbr);
      // print(dates[0].weekday);
    });
  }

  Future<void> getDataFromApi() async {
    await getDevicePosition();
    await getLocationDataLatLong();
    getLocationTemperature();
  }

  Future<void> getDataFromApiByCity() async {
    await getLocationData();
    getLocationTemperature();
  }

  @override
  void initState() {
    // TODO: implement initState
    getDataFromApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: sicaklik == null
          ? Center(
              child: SpinKitFadingCube(color: Colors.white),
            )
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 60,
                        width: 60,
                        child: Image.network(
                            "https://www.metaweather.com/static/img/weather/png/64/$weatherAbbr.png")),
                    Text(
                      "${sicaklik}°C",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 70,
                          shadows: <Shadow>[
                            Shadow(
                                color: Colors.black38,
                                offset: Offset(-5, 5),
                                blurRadius: 5)
                          ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          sehir,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              shadows: <Shadow>[
                                Shadow(
                                    color: Colors.black38,
                                    offset: Offset(-3, 3),
                                    blurRadius: 4)
                              ]),
                        ),
                        IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () async {
                              sehir = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(),
                                  ));
                              getDataFromApiByCity();
                              setState(() {
                                sehir = sehir;
                              });
                            }),
                      ],
                    ),
                    SizedBox(
                      height: 120,
                    ),
                    buildDailyWeatherCards(),
                  ],
                ),
              ),
            ),
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/$weatherAbbr.jpg"),
        ),
      ),
    );
  }

  Container buildDailyWeatherCards() {
    List<Widget> cards = List.filled(5, DailyWeather());
    for (int i = 0; i < cards.length; i++) {
      cards[i] = DailyWeather(
          temp: temps[i].toString(),
          date: gunler[dates[i].weekday - 1],
          image: images[i]);
    }
    return Container(
      height: 120,
      child: FractionallySizedBox(
        widthFactor: 0.95,
        child: ListView(scrollDirection: Axis.horizontal, children: cards),
      ),
    );
  }
}
