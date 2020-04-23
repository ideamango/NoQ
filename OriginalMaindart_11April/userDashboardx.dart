// import 'package:flutter/material.dart';
// import 'package:map_launcher/map_launcher.dart';
// import 'main.dart';
// import 'style.dart';
// import 'models/Store.dart';
// //import 'repository/StoreRepository.dart';

// class UserDashboard extends StatefulWidget {
//   UserDashboard({Key key, this.title}) : super(key: key);
//   final String title;

//   @override
//   _UserDashboardState createState() => _UserDashboardState();
// }

// class _UserDashboardState extends State<UserDashboard> {
//   //Getting dummy list of stores from store class and storing in local variable

//   // int _selectedIndex = 0;
//   List<Store> _stores = xstores;
//   int i;
//   TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
//   // List<Widget> _widgetOptions = <Widget>[
//   //   Text(
//   //     'Index 1: Home',
//   //     style: optionStyle,
//   //   ),
//   //   _storesListPage(),
//   //   Text(
//   //     'Index 2: Account',
//   //     style: optionStyle,
//   //   ),
//   // ];
//   int _index = 0;
//   @override
//   Widget build(BuildContext context) {
//     Widget child;
//     switch (_index) {
//       case 0:
//         child = _userFavPage();
//         break;
//       case 1:
//         child = _storesListPage();
//         break;
//       case 2:
//         child = FlutterLogo(colors: Colors.red);
//         break;
//     }
//     final backButton = MaterialButton(
//       minWidth: MediaQuery.of(context).size.width,
//       padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => MyApp()),
//         );
//       },
//       child: Text("Go Back to Home",
//           textAlign: TextAlign.center,
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//     );

//     return MaterialApp(
//       title: 'My Dashboard',
//       theme: ThemeData.light().copyWith(),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Flutter layout demo'),
//         ),
//         body: Center(
//           child: child,
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home),
//               title: Text('Home'),
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.search),
//               title: Text('Search'),
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.account_circle),
//               title: Text('Settings'),
//             ),
//           ],
//           currentIndex: _index,
//           selectedItemColor: Colors.amber[800],
//           onTap: _onItemTapped,
//         ),
//       ),
//     );
//   }

//   // final Widget searchPage = Widget searchPage(BuildContext context) {
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //         title: Text('Search Store'),
//   //         actions: <Widget>[IconButton(icon: Icon(Icons.search))]),
//   //     body: Center(
//   //       child: Container(
//   //         color: Colors.white,
//   //         margin: new EdgeInsets.all(15.0),
//   //         child: new Form(
//   //           key: _formKey,
//   //           //autovalidate: _autoValidate,
//   //           child: Text('Search Page'),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }

//   void _onItemTapped(int index) {
//     setState(() {
//       _index = index;
//     });
//   }

//   Widget _userFavPage() {
//     return Container(
//         child: Column(
//       children: <Widget>[
//         Text("Welcome to homepage"),
//         Text("HEre we will list favourite stores which you selected in past"),
//         Icon(
//           Icons.shopping_cart,
//           color: Colors.white,
//           size: 10,
//         )
//       ],
//     ));
//   }

//   Widget _storesListPage() {
//     return Center(
//       child: Container(
//         margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
//         child: ListView.builder(
//             itemCount: _stores.length,
//             itemBuilder: (BuildContext context, int index) {
//               return Container(
//                 child: new Column(children: _stores.map(_buildItem).toList()),
//                 //children: <Widget>[firstRow, secondRow],
//               );
//             }),
//       ),
//     );
//   }

//   Widget _buildItem(Store str) {
//     return Card(
//         elevation: 10,
//         child: new Column(children: <Widget>[
//           Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 new Container(
//                   margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
//                   alignment: Alignment.center,
//                   decoration: ShapeDecoration(
//                     shape: CircleBorder(),
//                     color: Colors.orange[300],
//                   ),
//                   child: Icon(
//                     Icons.shopping_cart,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//                 new Container(
//                   padding: EdgeInsets.fromLTRB(10.0, 5.0, 0, 0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
//                         child:
//                             Column(crossAxisAlignment: CrossAxisAlignment.start,
//                                 // mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                               Text(
//                                 str.name.toString(),
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: <Widget>[
//                                   Text(
//                                     str.adrs,
//                                   ),
//                                   Container(
//                                     width: 20.0,
//                                     height: 20.0,
//                                     child: IconButton(
//                                       alignment: Alignment.center,
//                                       padding: EdgeInsets.all(0),
//                                       onPressed: () => {
//                                         launchURL(str.name, str.adrs, str.lat,
//                                             str.long),
//                                       },
//                                       highlightColor: Colors.orange[300],
//                                       icon: Icon(
//                                         Icons.location_on,
//                                         color: Colors.blueGrey,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             ]),
//                       ),
//                       DefaultTextStyle.merge(
//                         child: Container(
//                             child: Row(children: [
//                           Icon(Icons.remove_circle,
//                               color: Colors.blueGrey[300]),
//                           Icon(Icons.add_circle, color: Colors.orange),
//                           Icon(Icons.remove_circle,
//                               color: Colors.blueGrey[300]),
//                           Icon(Icons.remove_circle,
//                               color: Colors.blueGrey[300]),
//                           Icon(Icons.remove_circle,
//                               color: Colors.blueGrey[300]),
//                         ])),
//                       ),
//                     ],
//                   ),
//                 ),
//               ]),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Row(
//                 children: <Widget>[],
//               ),
//               Row(
//                 //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   //Icon(Icons.play_circle_filled, color: Colors.blueGrey[300]),
//                   Text('Opens at:', style: labelTextStyle),
//                   Text(str.opensAt, style: lightSubTextStyle),
//                 ],
//               ),
//               Row(
//                 children: [
//                   //Icon(Icons.pause_circle_filled, color: Colors.blueGrey[300]),
//                   Text('Closes at:', style: labelTextStyle),
//                   Text(str.closesAt, style: lightSubTextStyle),
//                 ],
//               ),
//               Row(
//                 children: <Widget>[
//                   new Container(
//                     width: 40.0,
//                     height: 20.0,
//                     child: MaterialButton(
//                       color: Colors.orange,
//                       child: Text(
//                         "Book Slot",
//                         style: new TextStyle(
//                             fontFamily: 'Montserrat',
//                             letterSpacing: 0.5,
//                             color: Colors.white,
//                             fontSize: 10),
//                       ),
//                       onPressed: () => {
//                         //onPressed_bookSlotBtn();
//                       },
//                       highlightColor: Colors.orange[300],
//                     ),
//                   )
//                 ],
//               ),
//             ],
//           )
//         ]));
//   }

//   launchURL(String tit, String addr, double lat, double long) async {
//     final title = tit;
//     final description = addr;
//     final coords = Coords(lat, long);
//     if (await MapLauncher.isMapAvailable(MapType.google)) {
//       await MapLauncher.launchMap(
//         mapType: MapType.google,
//         coords: coords,
//         title: title,
//         description: description,
//       );
//     }
//   }
// }
