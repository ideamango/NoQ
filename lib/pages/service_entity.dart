import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/manage_child_entity_details_page.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';

class ChildEntityRow extends StatefulWidget {
  final MetaEntity childEntity;

  ChildEntityRow({Key key, @required this.childEntity}) : super(key: key);
  @override
  State<StatefulWidget> createState() => new ChildEntityRowState();
}

class ChildEntityRowState extends State<ChildEntityRow> {
  Entity entity;
  MetaEntity _metaEntity;
  GlobalState _state;
  bool _initCompleted = false;
  // Map<String, Entity> _entityMap;

  @override
  void initState() {
    super.initState();
    _metaEntity = widget.childEntity;
    // _entityMap = widget.entityMap;
    GlobalState.getGlobalState().then((value) {
      _state = value;
      if (this.mounted) {
        setState(() {
          _initCompleted = true;
        });
      } else {
        _initCompleted = false;
      }
    });
  }

  Future<void> getEntity(String entityId) async {
    // if (_entityMap != null) {
    //   if (_entityMap.length != 0) {
    //     if (_entityMap.containsKey(entityId))
    //       entity = _entityMap[entityId];
    //     else {
    //       entity = await EntityService().getEntity(entityId);
    //     }
    //   }
    // }
    // if (entity == null) {
    //   entity = await EntityService().getEntity(entityId);
    //   print(entity.name);
    // }
  }

  @override
  Widget build(BuildContext context) {
    showServiceForm() {
      //get Entity for this metaEntity
      // if Entity is inentityMap it means its a new entity and is not created yet,
      // else fetch from DB.
      //TODO Sumant - use state for entity get, put
      _state.getEntity(_metaEntity.entityId).then((value) {
        Navigator.of(context).pop();
        Navigator.of(context).push(PageAnimation.createRoute(
            ManageChildEntityDetailsPage(childEntity: value.item1)));
      });
    }

    generateLinkAndShareWithParams(String entityId, String name) async {
      String msgTitle = name + entityShareByOwnerHeading;
      String msgBody = entityShareMessage;

      Utils.generateLinkAndShare(entityId, msgTitle, msgBody);
      // var dynamicLink =
      //     await Utils.createDynamicLinkWithParams(entityId, msgTitle, msgBody);
      // print("Dynamic Link: $dynamicLink");

      // String _dynamicLink =
      //     Uri.https(dynamicLink.authority, dynamicLink.path).toString();
      // // dynamicLink has been generated. share it with others to use it accordingly.
      // Share.share(dynamicLink.toString());
    }

    share() {
      Entity en;
      _state.getEntity(_metaEntity.entityId).then((value) {
        en = value.item1;
        if (en == null) {
          Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 4),
              missingInfoForShareStr, missingInfoForShareSubStr);
        } else
          generateLinkAndShareWithParams(
              _metaEntity.entityId, _metaEntity.name);
      });
    }

    shareQr() {
      Entity en;

      _state.getEntity(_metaEntity.entityId).then((value) {
        en = value.item1;
        if (en == null) {
          Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 4),
              missingInfoForShareStr, missingInfoForShareSubStr);
        } else
          Navigator.of(context).push(PageAnimation.createRoute(GenerateScreen(
              entityId: _metaEntity.entityId, entityName: _metaEntity.name)));
      });
    }

    return Container(
      // height: MediaQuery.of(context).size.width * .55,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: Column(
        //   mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  print("Opening manage details on container click");
                  showServiceForm();
                },
                child: Container(
                  //padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  width: MediaQuery.of(context).size.width * .5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        (_metaEntity.name != null)
                            ? _metaEntity.name
                            : "Untitled",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.blueGrey[700], fontSize: 17),
                      ),
                      Text(
                        _metaEntity.type,
                        style: labelTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  width: MediaQuery.of(context).size.width * .36,
                  //   height: MediaQuery.of(context).size.width * .08,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(0),
                        margin: EdgeInsets.all(5),
                        height: 28.0,
                        width: 28.0,
                        child: IconButton(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            alignment: Alignment.center,
                            highlightColor: Colors.orange[300],
                            icon: ImageIcon(
                              AssetImage('assets/qrcode.png'),
                              size: 25,
                              color: primaryIcon,
                            ),
                            onPressed: () {
                              shareQr();
                            }),
                      ),
                      horizontalSpacer,
                      Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          height: 25.0,
                          width: 28.0,
                          child: IconButton(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            alignment: Alignment.center,
                            highlightColor: Colors.orange[300],
                            icon: Icon(Icons.share),
                            iconSize: 25,
                            onPressed: () {
                              share();
                            },
                          )),
                    ],
                  )),
            ],
          ),
          //  horizontalSpacer,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                //margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                height: 30,
                width: MediaQuery.of(context).size.width * .42,
                child: RaisedButton(
                  elevation: 7,
                  color: btnColor,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  splashColor: highlightColor,
                  child: Text(
                    'Manage Details',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  // Text(
                  //   (_metaEntity.name != null)
                  //       ? (_metaEntity.name)
                  //       : (_metaEntity.type),
                  //   style: labelTextStyle,
                  // ),

                  //Icon(Icons.arrow_forward),

                  onPressed: () {
                    print("To Add details page");
                    showServiceForm();
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
