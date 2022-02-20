import 'package:flutter/material.dart';

class DailyWeather extends StatelessWidget {
  const DailyWeather(
      {@required this.temp, @required this.date, @required this.image});
  final String? image;
  final String? date;
  final String? temp;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 2,
      child: Container(
        height: 120,
        width: 100,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.network(
            "https://www.metaweather.com/static/img/weather/png/64/$image.png",
            height: 50,
            width: 50,
          ),
          Text("$temp°C"),
          Text("$date")
        ]),
      ),
    );
  }
}
