part of 'group_bloc.dart';

final class GroupState extends Equatable {
  const GroupState({
    required this.getGroupsFailureOrGroups,
    required this.groupsOption,
    required this.getGroupRequestsFailureOrRequests,
    required this.requestsOption,
    this.isFetchingData = false,
  });

  factory GroupState.initial() {
    return GroupState(
      getGroupsFailureOrGroups: none(),
      groupsOption: none(),
      getGroupRequestsFailureOrRequests: none(),
      requestsOption: none(),
      isFetchingData: false,
    );
  }

  final Option<FailureOr<KtList<GroupData>>> getGroupsFailureOrGroups;
  final Option<KtList<GroupData>> groupsOption;
  final Option<FailureOr<KtList<GroupRequestData>>> getGroupRequestsFailureOrRequests;
  final Option<KtList<GroupRequestData>> requestsOption;
  final bool isFetchingData;

  GroupState copyWith({
    Option<FailureOr<KtList<GroupData>>>? getGroupsFailureOrGroups,
    Option<KtList<GroupData>>? groupsOption,
    Option<FailureOr<KtList<GroupRequestData>>>? getGroupRequestsFailureOrRequests,
    Option<KtList<GroupRequestData>>? requestsOption,
    bool? isFetchingData,
  }) {
    return GroupState(
      getGroupsFailureOrGroups:
          getGroupsFailureOrGroups ?? this.getGroupsFailureOrGroups,
      groupsOption: groupsOption ?? this.groupsOption,
      getGroupRequestsFailureOrRequests:
          getGroupRequestsFailureOrRequests ?? this.getGroupRequestsFailureOrRequests,
      requestsOption: requestsOption ?? this.requestsOption,
      isFetchingData: isFetchingData ?? this.isFetchingData,
    );
  }

  bool get hasFetchedGroupsSucceeded {
    return getGroupsFailureOrGroups.fold(
      () => false,
      (either) => either.isRight(),
    );
  }
  bool get hasFetchedRequestsSucceeded {
    return getGroupRequestsFailureOrRequests.fold(
      () => false,
      (either) => either.isRight(),
    );
  }

  @override
  List<Object> get props => [getGroupsFailureOrGroups, isFetchingData];
}
