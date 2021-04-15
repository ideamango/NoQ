// import 'package:flushbar/flushbar.dart';
// import 'package:flutter/material.dart';
// import 'package:noq/utils.dart';

// class ParentPage extends StatefulWidget {
//   @override
//   _ParentPageState createState() => _ParentPageState();
// }

// class _ParentPageState extends State<ParentPage> {
//   final GlobalKey<ChildPageState> _key = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Parent")),
//       body: Center(
//         child: Column(
//           children: <Widget>[
//             Expanded(
//               child: Container(
//                 color: Colors.grey,
//                 width: double.infinity,
//                 alignment: Alignment.center,
//                 child: RaisedButton(
//                   child: Text("Call method in child"),
//                   onPressed: () => _key.currentState
//                       .methodInChild(), // calls method in child
//                 ),
//               ),
//             ),
//             Text("Above = Parent\nBelow = Child"),
//             Expanded(
//               child: ChildPage(
//                 key: _key,
//                 function: methodInParent,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   methodInParent() => print("Clicked");
// }

// class ChildPage extends StatefulWidget {
//   final Function function;

//   ChildPage({Key key, this.function}) : super(key: key);

//   @override
//   ChildPageState createState() => ChildPageState();
// }

// class ChildPageState extends State<ChildPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.teal,
//       width: double.infinity,
//       alignment: Alignment.center,
//       child: RaisedButton(
//         child: Text("Call method in parent"),
//         onPressed: () => widget.function(), // calls method in parent
//       ),
//     );
//   }

//   methodInChild() => Fluttertoast.showToast(msg: "Method called in child");
// }
