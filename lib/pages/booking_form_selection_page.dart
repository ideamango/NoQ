import 'package:flutter/material.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/meta_form.dart';
import 'package:noq/global_state.dart';

class BookingFormSelection extends StatefulWidget {
  final MetaEntity metaEntity;
  final List<MetaForm> forms;
  final DateTime preferredSlotTime;
  BookingFormSelection(
      {Key key,
      @required this.metaEntity,
      @required this.forms,
      @required this.preferredSlotTime})
      : super(key: key);

  @override
  _BookingFormSelectionState createState() => _BookingFormSelectionState();
}

class _BookingFormSelectionState extends State<BookingFormSelection> {
  MetaEntity metaEntity;
  List<MetaForm> forms;
  GlobalState _gs;
  bool initCompleted = false;
  int _radioValue1 = -1;
  int index = 0;
  @override
  void initState() {
    super.initState();
    metaEntity = this.widget.metaEntity;
    forms = this.widget.forms;
    getGlobalState().whenComplete(() {
      setState(() {
        initCompleted = true;
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  void _handleRadioValueChange1(int value) {
    setState(() {
      _radioValue1 = value;

      // switch (_radioValue1) {
      //   case 0:
      //     Fluttertoast.showToast(msg: 'Correct !',toastLength: Toast.LENGTH_SHORT);
      //     correctScore++;
      //     break;
      //   case 1:
      //     Fluttertoast.showToast(msg: 'Try again !',toastLength: Toast.LENGTH_SHORT);
      //     break;
      //   case 2:
      //     Fluttertoast.showToast(msg: 'Try again !',toastLength: Toast.LENGTH_SHORT);
      //     break;
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return (forms.length != 0)
        ? Container(
            child: Column(
              children: [
                new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Container(
                    //   child: ListView.builder(
                    //       itemCount: forms.length,
                    //       itemBuilder: (BuildContext context, int index) {
                    //         return
                    Container(
                      child: Row(
                        children: [
                          new Radio(
                            value: index,
                            groupValue: _radioValue1,
                            onChanged: _handleRadioValueChange1,
                          ),
                          Column(
                            children: [
                              Wrap(children: [
                                new Text(
                                  forms[index].name,
                                  style: new TextStyle(fontSize: 10.0),
                                ),
                              ]),
                              new Text(
                                forms[index].description != null
                                    ? forms[index].description
                                    : "No Description found",
                                style: new TextStyle(fontSize: 8.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    // }),
                    //),
                  ],
                ),
              ],
            ),
          )
        : Container(
            child: Text('No forms found'),
          );
  }
}
