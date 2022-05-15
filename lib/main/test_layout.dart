import 'package:colour/colour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TestPageState();
  }
}

class TestPageState extends State<TestPage> {
  bool isClicked = true;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("test title", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(

              margin: EdgeInsets.all(25),
              padding: EdgeInsets.only(bottom: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin:EdgeInsets.only(left: 8, top: 8) ,
                        child: Text("back"),),
                      Container(
                        margin:EdgeInsets.only(right: 8, top: 8) ,
                        child: Icon(
                          Icons.arrow_right_alt
                        ))
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 15),
                    child:
                    Icon(
                      Icons.account_circle, size: 50, color: Colors.cyan,
                    ),
                  ),
                  Text(
                    "thuong", style: TextStyle(fontSize: 18, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    child: Text(
                      "hihi", style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    margin: EdgeInsets.only(top: 8, bottom: 15),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 15),
                            padding: EdgeInsets.only( right: 15

                            ),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: Text("2345", style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
                                ),

                                Text("3435", style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                              ],
                            ),
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1, color: Colors.black))
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15),
                            padding: EdgeInsets.only( right: 15

                            ),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: Text("2345", style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
                                ),

                                Text("3435", style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                              ],
                            ),
                            decoration: BoxDecoration(
                                border: Border(right: BorderSide(width: 1, color: Colors.black))
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: Text("2345", style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
                                ),

                                Text("3435", style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),


                ],
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(2,2),
                        blurRadius: 2,
                        spreadRadius: 0
                    )
                  ]
              ),
            ),
          ],
        )
      )
    );
  }
}