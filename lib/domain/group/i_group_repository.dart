

import 'package:kasa_app/domain/core/failure_or.dart';
import 'package:kasa_app/domain/group/group_data.dart';
import 'package:kasa_app/domain/group/request_data.dart';
import 'package:kt_dart/collection.dart';

abstract class IGroupRepository {
  Future<FailureOr<KtList<GroupData>>> getGroups({required String jwtToken});
  Future<FailureOr<KtList<GroupRequestData>>> getRequests({required String jwtToken});
}
