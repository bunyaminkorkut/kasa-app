part of 'group_bloc.dart';

final class GroupState extends Equatable {
  const GroupState({
    required this.getGroupsFailureOrGroups,
    required this.groupsOption,
    required this.getGroupRequestsFailureOrRequests,
    required this.requestsOption,
    required this.isSendingReqAnswer,
    this.isFetchingRequests = false,
    this.isFetchingData = false,
  });

  factory GroupState.initial() {
    return GroupState(
      getGroupsFailureOrGroups: none(),
      groupsOption: none(),
      getGroupRequestsFailureOrRequests: none(),
      requestsOption: none(),
      isSendingReqAnswer: -1,
      isFetchingRequests: false,
      isFetchingData: false,
    );
  }

  final Option<FailureOr<KtList<GroupData>>> getGroupsFailureOrGroups;
  final Option<KtList<GroupData>> groupsOption;
  final Option<FailureOr<KtList<GroupRequestData>>>
  getGroupRequestsFailureOrRequests;
  final Option<KtList<GroupRequestData>> requestsOption;
  final bool isFetchingData;
  final bool isFetchingRequests;
  final int isSendingReqAnswer; 

  GroupState copyWith({
    Option<FailureOr<KtList<GroupData>>>? getGroupsFailureOrGroups,
    Option<KtList<GroupData>>? groupsOption,
    Option<FailureOr<KtList<GroupRequestData>>>?
    getGroupRequestsFailureOrRequests,
    Option<KtList<GroupRequestData>>? requestsOption,
    bool? isFetchingData,
    bool? isFetchingRequests,
    int? isSendingReqAnswer,
  }) {
    return GroupState(
      getGroupsFailureOrGroups:
          getGroupsFailureOrGroups ?? this.getGroupsFailureOrGroups,
      groupsOption: groupsOption ?? this.groupsOption,
      getGroupRequestsFailureOrRequests:
          getGroupRequestsFailureOrRequests ??
          this.getGroupRequestsFailureOrRequests,
      requestsOption: requestsOption ?? this.requestsOption,
      isFetchingData: isFetchingData ?? this.isFetchingData,
      isFetchingRequests: isFetchingRequests ?? this.isFetchingRequests,
      isSendingReqAnswer: isSendingReqAnswer ?? this.isSendingReqAnswer,
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
  List<Object> get props => [
    getGroupsFailureOrGroups,
    groupsOption,
    getGroupRequestsFailureOrRequests,
    requestsOption,
    isFetchingData,
    isFetchingRequests,
    isSendingReqAnswer,
  ];
}
