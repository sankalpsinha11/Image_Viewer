import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Image Viewer",
      home: homepage(),
    );
  }
}

class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage>{

  int selectedIndex = 0;
  int pageNumber_nature = 1;
  int pageNumber_pets = 1;
  Map<int, Widget> map = new Map();
  String url1 = "https://api.unsplash.com/collections/1580860/photos";
  String url2 = "https://api.unsplash.com/collections/139386/photos";
  List data1=[];
  List nature = [];
  List nature_title = [];
  List data2=[];
  List pets = [];
  List pets_title = [];
  String access_key = "r1zplx0mNKePUYxLjxnv7LYsEmy_D9GIJ0vsN2qilI8";
  bool isLoading = true;
  bool loading = true;
  ScrollController _sc = new ScrollController();
  ScrollController _sc2 = new ScrollController();

  @override
  void initState() {
    super.initState();
    loadTabs();
    getData1().whenComplete((){
      setState(() {
        isLoading = false;
      });
    });
    getData2().whenComplete((){
      setState(() {
        loading = false;
      });
    });
    _sc.addListener((){
      if(_sc.position.pixels == _sc.position.maxScrollExtent){
        _getMoreData();
      }
    });
    _sc2.addListener((){
      if(_sc2.position.pixels == _sc2.position.maxScrollExtent){
        _getMoreData2();
      }
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    _sc2.dispose();
    super.dispose();
  }
  
  loadTabs() {
    map = new Map();
    map.putIfAbsent(0,()=> Text("Nature"));
    map.putIfAbsent(1, ()=> Text("Pets"));
  }

  _getMoreData(){
    pageNumber_nature = pageNumber_nature + 1;
    getData1();
  }

  Future getData1() async{
    var response = await http.get(
        Uri.encodeFull(url1 + "?page=$pageNumber_nature"),
        headers: {
          "Accept" : "application/json",
          "Authorization" : "Client-ID $access_key"
        }
    );
      setState(() {
        data1 = json.decode(response.body);
      });
      _assignNature();
  }

  _assignNature() {
    for(int i = 0 ; i < data1.length ; i++){
      nature.add(data1.elementAt(i)['urls']['regular']);
      nature_title.add(data1.elementAt(i)['description']);
    }
  }

  _getMoreData2(){
    pageNumber_pets = pageNumber_pets + 1;
    getData2();
  }

  Future getData2() async{
    var response = await http.get(
        Uri.encodeFull(url2+"?page=$pageNumber_pets"),
        headers: {
          "Accept" : "application/json",
          "Authorization" : "Client-ID $access_key"
        }
    );
    setState(() {
      data2 = json.decode(response.body);
    });
    _assignPets();
  }

  _assignPets() {
    for(int i = 0 ; i < data2.length ; i++){
      pets.add(data2.elementAt(i)['urls']['regular']);
      pets_title.add(data2.elementAt(i)['description']);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Viewer",style: TextStyle(
            color: Colors.black
        ),),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10.0,),
            Center(
              child: CupertinoSlidingSegmentedControl(
                onValueChanged: (val){
                  setState(() {
                    selectedIndex = val;
                  });
                },
                backgroundColor: Colors.black12,
                thumbColor: Colors.white,
                groupValue: selectedIndex,
                padding: EdgeInsets.all(4.0),
                children: map,
              ),
            ),
            SizedBox(height: 20.0,),
            (selectedIndex == 0) ? Expanded(
              child: Container(
                child:  (isLoading) ? Center(
                  child:
                  CircularProgressIndicator()
                  ,) :
                GridView.builder(
                  shrinkWrap: true,
                  controller: _sc,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 18.0,
                      crossAxisSpacing: 4.0,
                      crossAxisCount: 2,
                    childAspectRatio:  MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 1.2)
                  ),
                  scrollDirection: Axis.vertical,
                  itemCount: nature.length,
                  itemBuilder: (context , index){
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal : 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(
                              nature[index],
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width*0.46,
                              height: 300,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal : 8.0),
                          child: Text((nature_title[index]== null) ? "Nature Images" : nature_title[index]
                            ,overflow: TextOverflow.ellipsis,maxLines : 1,
                          style: TextStyle(
                            color: Colors.grey[500]
                          ),),
                        )
                      ],
                    );
                  },
                ),
              ),
            ) : Expanded(
              child: Container(
                child:  (loading) ? Center(
                  child:
                  CircularProgressIndicator()
                  ,) :
                GridView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  controller: _sc2,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 4.0,
                    crossAxisCount:  2,
                      childAspectRatio:  MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 1.2)
                  ),
                  itemCount: pets.length,
                  itemBuilder: (context , index){
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal : 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(
                              pets[index],
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width*0.46,
                              height: 300,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal : 8.0),
                          child: Text((pets_title[index]== null) ? "Pets Images" : pets_title[index]
                            , overflow: TextOverflow.ellipsis,maxLines: 1,
                            style: TextStyle(
                                color: Colors.grey[500]
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

