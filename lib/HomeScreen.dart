import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/model/tempmodel.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int temp=0;
  var woeid=0;
  String location="City";
  String weathear="clear";
  String appear="c";
  fatchCity(String input)async{
    var url=Uri.parse("https://www.metaweather.com/api/location/search/?query=$input");
    var response = await http.get(url);
    var resbonsebody=jsonDecode(response.body)[0];
    setState(() {
      woeid=resbonsebody["woeid"];
     location =resbonsebody["title"];
    });
  }
   Future<List<tempmodel>>fatchTamp()async{
    var url=Uri.parse("https://www.metaweather.com/api/location/$woeid");
    var response = await http.get(url);
    var resbonsebody=jsonDecode(response.body)["consolidated_weather"];
    setState(() {
      temp=resbonsebody[0]["the_temp"].round();
      print("$temp");
      weathear =resbonsebody[0]["weather_state_name"].replaceAll(' ','').toLowerCase();
      print("$temp");
      appear=resbonsebody[0]["weather_state_abbr"];
    });
    List <tempmodel>list=[];
    for(var i in resbonsebody){
      tempmodel x =tempmodel(applicable_date: i["applicable_date"],max_temp:i["max_temp"] ,min_temp:i["min_temp"] ,weather_state_abbr: i["weather_state_abbr"]);
      list.add(x);
    }
    return list;
  }

  onTextFieldSubmitted(String input)async{
    await fatchCity(input);
    await fatchTamp();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("images/$weathear.png"),
          fit: BoxFit.cover,
        )),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(

                children: [
                  Center(
                    child: Image.network(
                      "https://www.metaweather.com/static/img/weather/png/$appear.png",
                      width: 100,
                    ),
                  ),
                  Center(
                    child: Text(
                      "$temp °C",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "$location",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                      ),
                    ),
                  ),

                ],
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      onSubmitted: (String input){
                        print("$input");
                        onTextFieldSubmitted(input);
                      },
                      style: TextStyle(
                          color: Colors.white,fontSize: 24
                      ),
                      decoration: InputDecoration(
                        hintText: "Search anther Country"
                        ,helperStyle: TextStyle(
                          color: Colors.white,fontSize: 18
                      ),
                        prefixIcon: Icon(Icons.search_rounded,color: Colors.white,size: 30,),
                      ),
                    ),
                  ),
                  Container(
                    height: 200,
                    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 20),
                    child:
                    FutureBuilder(
                      future: fatchTamp(),
                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        if(snapshot.data==null){
                          return Text(" ");
                        }else if(snapshot.hasData){return
                          ListView.builder(
                 scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                             return Card(
                               color: Colors.transparent,
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(20),
                               ),
                               child: Container(
                                  height: 170,
                                 width: 120,
                                 child: Column(
                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                   crossAxisAlignment: CrossAxisAlignment.center,
                                   children: [
                                     Text("Date: ${snapshot.data[index].applicable_date}",style: TextStyle(color: Colors.white,fontSize: 12),textAlign: TextAlign.center,),
                                     Text("City: $location",style: TextStyle(color: Colors.white,fontSize: 12),textAlign: TextAlign.center,),
                                     Image.network(
                                       "https://www.metaweather.com/static/img/weather/png/${snapshot.data[index].weather_state_abbr}.png",
                                       width: 50,
                                     ),
                                     Text("Min: ${snapshot.data[index].min_temp.round()}",style: TextStyle(color: Colors.white,fontSize: 12),textAlign: TextAlign.center,),
                                     Text("Mix: ${snapshot.data[index].max_temp.round()}",style: TextStyle(color: Colors.white,fontSize: 12),textAlign: TextAlign.center,),

                                   ],
                                 ),
                               ),
                             );

                          },);
                        }else{
                         return Text(" ");
                        }

                      },),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
