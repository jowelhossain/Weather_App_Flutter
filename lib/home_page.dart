import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart'as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position= await Geolocator.getCurrentPosition();
    print("latitude is ${position!.latitude} and longitude is ${position!.longitude}");
    getWeatherData();
  }
  
  Position? position;
  
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;
  
  getWeatherData()async{
    
    var weatherData= await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=4daee45e58224e0c865db4b4454a4a76&units=metric"));

    var forecastData= await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=4daee45e58224e0c865db4b4454a4a76&units=metric"));



    setState(() {

      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherData.body));
      forecastMap = Map<String, dynamic>.from(jsonDecode(forecastData.body));

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    determinePosition();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:weatherMap!=null? Scaffold(

        body: Column(
          children: [
            InkWell(
              onTap: (){
                setState(() {

                });
              },
              child: Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                height:MediaQuery.of(context).size.height*.65,

                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(15),

                  color: Colors.deepPurple
                ),
                child: Column(

                  children: [

                    Container(

                      padding: EdgeInsets.only(top: 50),
                      child: Column(
                        children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("${weatherMap!["name"]},",style: TextStyle( color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),),
                             Text("${weatherMap!["sys"]['country']}",style: TextStyle( color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),),
                           ],
                         ),
                          SizedBox(height: 5,),
                          Text("${Jiffy("${DateTime.now()}").format('MMMM do yyyy, hh : mm')}",style: TextStyle( color: Colors.white,fontSize: 16, fontWeight: FontWeight.bold,)),


                        ],
                      ),
                    ),
                    SizedBox(height: 10,),

                    Container(

                        height: 120,
                        width:120,

                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),


                        child: Image.network("https://openweathermap.org/img/wn/${weatherMap!['weather'][0]['icon']}@2x.png",height: 100,width: 100,color: Colors.white,)),
                      SizedBox(height: 10,),
                    Container(
                      child:Text("${weatherMap!["weather"][0]['main']}",style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold),) ,
                    ),

                    SizedBox(height: 10,),
                    Container(
                      child:Text("${weatherMap!['main']['temp']}°",style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),) ,
                    ),
                    SizedBox(height: 40),

                    Container(
                      height: MediaQuery.of(context).size.height* 0.08,
                      child: Column(
                        mainAxisAlignment:MainAxisAlignment.spaceBetween ,

                        children: [
                          Text("Feels Like ${weatherMap!['main']['feels_like']}°",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Humidity ${weatherMap!['main']['humidity']},",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),SizedBox(width: 5,),
                              Text("Pressure ${weatherMap!['main']['pressure']}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Sunrise ${Jiffy("${DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunrise']*1000)}").format('hh:mm')} AM,",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),SizedBox(width: 5,),
                              Text("Sunset ${Jiffy("${DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunset']*1000)}").format('hh:mm')} PM",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),SizedBox(width: 5,),


                            ],
                          ),




                      ],),


                    ),



                  ],


                ),

              ),
            ),


            SizedBox(height: 5,),

            SizedBox(
              height:MediaQuery.of(context).size.height*0.25,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: forecastMap!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context,index){

                    return InkWell(
                      onTap: (){

                        setState(() {

                        });
                      },

                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        margin: EdgeInsets.only(right: 5, left: 5),

                          width: MediaQuery.of(context).size.height*.2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                            Text("${Jiffy("${forecastMap!['list'][index]['dt_txt']}").format('EEE, HH : mm')}",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),

                            Image.network("https://openweathermap.org/img/wn/${forecastMap!['list'][index]['weather'][0]['icon']}@2x.png"),

                              Text("${forecastMap!['list'][index]['main']["temp"]}°",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("${forecastMap!['list'][index]['weather'][0]["description"]}",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],)

                      ),
                    );
                  }),
            )
          ],
        ),


      ): Center(child: CircularProgressIndicator()),
    );
  }
}
