import 'package:flutter/material.dart';

class Item1 extends StatelessWidget {
  const Item1({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        'assets/1.jpg',
        width: MediaQuery.of(context).size.width * .9,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}

class Item2 extends StatelessWidget {
  const Item2({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        'assets/2.jpg',
        width: MediaQuery.of(context).size.width * .9,
        fit: BoxFit.fitWidth,
      ),
      // child: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Text("Data",
      //         style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 22.0,
      //             fontWeight: FontWeight.bold)),
      //     Text("Data",
      //         style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 17.0,
      //             fontWeight: FontWeight.w600)),
      //   ],
      // ),
    );
  }
}

class Item3 extends StatelessWidget {
  const Item3({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        'assets/3.jpg',
        width: MediaQuery.of(context).size.width * .9,
        fit: BoxFit.fitWidth,
      ),
      // child: Image.asset('assets/3.jpg',
      //     gaplessPlayback: true,
      //     // height: MediaQuery.of(context).size.height * .24,
      //     // width: MediaQuery.of(context).size.width * .9,
      //     fit: BoxFit.fitHeight),
    );
  }
}

class Item4 extends StatelessWidget {
  const Item4({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        'assets/4.jpg',
        width: MediaQuery.of(context).size.width * .9,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}

class Item5 extends StatelessWidget {
  const Item5({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        'assets/5.jpg',
        width: MediaQuery.of(context).size.width * .9,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}

class Item6 extends StatelessWidget {
  const Item6({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        'assets/6.jpg',
        width: MediaQuery.of(context).size.width * .9,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}

class Item7 extends StatelessWidget {
  const Item7({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        'assets/7.jpg',
        width: MediaQuery.of(context).size.width * .9,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
