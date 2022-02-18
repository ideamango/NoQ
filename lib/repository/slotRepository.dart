//Post selected Slot to server
//Cancel Slot
//List Slots for particular store

import 'package:LESSs/triplet.dart';

import '../db/db_model/entity_slots.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/slot.dart';
import '../db/db_model/user_token.dart';

import '../global_state.dart';

import '../tuple.dart';
import '../utils.dart';

Future<Tuple<EntitySlots, List<Slot>>> getSlotsListForEntity(
    MetaEntity entity, DateTime dateTime) async {
  EntitySlots? entitySlots;

  GlobalState gs = await (GlobalState.getGlobalState() as FutureOr<GlobalState>);
  entitySlots =
      await gs.getTokenService()!.getEntitySlots(entity.entityId!, dateTime);
  List<Slot> slots = Utils.getSlots(entitySlots, entity, dateTime);

  return new Tuple(item1: entitySlots, item2: slots);
}

// Future<UserToken> bookSlotForStore(
//     MetaEntity meta, Slot slot, bool enableVideoChat) async {
// //TODO: Have Entity object here, either pass entity object to generateToken() or create metaEntity and pass to this method.

//   GlobalState gs = await GlobalState.getGlobalState();
//   UserTokens tokens;
//   Triplet<UserTokens, TokenCounter, EntitySlots> tuple =
//       await gs.addBooking(meta, slot, enableVideoChat);
//   tokens = tuple.item1;

//   gs.getNotificationService().registerTokenNotification(tokens);

//   return tokens.tokens.last;
// }

// Future<bool> cancelToken(UserToken token) async {
//   GlobalState gs = await GlobalState.getGlobalState();

//   bool returnVal =
//       await gs.cancelBooking(token.parent.getTokenId(), token.number);

//   gs.getNotificationService().unRegisterTokenNotification(token);

//   return returnVal;
// }

Future<bool?> updateToken(UserTokens tokens) async {
  GlobalState gs = await (GlobalState.getGlobalState() as FutureOr<GlobalState>);

  bool? result;
  try {
    result = await gs.getTokenService()!.updateToken(tokens);
    print('Updated token successfully');
  } catch (e) {
    print(e.toString());
  }
  return result;
}
