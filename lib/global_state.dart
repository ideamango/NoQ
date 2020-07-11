import 'package:noq/db/db_model/configurations.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/user.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/configurations_service.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/utils.dart';
import 'db/db_service/user_service.dart';

class GlobalState {
  User currentUser;
  Configurations conf;
  List<UserToken> bookings;
  List<Entity> pastSearches;

  static GlobalState _gs;

  GlobalState._();

  GlobalState.withValues(
      {this.currentUser, this.conf, this.bookings, this.pastSearches});

  static Future<GlobalState> getGlobalState() async {
    if (_gs == null) {
      _gs = await readData();

      if (_gs == null) {
        _gs = new GlobalState._();
      }
      _gs.currentUser = await UserService().getCurrentUser();
      if (Utils.isNullOrEmpty(_gs.currentUser.favourites))
        _gs.currentUser.favourites = new List<MetaEntity>();
      _gs.conf = await ConfigurationService().getConfigurations();
    }
    return _gs;
  }

  Future<bool> addFavourite(MetaEntity me) async {
    if (_gs.currentUser.favourites
            .firstWhere((element) => element.entityId == me.entityId) !=
        null) _gs.currentUser.favourites.add(me);
    saveGlobalState();
    return true;
  }

  Future<bool> removeFavourite(MetaEntity me) async {
    _gs.currentUser.favourites
        .removeWhere((element) => element.entityId == me.entityId);
    saveGlobalState();
    return true;
  }

  Future<bool> updateSearchResults(List<Entity> list) async {
    _gs.pastSearches = list;

    saveGlobalState();
    return true;
  }

  addBooking() async {}

  cancelBooking() async {}

  static Future<void> saveGlobalState() async {
    writeData(_gs);
  }

  Map<String, dynamic> toJson() => {
        'currentUser': currentUser.toJson(),
        'conf': conf.toJson(),
        'bookings': convertBookingsListToJson(this.bookings),
        'pastSearches': convertPastSearchesListToJson(this.pastSearches)
      };

  static GlobalState fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new GlobalState.withValues(
      currentUser: User.fromJson(json['currentUser']),
      conf: Configurations.fromJson(json['conf']),
      bookings: convertToBookingsFromJson(json['bookings']),
      pastSearches: convertToSearchListFromJson(json['pastSearches']),
    );
  }

  List<dynamic> convertBookingsListToJson(List<UserToken> tokens) {
    List<dynamic> bookingListJson = new List<dynamic>();
    if (tokens == null) return bookingListJson;
    for (UserToken token in tokens) {
      bookingListJson.add(token.toJson());
    }
    return bookingListJson;
  }

  List<dynamic> convertPastSearchesListToJson(List<Entity> metaEntities) {
    List<dynamic> searchListJson = new List<dynamic>();
    if (metaEntities == null) return searchListJson;
    for (Entity meta in metaEntities) {
      searchListJson.add(meta.toJson());
    }
    return searchListJson;
  }

  static List<Entity> convertToSearchListFromJson(
      List<dynamic> metaEntityJson) {
    List<Entity> metaEntities = new List<Entity>();

    if (metaEntityJson != null) {
      for (Map<String, dynamic> json in metaEntityJson) {
        Entity metaEnt = Entity.fromJson(json);
        metaEntities.add(metaEnt);
      }
    }
    return metaEntities;
  }

  static List<UserToken> convertToBookingsFromJson(List<dynamic> bookingsJson) {
    List<UserToken> bookings = new List<UserToken>();
    if (bookingsJson != null) {
      for (Map<String, dynamic> json in bookingsJson) {
        UserToken token = UserToken.fromJson(json);
        bookings.add(token);
      }
    }
    return bookings;
  }
}
