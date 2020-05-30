import 'package:flutter/material.dart';
import 'package:noq/models/localDB.dart';

class ChildEntityDetailsPage extends StatefulWidget {
  final EntityAppData entity;
  ChildEntityDetailsPage({Key key, @required this.entity}) : super(key: key);
  @override
  _ChildEntityDetailsPageState createState() => _ChildEntityDetailsPageState();
}

class _ChildEntityDetailsPageState extends State<ChildEntityDetailsPage> {
  @override
  void initState() {
    super.initState();
    print(widget.entity.isFavourite.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add child entities',
      //theme: ThemeData.light().copyWith(),
      home: Scaffold(
        appBar: AppBar(title: Text(''), backgroundColor: Colors.teal,
            //Theme.of(context).primaryColor,
            actions: <Widget>[]),
        body: Center(
          child: Text("jhsgdf"),
          // new Form(
          //   key: _formKey,
          //   autovalidate: true,
          //   child: new ListView(
          //     padding: const EdgeInsets.symmetric(horizontal: 5.0),
          //     children: <Widget>[
          //       Container(
          //         decoration: BoxDecoration(
          //             border: Border.all(color: Colors.indigo),
          //             color: Colors.grey[50],
          //             shape: BoxShape.rectangle,
          //             borderRadius: BorderRadius.all(Radius.circular(5.0))),
          //         padding: EdgeInsets.all(5.0),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: <Widget>[
          //             Column(
          //               children: <Widget>[
          //                 Container(
          //                   decoration: indigoContainer,
          //                   child: Theme(
          //                     data: ThemeData(
          //                       unselectedWidgetColor: Colors.white,
          //                       accentColor: Colors.grey[50],
          //                     ),
          //                     child: ExpansionTile(
          //                       //key: PageStorageKey(this.widget.headerTitle),
          //                       initiallyExpanded: false,
          //                       title: Row(
          //                         children: <Widget>[
          //                           Text(
          //                             "Basic Details",
          //                             style: TextStyle(
          //                                 color: Colors.white, fontSize: 15),
          //                           ),
          //                           SizedBox(width: 5),
          //                           Icon(
          //                             Icons.info,
          //                             color: Colors.white,
          //                           ),
          //                         ],
          //                       ),
          //                       backgroundColor: Colors.indigo,

          //                       children: <Widget>[
          //                         new Container(
          //                           width:
          //                               MediaQuery.of(context).size.width * .94,
          //                           decoration: BoxDecoration(
          //                               border:
          //                                   Border.all(color: Colors.indigo),
          //                               color: Colors.grey[50],
          //                               shape: BoxShape.rectangle,
          //                               borderRadius: BorderRadius.all(
          //                                   Radius.circular(5.0))),
          //                           padding: EdgeInsets.all(2.0),
          //                           child: Expanded(
          //                             child: Text(
          //                                 'These are important details of the establishment, Same will be shown to customer while search.',
          //                                 style: lightSubTextStyle),
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //                 nameField,
          //                 entityType,
          //                 regNumField,
          //                 opensTimeField,
          //                 closeTimeField,
          //                 daysClosedField,
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //       SizedBox(
          //         height: 7,
          //       ),
          //       Container(
          //         decoration: BoxDecoration(
          //             border: Border.all(color: Colors.indigo),
          //             color: Colors.grey[50],
          //             shape: BoxShape.rectangle,
          //             borderRadius: BorderRadius.all(Radius.circular(5.0))),
          //         padding: EdgeInsets.all(5.0),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: <Widget>[
          //             Column(
          //               children: <Widget>[
          //                 Container(
          //                   decoration: indigoContainer,
          //                   child: Theme(
          //                     data: ThemeData(
          //                       unselectedWidgetColor: Colors.white,
          //                       accentColor: Colors.grey[50],
          //                     ),
          //                     child: ExpansionTile(
          //                       //key: PageStorageKey(this.widget.headerTitle),
          //                       initiallyExpanded: false,
          //                       title: Row(
          //                         children: <Widget>[
          //                           Text(
          //                             "Address",
          //                             style: TextStyle(
          //                                 color: Colors.white, fontSize: 15),
          //                           ),
          //                           SizedBox(width: 5),
          //                           Icon(
          //                             Icons.info,
          //                             color: Colors.white,
          //                           ),
          //                         ],
          //                       ),
          //                       backgroundColor: Colors.indigo,

          //                       children: <Widget>[
          //                         new Container(
          //                           width:
          //                               MediaQuery.of(context).size.width * .94,
          //                           decoration: BoxDecoration(
          //                               border:
          //                                   Border.all(color: Colors.indigo),
          //                               color: Colors.grey[50],
          //                               shape: BoxShape.rectangle,
          //                               borderRadius: BorderRadius.all(
          //                                   Radius.circular(5.0))),
          //                           padding: EdgeInsets.all(2.0),
          //                           child: Expanded(
          //                             child: Text(
          //                                 'The address is using the current location, and same will be used by customers when searching your location.',
          //                                 style: lightSubTextStyle),
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             Column(
          //               children: <Widget>[
          //                 RaisedButton(
          //                   elevation: 20,
          //                   color: highlightColor,
          //                   splashColor: Colors.orange,
          //                   textColor: Colors.white,
          //                   // shape: RoundedRectangleBorder(
          //                   //     side: BorderSide(color: Colors.orange)),
          //                   child: Text('Use current location'),
          //                   onPressed: _getCurrLocation,
          //                 ),
          //                 adrsField1,
          //                 landmarkField2,
          //                 localityField,
          //                 cityField,
          //                 stateField,
          //                 pinField,
          //                 countryField,
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //       SizedBox(
          //         height: 7,
          //       ),
          //       Container(
          //         decoration: BoxDecoration(
          //             border: Border.all(color: Colors.indigo),
          //             color: Colors.grey[50],
          //             shape: BoxShape.rectangle,
          //             borderRadius: BorderRadius.all(Radius.circular(5.0))),
          //         padding: EdgeInsets.all(5.0),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: <Widget>[
          //             Column(
          //               children: <Widget>[
          //                 Container(
          //                   decoration: indigoContainer,
          //                   child: Theme(
          //                     data: ThemeData(
          //                       unselectedWidgetColor: Colors.white,
          //                       accentColor: Colors.grey[50],
          //                     ),
          //                     child: ExpansionTile(
          //                       //key: PageStorageKey(this.widget.headerTitle),
          //                       initiallyExpanded: false,
          //                       title: Row(
          //                         children: <Widget>[
          //                           Text(
          //                             "Contact Person",
          //                             style: TextStyle(
          //                                 color: Colors.white, fontSize: 15),
          //                           ),
          //                           SizedBox(width: 5),
          //                           Icon(
          //                             Icons.info,
          //                             color: Colors.white,
          //                           ),
          //                         ],
          //                       ),
          //                       backgroundColor: Colors.indigo,

          //                       children: <Widget>[
          //                         new Container(
          //                           width:
          //                               MediaQuery.of(context).size.width * .94,
          //                           decoration: BoxDecoration(
          //                               border:
          //                                   Border.all(color: Colors.indigo),
          //                               color: Colors.grey[50],
          //                               shape: BoxShape.rectangle,
          //                               borderRadius: BorderRadius.all(
          //                                   Radius.circular(5.0))),
          //                           padding: EdgeInsets.all(2.0),
          //                           child: Expanded(
          //                             child: Text(
          //                                 'The perosn who can be contacted for any queries regarding your services.',
          //                                 style: lightSubTextStyle),
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             Container(
          //                 child: Column(
          //               children: <Widget>[
          //                 ctNameField,
          //                 ctEmpIdField,
          //                 ctPhn1Field,
          //                 ctPhn2Field,
          //                 daysOffField,
          //                 Divider(
          //                   thickness: .7,
          //                   color: Colors.grey[600],
          //                 ),
          //                 ctAvlFromTimeField,
          //                 ctAvlTillTimeField,
          //                 new FormField(
          //                   builder: (FormFieldState state) {
          //                     return InputDecorator(
          //                       decoration: InputDecoration(
          //                         icon: const Icon(Icons.person),
          //                         labelText: 'Role ',
          //                       ),
          //                       child: new DropdownButtonHideUnderline(
          //                         child: new DropdownButton(
          //                           value: _role,
          //                           isDense: true,
          //                           onChanged: (newValue) {
          //                             setState(() {
          //                               // newContact.favoriteColor = newValue;
          //                               _role = newValue;
          //                               state.didChange(newValue);
          //                             });
          //                           },
          //                           items: roleTypes.map((role) {
          //                             return DropdownMenuItem(
          //                               value: role,
          //                               child: new Text(
          //                                 role.toString(),
          //                                 style: textInputTextStyle,
          //                               ),
          //                             );
          //                           }).toList(),
          //                         ),
          //                       ),
          //                     );
          //                   },
          //                 ),
          //               ],
          //             )),

          //             // Column(children: <Widget>[
          //             //   Center(
          //             //     child: FloatingActionButton(
          //             //       backgroundColor: highlightColor,
          //             //       child: Icon(Icons.add, color: Colors.white),
          //             //       splashColor: highlightColor,
          //             //       onPressed: () {
          //             //         // addPerson();
          //             //       },
          //             //     ),
          //             //   ),
          //             //   // _createChildren(),
          //             //   // Expanded(
          //             //   //     child: new ListView.builder(
          //             //   //         itemCount: contactList.length,
          //             //   //         itemBuilder: (BuildContext ctxt, int index) {
          //             //   //           return new Text(contactList[index].perName);
          //             //   //         })),
          //             // ]),
          //           ],
          //         ),
          //       ),
          //       Container(
          //         padding: EdgeInsets.all(8),
          //         alignment: Alignment.center,
          //         // decoration: BoxDecoration(
          //         //     borderRadius: BorderRadius.all(Radius.circular(5.0))),
          //         //height: MediaQuery.of(context).size.width * .2,
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //           children: <Widget>[
          //             RaisedButton(
          //               color: highlightColor,
          //               splashColor: Colors.orange,
          //               onPressed: () {
          //                 if (_formKey.currentState.validate()) {
          //                   _formKey.currentState.save();
          //                   saveEntityDetails(entity);
          //                   Navigator.push(
          //                       context,
          //                       MaterialPageRoute(
          //                           builder: (context) =>
          //                               ChildEntityDetailsPage(
          //                                   entity: this.entity)));
          //                 }
          //               },
          //               child: Column(
          //                 children: <Widget>[
          //                   Text(
          //                     'Save & Submit',
          //                     style: buttonMedTextStyle,
          //                   ),
          //                   Text(
          //                     'For now, rest of details later.',
          //                     style: buttonXSmlTextStyle,
          //                   ),
          //                 ],
          //               ),
          //             ),
          //             RaisedButton(
          //               color: highlightColor,
          //               splashColor: Colors.orange,
          //               onPressed: () {
          //                 //  if (_formKey.currentState.validate()) {
          //                 //_formKey.currentState.save();
          //                 saveEntityDetails(entity);
          //                 Navigator.push(
          //                     context,
          //                     MaterialPageRoute(
          //                         builder: (context) => ChildEntityDetailsPage(
          //                             entity: this.entity)));
          //                 // }
          //               },
          //               child: Column(
          //                 children: <Widget>[
          //                   Text(
          //                     'Save & Next',
          //                     style: buttonMedTextStyle,
          //                   ),
          //                   Text(
          //                     'Fill services detail now.',
          //                     style: buttonXSmlTextStyle,
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ),
        // bottomNavigationBar: buildBottomItems()
      ),
    );
  }
}
