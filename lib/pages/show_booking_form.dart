import 'package:flutter/material.dart';
import 'package:noq/pages/search_child_entity_page.dart';
import 'package:noq/pages/search_entity_page.dart';
import 'package:noq/services/create_form_fields.dart';
import 'package:noq/widget/appbar.dart';

class ShowBookingForm extends StatefulWidget {
  @override
  _ShowBookingFormState createState() => _ShowBookingFormState();
}

class _ShowBookingFormState extends State<ShowBookingForm> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBarWithBackButton(
            backRoute: SearchEntityPage(), titleTxt: "Booking Form Page"),
        body: Container(
          child: CreateFormFields(),
        ),
      ),
    );
  }
}
