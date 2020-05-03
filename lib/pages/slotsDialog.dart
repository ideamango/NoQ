import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:noq/models/slot.dart';
import 'package:noq/view/showSlotsPage.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:noq/style.dart';
import 'package:noq/services/authService.dart';

//final TextEditingController _pinPutController = TextEditingController();
//final FocusNode _pinPutFocusNode = FocusNode();
//String _pin;
String status;
bool _isPressed = false;
Slot selectedSlot;
String _errorMessage;
List<Slot> _slotList;
//   '9:00am',
//   '9:30am',
//   '10:00am',
//   '10:30am',
//   '11:30am',
//   '12:00pm',
//   '12:30pm',
//   '1:00am',
//   '10:30am',
//   '11:30am'
// ];

Future<bool> showSlotsDialog(
    BuildContext context, List<Slot> slots, DateTime dateTime) {
  _slotList = slots;

  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return ShowSlotsPage();
        });
      });
}

Widget _buildGridItems(BuildContext context, int index) {
  int x, y = 0;
  int gridRowLength = 5;
  x = (index / gridRowLength).floor();
  y = (index % gridRowLength);

  return GestureDetector(
    onTap: () => _gridItemTapped(x, y),
    child: GridTile(
      child: Container(
        padding: EdgeInsets.all(4),
        // decoration:
        //     BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
        child: Center(
          child: _buildGridItem(index),
        ),
      ),
    ),
  );
}

void _gridItemTapped(int x, int y) {
  print("Grid item tapped");
}

Widget _buildGridItem(int index) {
  Slot sl = _slotList[index];
  return StatefulBuilder(builder: (context, setState) {
    return RaisedButton(
        elevation: (sl.slotSelected == "true") ? 0.0 : 10.0,
        autofocus: false,
        color: (sl.slotSelected == "true")
            ? Colors.greenAccent
            : Colors.indigo[200],
        textColor: Colors.indigo,
        textTheme: ButtonTextTheme.normal,
        highlightColor: Colors.green,
        highlightElevation: 10.0,
        splashColor: highlightColor,
        shape: (sl.slotSelected == "true")
            ? RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(5.0),
                side: BorderSide(color: Colors.black),
              )
            : RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(5.0),
                side: BorderSide(color: Colors.white),
              ),
        onPressed: () {
          setState(() {
            //unselect previously selected slot
            _slotList.forEach((element) => element.slotSelected = "false");

            sl.slotSelected = "true";
            selectedSlot = sl;
          });

          print(sl.slotStrTime);
          print(sl.slotSelected);
        },
        child: new Text(sl.slotStrTime));
  });
}

void bookSlot() {
  print('Selected slot for time: $selectedSlot');
}

Future<bool> newDiallog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedRadio = 0;
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(4, (int index) {
                  return Radio<int>(
                    value: index,
                    groupValue: selectedRadio,
                    onChanged: (int value) {
                      setState(() => selectedRadio = value);
                    },
                  );
                }),
              );
            },
          ),
        );
      });
}
