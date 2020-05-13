import 'package:flutter/material.dart';

class ManagerDetailsPage extends StatefulWidget {
  @override
  _ManagerDetailsPageState createState() => _ManagerDetailsPageState();
}

class _ManagerDetailsPageState extends State<ManagerDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Add TextFormFields and RaisedButton here.

                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      prefixText: '+91',
                    ),
                    controller: controller,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter name';
                      }
                      print("Prinbtinbsgdauytdsa");
                      print(value);
                      return value;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        print(controller.selection);
                        // Validate returns true if the form is valid, otherwise false.
                        if (_formKey.currentState.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.

                          // Scaffold.of(context).showSnackBar(
                          //     SnackBar(content: Text('Processing Data')));
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ])));
  }
}
