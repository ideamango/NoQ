import 'package:flutter/material.dart';

Future<bool> showLoadingDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(
                backgroundColor: Colors.black54,
                children: <Widget>[
                  Center(
                    child: Column(children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Please Wait....",
                        style: TextStyle(color: Colors.blueAccent),
                      )
                    ]),
                  )
                ]));
      });
}

// Widget progressCir = new Container(
//   child: new Stack(
//     children: <Widget>[
//       new Container(
//         alignment: AlignmentDirectional.center,
//         decoration: new BoxDecoration(
//           color: Colors.white70,
//         ),
//         child: new Container(
//           decoration: new BoxDecoration(
//               color: Colors.blue[200],
//               borderRadius: new BorderRadius.circular(10.0)),
//           width: 300.0,
//           height: 200.0,
//           alignment: AlignmentDirectional.center,
//           child: new Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               new Center(
//                 child: new SizedBox(
//                   height: 50.0,
//                   width: 50.0,
//                   child: new CircularProgressIndicator(
//                     value: null,
//                     strokeWidth: 7.0,
//                   ),
//                 ),
//               ),
//               new Container(
//                 margin: const EdgeInsets.only(top: 25.0),
//                 child: new Center(
//                   child: new Text(
//                     "loading.. wait...",
//                     style: new TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   ),
// );
