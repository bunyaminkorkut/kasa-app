import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:kasa_app/app_config.dart';
import 'package:kasa_app/core/errors/failure.dart';
import 'package:kasa_app/domain/core/failure_or.dart';
import 'package:kasa_app/domain/group/accept_data.dart';
import 'package:kasa_app/domain/group/create_expense_data.dart';
import 'package:kasa_app/domain/group/group_data.dart';
import 'package:kasa_app/domain/group/i_group_repository.dart';
import 'package:kasa_app/domain/group/request_data.dart';
import 'package:kt_dart/collection.dart';

class GroupService implements IGroupRepository {
  @override
  Future<FailureOr<KtList<GroupData>>> getGroups({
    required String jwtToken,
  }) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolveUri(
      Uri(path: '/groups'),
    ); // API endpoint for groups
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken', // Bearer eklendi
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      final groups = KtList.from(
        jsonResponse.map((group) => GroupData.fromMap(group)),
      );
      return right(groups);
    } else {
      return left(
        ServerFailure(
          'Failed to fetch groups: ${response.statusCode} - ${response.body}',
        ),
      );
    }
  }

  @override
  Future<FailureOr<KtList<GroupRequestData>>> getRequests({
    required String jwtToken,
  }) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolveUri(Uri(path: '/get-my-add-requests'));
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken', // Bearer eklendi
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      final requests = KtList.from(
        jsonResponse.map((group) => GroupRequestData.fromMap(group)),
      );
      return right(requests);
    } else {
      return left(
        ServerFailure(
          'Failed to fetch groups: ${response.statusCode} - ${response.body}',
        ),
      );
    }
  }

  @override
  Future<FailureOr<AcceptResponse>> acceptRequest({
    required String jwtToken,
    required int requestId,
  }) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolveUri(Uri(path: '/accept-add-request'));

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({'request_id': requestId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final acceptResponse = AcceptResponse.fromMap(jsonResponse);
      return right(acceptResponse);
    } else {
      return left(
        ServerFailure(
          'Failed to fetch groups: ${response.statusCode} - ${response.body}',
        ),
      );
    }
  }

  @override
  Future<FailureOr<KtList<GroupRequestData>>> rejectRequest({
    required String jwtToken,
    required int requestId,
  }) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolveUri(Uri(path: '/reject-add-request'));
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken', // Bearer eklendi
      },
      body: jsonEncode({'request_id': requestId}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      final requests = KtList.from(
        jsonResponse.map((group) => GroupRequestData.fromMap(group)),
      );
      return right(requests);
    } else {
      return left(
        ServerFailure(
          'Failed to fetch groups: ${response.statusCode} - ${response.body}',
        ),
      );
    }
  }

  @override
  Future<FailureOr<GroupData>> sendAddGroupRequest({
    required String jwtToken,
    required int groupId,
    required String memberEmail,
  }) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolveUri(Uri(path: '/send-add-group-request'));
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken', // Bearer eklendi
      },
      body: jsonEncode({
        "group_id": groupId.toString(),
        "added_member": memberEmail,
      }),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final requests = GroupData.fromMap(jsonResponse);

      return right(requests);
    } else {
      return left(ServerFailure('${response.body}'));
    }
  }

    @override
  Future<FailureOr<GroupData>> createExpense({
    required String jwtToken,
    required CreateExpenseData expenseData,
  }) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolveUri(Uri(path: '/add-group-expense'));
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken', // Bearer eklendi
      },
      body: jsonEncode(expenseData.toJson()),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final requests = GroupData.fromMap(jsonResponse);

      return right(requests);
    } else {
      return left(ServerFailure('${response.body}'));
    }
  }
}
