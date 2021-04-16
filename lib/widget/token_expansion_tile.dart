import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/entity_token_list_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';

class TokenExpansionTile extends StatefulWidget {
  final String slotKey;
  final TokenStats stats;
  final DateTime date;
  final DateDisplayFormat format;
  final MetaEntity metaEntity;
  TokenExpansionTile(
      {Key key,
      @required this.slotKey,
      @required this.stats,
      @required this.date,
      @required this.format,
      @required this.metaEntity})
      : super(key: key);
  @override
  _TokenExpansionTileState createState() => _TokenExpansionTileState();
}

class _TokenExpansionTileState extends State<TokenExpansionTile> {
  GlobalState _gs;
  bool initCompleted = false;
  List<UserToken> listOfTokens = new List<UserToken>();
  void initState() {
    super.initState();

    getGlobalState().whenComplete(() {
      getTokenList(widget.slotKey, widget.date, widget.format).then((retVal) {
        if (this.mounted) {
          setState(() {
            initCompleted = true;
          });
        } else
          initCompleted = true;
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  buildChildItem(UserToken token) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Card(
          child: Row(
        children: [
          Container(
              width: MediaQuery.of(context).size.width * .4,
              padding: EdgeInsets.all(8),
              child: Text(token.parent.userId,
                  style: TextStyle(
                      //fontFamily: "RalewayRegular",
                      color: Colors.blueGrey[800],
                      fontSize: 13))),
          if (token.bookingFormName != null)
            Container(
                width: MediaQuery.of(context).size.width * .4,
                padding: EdgeInsets.all(8),
                child: Text(token.bookingFormName,
                    style: TextStyle(
                        //fontFamily: "RalewayRegular",
                        color: Colors.blueGrey[800],
                        fontSize: 13))),
        ],
      )),
    );
  }

  Future<void> getTokenList(
      String slot, DateTime date, DateDisplayFormat format) async {
    String slotId;
    String dateTime = date.year.toString() +
        '~' +
        date.month.toString() +
        '~' +
        date.day.toString() +
        '#' +
        slot.replaceAll(':', '~');
    print(dateTime);
    //Build slotId using info we have entityID#YYYY~MM~DD#HH~MM

    slotId = widget.metaEntity.entityId + "#" + dateTime;
    //6b8af7a0-9ce7-11eb-b97b-2beeb21da0d7#15~4~2021#11~20

    _gs.getTokenService().getAllTokensForSlot(slotId).then((list) {
      listOfTokens = list;
      setState(() {});
    });
  }

  Widget buildExpansionTile() {
    String timeSlot = widget.slotKey.replaceAll('~', ':');

    return Container(
      // height: 500,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeSlot,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    AutoSizeText(
                      "Booked - " +
                          widget.stats.numberOfTokensCreated.toString() +
                          ", ",
                      minFontSize: 8,
                      maxFontSize: 13,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    AutoSizeText(
                      "Cancelled - " +
                          widget.stats.numberOfTokensCancelled.toString(),
                      minFontSize: 8,
                      maxFontSize: 13,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    IconButton(
                      icon: Icon(Icons.view_column),
                      onPressed: () {
                        setState(() {});
                      },
                    )
                  ],
                ),
              ],
            ),

            (listOfTokens.length != 0)
                ? Column(
                    children: [
                      Text("${listOfTokens.length.toString()}"),
                    ],
                  )
                // ListView.builder(
                //     scrollDirection: Axis.horizontal,
                //     itemCount: listOfTokens.length,
                //     shrinkWrap: true,
                //     itemBuilder: (context, index) {
                //       return Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[buildChildItem(listOfTokens[index])],
                //       );
                //     },
                //   )
                : Text("No Tokens"),

            //initialData: getDefaultTokenListWidget(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (initCompleted)
      return buildExpansionTile();
    else
      Container(child: showCircularProgress());
  }
}
