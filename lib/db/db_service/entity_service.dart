import 'package:firebase_auth/firebase_auth.dart';
import 'package:noq/db/db_model/entity.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> upsertEntity(Entity entity) {
    //validations
    //
  }

  Future<bool> deleteEntity(String entityId) {}

  Future<bool> addToParentEntity(String childEntityId, String parentEntityId) {}

  Future<bool> addToParentEntity(Entity childEntity, String parentEntityId) {}

  Future<bool> assignAdmin(
    String entityId,
    String phone,
    String firstName,
    String lastName,
  ) {}

  Future<bool> removeAdmin(String entityId, String phone) {}

  Future<Entity> searchByName(
      String name, double lat, double lon, int distance, int pageSize) {}

  Future<Entity> searchByType(
      String type, double lat, double lon, int distance, pageSize) {}
}
