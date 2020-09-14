// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:flutter/material.dart';
// import 'package:noq/userHomePage.dart';

// class LandingPage extends StatefulWidget {
//   @override
//   _LandingPageState createState() => _LandingPageState();
// }

// class _LandingPageState extends State<LandingPage> {
//   @override
//   void initState() {
//     super.initState();
//     this.initDynamicLinks();
//   }

//   void initDynamicLinks() async {
//     final PendingDynamicLinkData data =
//         await FirebaseDynamicLinks.instance.getInitialLink();
//     final Uri deepLink = data?.link;

//     if (deepLink != null) {
//       Navigator.pushNamed(context, deepLink.path);
//     }

//     FirebaseDynamicLinks.instance.onLink(
//         onSuccess: (PendingDynamicLinkData dynamicLink) async {
//       final Uri deepLink = dynamicLink?.link;
//       print(deepLink.path);

//       if (deepLink != null) {
//         print(deepLink.path);
//         Navigator.pushNamed(context, deepLink.path);
//       }
//     }, onError: (OnLinkErrorException e) async {
//       print('onLinkError');
//       print(e.message);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return UserHomePage();
//   }
// }
