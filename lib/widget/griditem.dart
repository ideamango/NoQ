import 'package:flutter/material.dart';
import 'package:noq/services/create_form_fields.dart';
import 'package:noq/style.dart';

class GridItem extends StatefulWidget {
  final Key key;
  final Item item;
  final ValueChanged<bool> isSelected;

  GridItem({this.item, this.isSelected, this.key});

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      },
      child: Container(
      //  width: 100,
        child: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            Container(
              decoration: new BoxDecoration(
                  border: Border.all(color: Colors.blueGrey[200]),
                  shape: BoxShape.rectangle,
                  color: Colors.cyan[50],
                  borderRadius: BorderRadius.all(Radius.circular(0.0))),
              padding: EdgeInsets.all(0),
              margin: EdgeInsets.all(0),
              height: 10,
              //width: double.infinity,
              child: Text(
                widget.item.text,
                style: textInputTextStyle,
              ),
              // Image.asset(
              //   widget.item.text,
              //   color: Colors.black.withOpacity(isSelected ? 0.9 : 0),
              //   colorBlendMode: BlendMode.color,
              // ),
            ),
            isSelected
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.orangeAccent[700].withOpacity(.7),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
