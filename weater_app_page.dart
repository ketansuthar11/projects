import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'Additional_Info.dart';
import 'HourlyForecastItem.dart';
import 'SecretsInfo.dart';

class WeatherAppPage extends StatefulWidget {
  const WeatherAppPage({super.key});


  @override
  State<WeatherAppPage> createState() => _WeatherAppPage();
}

class _WeatherAppPage extends State<WeatherAppPage> {
  late double tempCelsius = 0;
  late String currentSky = '';
  late int humidity = 0;
  late int pressure = 0;
  late double windspeed = 0;
  String city = 'Vadodara';
  Future<Map<String,dynamic>> getCurrentWeather() async{
    try{
      final res = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=$openWeatherAPIKey'),);
      final data = jsonDecode(res.body);
      if(data['cod']!='200'){
        throw 'An unexpected error occurred';
      }
      return data;
    }
    catch(e){
      throw e.toString();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          city,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'refresh',
            iconSize: 20.0,
            onPressed: () {
              setState(() {
                // Refresh weather data
                getCurrentWeather();
              });
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.search),
            tooltip: 'search',
            iconSize: 20.0,
            onPressed: () async {
              final TextEditingController controller = TextEditingController();
              String? newCity = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Enter City'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'City name'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(controller.text);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
              if (newCity != null && newCity.isNotEmpty) {
                setState(() {
                  city = newCity;
                });
              }
            },
          )

        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder:(context,snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if(snapshot.hasError){
            return  const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Invalid city\nor\nCheck internet connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.blueGrey,fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          final data = snapshot.data;
          double? temp = data?['list']?[0]?['main']?['temp']?.toDouble(); // Assuming this is double
          if (temp != null) {
            tempCelsius = temp ;
            currentSky = data?['list']?[0]?['weather']?[0]?['main']?? '';
            humidity =  data?['list']?[0]?['main']?['humidity'];
            pressure =  data?['list']?[0]?['main']?['pressure'];
            windspeed =  data?['list']?[0]?['wind']?['speed'];
          }



          IconData weatherIcon;
          String label;
          switch(currentSky.toLowerCase()){
            case 'clear':
              weatherIcon = Icons.wb_sunny;
              label = 'Sunny';
              break;
            case 'clouds':
              weatherIcon = Icons.cloud;
              label = 'Cloudy';
              break;
            case 'rain':
              weatherIcon = Icons.beach_access;
              label = 'Rainy';
              break;
            case 'snow':
              weatherIcon = Icons.ac_unit;
              label = 'Snowy';
              break;
            case 'thunderstorm':
              weatherIcon = Icons.flash_on;
              label = 'Thunderstorm';
              break;
            default:
              weatherIcon = Icons.help_outline;
              label = 'Unknown';
          }

          return SingleChildScrollView(
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child:  Padding(
                          padding:  const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Text(
                              '${tempCelsius.toStringAsFixed(2)} K°',
                          // '${tempCelsius.toStringAsFixed(2)} °C',
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Icon(
                                weatherIcon,
                                size: 64.0,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                               Text(
                                label,
                                style: const TextStyle(color: Colors.white54),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Hourly Forecast",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(
                  height: 16,
                ),
                 //  SingleChildScrollView(
                 //   scrollDirection: Axis.horizontal,
                 //   child: Row(
                 //    children: [
                 //      for(int i=0;i<5;i++)
                 //         HourlyForecastItem(
                 //             time:DateTime.fromMillisecondsSinceEpoch((data?['list']?[i+1]?['dt'] ?? 0) * 1000).toString(),
                 //             icon: data?['list']?[i+1]?['weather']?[0]?['main'] == 'Clouds' ||
                 //                 data?['list']?[i+1]?['weather']?[0]?['main'] == 'Rain'
                 //                 ? Icons.cloud
                 //                 : Icons.wb_sunny,
                 //             tempreture: (data?['list']?[i+1]?['main']?['temp']).toStringAsFixed(2) + "°K",
                 //         ),
                 //    ],
                 //               ),
                 // ),
            
                 SizedBox(
                   height: 130,
                   child: ListView.builder(
                       scrollDirection: Axis.horizontal,
                       itemCount:5,
                       itemBuilder: (context,index){
                         final time = DateTime.parse(data?['list']?[index+1]?['dt_txt']??'');
                         return HourlyForecastItem(
                           time:DateFormat('j').format(time),
                           icon: data?['list']?[index+1]?['weather']?[0]?['main'] == 'Rain' ||
                                         data?['list']?[index+1]?['weather']?[0]?['main'] == 'Clouds'
                                         ? Icons.cloud
                                         : Icons.wb_sunny,
                           tempreture: (data?['list']?[index+1]?['main']?['temp']).toStringAsFixed(2) + "°K",
                         );
                       }
                   ),
                 ),
                //Weather Forcast card
                 const SizedBox(
                   height: 20,
                 ),
                 const Text(
                   "Additional Features",
                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                 ),
                const SizedBox(
                  height: 30,
                ),
            
                  Container(
                    color: Colors.blue,
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
            
                      AdditionalInfo(icon: Icons.water_drop_rounded,label: "Humidity",value: humidity.toString()),
                      AdditionalInfo(icon: Icons.air,label: "Wind Speed",value: windspeed.toString()),
                      AdditionalInfo(icon: CupertinoIcons.umbrella_fill,label: "Pressure",value: pressure.toString()),
                    ],
                                ),
                  ),
              ],
            ),
                    ),
          );
        },
      ),
    );
  }
}

