//Post selected Slot to server
//Cancel Slot
//List Slots for particular store

import '../db/db_model/entity_slots.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/slot.dart';
import '../db/db_model/user_token.dart';

import '../global_state.dart';

import '../tuple.dart';
import '../utils.dart';

Future<List<Slot>> getSlotsListForEntity(
    MetaEntity entity, DateTime dateTime) async {
  EntitySlots entitySlots;

  GlobalState gs = await GlobalState.getGlobalState();
  entitySlots =
      await gs.getTokenService().getEntitySlots(entity.entityId, dateTime);

  return Utils.getSlots(entitySlots, entity, dateTime);
}

Future<UserToken> bookSlotForStore(
    MetaEntity meta, Slot slot, bool enableVideoChat) async {
//TODO: Have Entity object here, either pass entity object to generateToken() or create metaEntity and pass to this method.

  GlobalState gs = await GlobalState.getGlobalState();
  UserTokens tokens;
  Tuple<UserTokens, TokenCounter> tuple =
      await gs.addBooking(meta, slot, enableVideoChat);
  tokens = tuple.item1;

  gs.getNotificationService().registerTokenNotification(tokens);

  return tokens.tokens.last;
}

Future<bool> cancelToken(UserToken token) async {
  GlobalState gs = await GlobalState.getGlobalState();

  bool returnVal =
      await gs.cancelBooking(token.parent.getTokenId(), token.number);

  gs.getNotificationService().unRegisterTokenNotification(token);

  return returnVal;
}

Future<bool> updateToken(UserTokens tokens) async {
  GlobalState gs = await GlobalState.getGlobalState();

  bool result;
  try {
    result = await gs.getTokenService().updateToken(tokens);
    print('Updated token successfully');
  } catch (e) {
    print(e.toString());
  }
  return result;
}
