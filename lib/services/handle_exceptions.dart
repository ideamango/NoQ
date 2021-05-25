import 'package:LESSs/db/exceptions/access_denied_exception.dart';
import 'package:LESSs/db/exceptions/entity_deletion_denied_child_exists_exception.dart';
import 'package:LESSs/db/exceptions/entity_does_not_exists_exception.dart';
import 'package:LESSs/db/exceptions/not_admin_parent_entity_exception.dart';
import 'package:LESSs/utils.dart';
import 'package:flutter/material.dart';

class ErrorsUtil {
  static handleDeleteEntityErrors(BuildContext context, Exception error) {
    switch (error.runtimeType) {
      case EntityDoesNotExistsException:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            (error as EntityDoesNotExistsException).cause, "");
        break;
      case EntityDeletionDeniedChildExistsException:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            (error as EntityDeletionDeniedChildExistsException).cause, "");

        break;
      case NotAdminParentEntityException:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            (error as NotAdminParentEntityException).cause, "");

        break;
      case AccessDeniedException:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            (error as AccessDeniedException).cause, "");

        break;
      default:
        Utils.showMyFlushbar(
            context, Icons.error, Duration(seconds: 5), error.toString(), "");
        break;
    }
  }
}
