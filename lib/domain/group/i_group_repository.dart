

import 'package:kasa_app/domain/core/failure_or.dart';
import 'package:kasa_app/domain/group/accept_data.dart';
import 'package:kasa_app/domain/group/create_expense_data.dart';
import 'package:kasa_app/domain/group/expense_data.dart';
import 'package:kasa_app/domain/group/group_data.dart';
import 'package:kasa_app/domain/group/request_data.dart';
import 'package:kt_dart/collection.dart';

abstract class IGroupRepository {
  Future<FailureOr<KtList<GroupData>>> createGroup({required String jwtToken,required String groupName});
  Future<FailureOr<KtList<GroupData>>> getGroups({required String jwtToken});
  Future<FailureOr<KtList<GroupRequestData>>> getRequests({required String jwtToken});
  Future<FailureOr<AcceptResponse>> acceptRequest({required String jwtToken, required int requestId});
  Future<FailureOr<KtList<GroupRequestData>>> rejectRequest({required String jwtToken, required int requestId});
  Future<FailureOr<GroupData>> sendAddGroupRequest({required String jwtToken, required int groupId, required String memberEmail});
  Future<FailureOr<Expense>> createExpense({required String jwtToken, required CreateExpenseData expenseData});
  
}
