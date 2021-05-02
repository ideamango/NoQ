enum EntityRole {
  //Admin can Read-Write all details/parameters for an Entity
  //Manager cannot modify details of an entity(and child-entity) and employee. Only View mode
  //Manager can View/modify Applications, Forms, Tokens of an entity(and child-entity).
  //Executive has read-only for Tokens of an entity(and child-entity). No permission for other details/parameters for an Entity(or child-entity)

  Admin,
  Manager,
  Executive
}
