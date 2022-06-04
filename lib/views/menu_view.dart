import 'package:colour/colour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inet/config/config.dart';
import 'package:inet/views/chart_view.dart';
import 'package:page_transition/page_transition.dart';

import '../classes/auth.dart';
import '../config/firebase.dart';
import '../main.dart';
import '../main/layout_gis.dart';
import '../models/menu_model.dart';
import '../models/news_model.dart';
import '../widgets/alert.dart';
import 'home_view.dart';
import 'login_view.dart';

class MainMenuPage extends StatefulWidget {
  String username, password;

  MainMenuPage(this.username, this.password);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MainMenuState(username, password);
  }
}

class MainMenuState extends State<MainMenuPage> {

  List<MenuModel> listMenus = List<MenuModel>();
  List<NewsModel> listNews = List<NewsModel>();
  TextEditingController searchController = TextEditingController();

  String username, password;

  MainMenuState(this.username, this.password);

  String searchText = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
    ));

    registerNotification(username);

    addMenu();

    addNews();
  }

  void addMenu() {
    MenuModel dashboard = MenuModel();
    dashboard.title = "Quản lý logger";
    dashboard.color = Colors.transparent;
    dashboard.image = "assets/dashboard.png";
    dashboard.icon = const Icon(Icons.assignment, color: Colors.white, size: 30,);
    listMenus.add(dashboard);

    // MenuModel test = MenuModel();
    // test.title = "Test";
    // test.color = Colors.transparent;
    // test.image = "assets/report.png";
    // test.icon = const Icon(Icons.assignment, color: Colors.white, size: 30,);
    // listMenus.add(test);
  }

  void addNews() {
    NewsModel news1 = NewsModel();
    news1.title = "Điểm sự cố trong ngày";
    news1.color = Colors.transparent;
    news1.image = "assets/news1.png";
    news1.icon = const Icon(Icons.assignment, color: Colors.white, size: 30,);
    listNews.add(news1);

    NewsModel news2 = NewsModel();
    news2.title = "Thông tin mới nổi bật";
    news2.color = Colors.transparent;
    news2.image = "assets/news2.png";
    news2.icon = const Icon(Icons.assignment, color: Colors.white, size: 30,);
    listNews.add(news2);
  }

  List<Widget> buildNewsMenu() {
    List<Widget> resultWidgets = List<Widget>();
    for(int i = 0; i < listNews.length; i++) {
      resultWidgets.add(
          listNews.elementAt(i).title.isNotEmpty ? Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.all(15),
            height: 130,
            width: 280,
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    child: Image.asset(listNews.elementAt(i).image),
                    width: 100,
                  ),

                ),
                Expanded(child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: Text(listNews.elementAt(i).title,
                          style: Theme.of(context).textTheme.headline1.merge(const TextStyle(fontWeight: FontWeight.w400)), overflow: TextOverflow.visible, textAlign: TextAlign.center,),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: (){
                        showAlertDialog(context, "Chức năng này đang được phát ", "Vui lòng đợi các bản cập nhật tiếp theo");
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
                        child: Text("Xem ngay", style: Theme.of(context).textTheme.headline1),
                        decoration: BoxDecoration(
                            color: Colour("#F6d06D"),
                            borderRadius: const BorderRadius.all(Radius.circular(25))
                        ),
                      ),
                    )
                  ],
                ))
              ],
            ),
            decoration: BoxDecoration(
              color: Colour('#ECF2FF'),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ) : Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.all(15),
            height: 130,
            width: 250,
            decoration: BoxDecoration(
              color: Colour('#ECF2FF'),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          )
      );
    }
    return resultWidgets;
  }

  List<Widget> buildMainMenu(List<MenuModel> listMenu) {
    List<Widget> resultWidgets = List<Widget>();
    for(int i = 0; i < listMenu.length; i++) {
      if(listMenu.elementAt(i).title.toUpperCase().contains(searchText.toUpperCase())) {
        resultWidgets.add(
            GestureDetector(
              onTap: (){
                if(listMenu.elementAt(i).title.trim() == "Quản lý logger") {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: MyHomePage(key: homeKey, username: username, password: password,),
                    ),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    child: (listMenu.elementAt(i).image != null && listMenu.elementAt(i).image != "") ? (Image.asset(listMenu.elementAt(i).image)) : (listMenu.elementAt(i).icon != null ? listMenu.elementAt(i).icon : Container()),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        // color: Colour('#ECF2FF')
                        color: listMenu.elementAt(i).color
                    ),
                  ),
                  Text(listMenu.elementAt(i).title.trim(), style: Theme.of(context).textTheme.subtitle1.merge(const TextStyle(fontWeight: FontWeight.w400)),)
                ],
              ),
            )
        );
      }
    }
    return resultWidgets;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: AppBar(
                centerTitle: false,
                backgroundColor: Colour("#246EE9"),
                elevation: 0,
                toolbarHeight: 0,
              )
          ),
          //searchBar
          body: ListView(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 50),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: Icon(Icons.account_circle, size: 60, color: Colour('#D1DBEE'),),
                    ),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          child: Text(username, style: Theme.of(context).textTheme.headline1.merge(const TextStyle(color: Colors.white)),),
                        ),
                        Text("Xin chào!", style: Theme.of(context).textTheme.subtitle2.merge(const TextStyle(color: Colors.white)),),

                      ],
                    ),),
                    GestureDetector(
                        onTap: (){
                          Auth authentication = Auth();
                          authentication.clearSavedData();
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: const LoginPage(),
                            ),
                          );
                        },
                        child: const Icon(Icons.logout, color: Colors.white,)
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colour("#246EE9"), Colour("#011586")],
                  ),
                ),
              ),
              Container(
                transform: Matrix4.translationValues(0, -25, 0),
                padding: const EdgeInsets.only(left: 25, right: 25, top: 20),
                child: TextFormField(
                  controller: searchController,
                  autovalidateMode: AutovalidateMode.disabled,
                  onChanged: (text){
                    setState(() {
                      searchText = text;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colour('#F8FAFF'),
                    contentPadding: const EdgeInsets.only(top: 6, bottom: 6, left: 15, right: 15),
                    suffixIcon: IconButton(
                      onPressed: (){

                      },
                      icon: Icon(Icons.search, color: Colour('#666D75'), size: 30,),
                    ),
                    hintText: "Bạn cần tìm gì", hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                            color: Colour('#D1DBEE'),
                            width: 1
                        )
                    ),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                            color: Colour('#D1DBEE'),
                            width: 1
                        )
                    ),

                  ),
                ),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
                ),
              ),
              GridView.count(
                padding: const EdgeInsets.only(top: 10, left: 25, right: 25),
                physics: const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 10.0,
                children: buildMainMenu(listMenus),
              ),
              Container(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  margin: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Cập nhật hôm nay", style: Theme.of(context).textTheme.headline2,),
                      Text("Xem thêm", style: Theme.of(context).textTheme.subtitle1.merge(const TextStyle(fontWeight: FontWeight.w400, color: Colors.blue)),)
                      // Text("Tất cả", style: TextStyle(fontSize: 16, color: Colour('#4466EE')),)
                    ],
                  )
              ),
              Container(
                  margin: const EdgeInsets.only(left: 25, top: 20),
                  height: 130,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: buildNewsMenu(),
                  )
              )
            ],
          )
      ),
    );

  }
}