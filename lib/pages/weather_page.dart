import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  //variable
  Map<String, dynamic>? data;
  List<dynamic>? hourlyTimes;
  List<dynamic>? hourlyTemperatures;
  List<dynamic>? hourlyHumidities;
  String? timezone;
  String? greetings;
  String? formattedData;
  String? formattedTime;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  //fetchData function  to make HTTP GET request to the provided API
  void fetchData() async {
    //Convert URL string to URi object
    Uri url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=21.9747&longitude=96.0836&current=temperature_2m,relative_humidity_2m&hourly=temperature_2m,relative_humidity_2m');
    final response = await http.get(url);
    if (response == 200) {
      setState(() {
        data = jsonDecode(response.body);
        hourlyTimes = data!['hourly']['time'].sublist(0, 24);
        hourlyTemperatures = data!['hourly']['temperature_2m'].sublist(0, 24);
        hourlyHumidities =
            data!['hourly']['relative_humidity_2m'].sublist(0, 24);
        timezone = data!['timezone'];

        //Determine the greeting and format the data and time
        DateTime currentTime = DateTime.parse(data!['current']['time']);
        int currentHour = currentTime.hour;
        if (currentHour < 12) {
          greetings = 'Good Morning';
        } else if (currentHour < 17) {
          greetings = 'Good Afternoon';
        } else {
          greetings = 'Good Evening';
        }

        //Formatted data
        formattedData = DateFormat('EEEE d').format(currentTime);

        //Formatted time
        formattedTime = DateFormat('h:mm a').format(currentTime);
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  //Funtion to create grandient text for hourly forcast text
  Widget grdientText(String text, double fontSize, FontWeight fontweight) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
              colors: [Color.fromARGB(255, 255, 167, 2), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          .createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.openSans(fontSize: fontSize, fontWeight: fontweight),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              const Color.fromARGB(255, 211, 140, 7),
              const Color.fromARGB(171, 133, 23, 161).withOpacity(0.6),
              const Color.fromARGB(255, 0, 0, 0)
            ])),

        //Padding around contents
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),

          // Column starts  here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Timezone, greet and more icon in a container wrapped in a row\
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RichText(
                    text: TextSpan(
                        style: GoogleFonts.openSans(height: 1.1),
                        children: <TextSpan>[
                          // Timezone in a textspan
                          TextSpan(
                              text: '$timezone\n',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w100,
                                  color: const Color(0xFFFFFFFF)
                                      .withOpacity(0.7))),

                          //greet in a textspan
                          TextSpan(
                            text: '$greetings',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFFFFFF)),
                          ),
                        ]),
                  ),

                  //Conatiner for more icon
                  Container(
                    padding: const EdgeInsets.all(2.0),
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          width: 0.4,
                          color: const Color(0xFFFFFFFF),
                        )),
                    child: const Icon(
                      Icons.more_vert_outlined,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),

              //Container for images
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  height: 200.0,
                  width: 200.0,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/image.png"),
                  )),
                ),
              ),
              //temperature , humidity , data and time in a richtext
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: GoogleFonts.openSans(height: 1.2),
                      children: <TextSpan>[
                        // Temperature in a textspan
                        TextSpan(
                            text:
                                '${data!['current']['temperature_2m'].toString().substring(0, 2)} °C \n',
                            style: const TextStyle(
                                fontSize: 65,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFFFFF))),

                        //Humidity in a textspan
                        TextSpan(
                          text:
                              'Humidity ${data!['current']['relative_humidity_2m']} % \n',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFFFFFF)),
                        ),
                        //current data and time in a textspan
                        TextSpan(
                          text: 'Friday 27 , 10:45 PM',
                          style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFFFFFFFF).withOpacity(0.7)),
                        )
                      ]),
                ),
              ),

              //HOurly forecast text and keyboard arrow down icon in a container wrapped in a padding
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),

                //HOurly forecast text and keyboard arrow down icon in a container
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    //Hourly forecast text
                    grdientText('Hourly Forecast', 20.0, FontWeight.bold),
                    //Container for keyboard arrow
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFFF),
                          borderRadius: BorderRadius.circular(100.0)),
                      // keyboard arrow down
                      child: Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
              ),

              //Expanded
              Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(0.0),
                      itemCount: 24,
                      itemBuilder: (context, index) {
                        return Container(
                          padding:
                              const EdgeInsets.only(bottom: 12.0, top: 5.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              border: Border(
                            bottom: BorderSide(
                              width: 0.4,
                              color: Color(0xFFFFFFFF),
                            ),
                          )),

                          //Hour , Humidity and temperature using text in a row
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              //Hour
                              Text(
                                '12 AM',
                                style: GoogleFonts.openSans(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                              //Colum for humidity
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Humidity Text
                                  Text(
                                    'Humidity',
                                    style: GoogleFonts.openSans(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFFFFFFF)
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  // Humidity value
                                  Text(
                                    '76 %',
                                    style: GoogleFonts.openSans(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ],
                              ),

                              //Temperature
                              Text(
                                '36 C',
                                style: GoogleFonts.openSans(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                            ],
                          ),
                        );
                      }))
            ],
          ),

          //column ends here
        ),
      ),
    );
  }
}
