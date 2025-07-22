import 'package:kasa_app/domain/group/group_data.dart';
import 'package:kasa_app/domain/group/request_data.dart';
import 'package:kt_dart/collection.dart';

class AcceptResponse {
  final KtList<GroupRequestData> requests;
  final KtList<GroupData> groups;

  AcceptResponse({required this.requests, required this.groups});

  factory AcceptResponse.fromMap(Map<String, dynamic> map) {
    final requests = (map['requests'] as List<dynamic>)
        .map((e) => GroupRequestData.fromMap(e))
        .toList();

    final groups = (map['groups'] as List<dynamic>)
        .map((e) => GroupData.fromMap(e))
        .toList();

    return AcceptResponse(
      requests: KtList.from(requests),
      groups: KtList.from(groups),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requests': requests.map((e) => e.toMap()).toList(),
      'groups': groups.map((e) => e.toMap()).toList(),
    };
  }

  List<Object?> get props => [requests, groups];
}
