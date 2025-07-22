part of 'group_bloc.dart';

final class GroupState extends Equatable {
  const GroupState({
    required this.getGroupsFailureOrGroups,
    required this.groupsOption,
    required this.getGroupRequestsFailureOrRequests,
    required this.requestsOption,
    required this.sendingAddGroupReq,
    required this.sendAddGroupReqFailureOrRequests,
    required this.isSendingReqAnswer,
    this.sendAddGroupReqErrorMessage,
    this.isFetchingRequests = false,
    this.isFetchingData = false,
  });

  factory GroupState.initial() {
    return GroupState(
      getGroupsFailureOrGroups: none(),
      groupsOption: none(),
      getGroupRequestsFailureOrRequests: none(),
      sendAddGroupReqFailureOrRequests: none(),
      requestsOption: none(),
      isSendingReqAnswer: -1,
      sendAddGroupReqErrorMessage: null,
      isFetchingRequests: false,
      sendingAddGroupReq: false,
      isFetchingData: false,
    );
  }

  final Option<FailureOr<KtList<GroupData>>> getGroupsFailureOrGroups;
  final Option<KtList<GroupData>> groupsOption;
  final Option<FailureOr<KtList<GroupRequestData>>>
  getGroupRequestsFailureOrRequests;
  final Option<KtList<GroupRequestData>> requestsOption;
  final Option<bool> sendAddGroupReqFailureOrRequests;
  final bool isFetchingData;
  final bool isFetchingRequests;
  final bool sendingAddGroupReq;
  final int isSendingReqAnswer;
  final String? sendAddGroupReqErrorMessage;

  GroupState copyWith({
    Option<FailureOr<KtList<GroupData>>>? getGroupsFailureOrGroups,
    Option<KtList<GroupData>>? groupsOption,
    Option<FailureOr<KtList<GroupRequestData>>>?
    getGroupRequestsFailureOrRequests,
    Option<KtList<GroupRequestData>>? requestsOption,
    Option<bool>? sendAddGroupReqFailureOrRequests,
    bool? isFetchingData,
    bool? isFetchingRequests,
    bool? sendingAddGroupReq,
    int? isSendingReqAnswer,
    String? sendAddGroupReqErrorMessage,
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
      sendAddGroupReqFailureOrRequests:
          sendAddGroupReqFailureOrRequests ??
          this.sendAddGroupReqFailureOrRequests,
      isFetchingRequests: isFetchingRequests ?? this.isFetchingRequests,
      sendingAddGroupReq: sendingAddGroupReq ?? this.sendingAddGroupReq,
      isSendingReqAnswer: isSendingReqAnswer ?? this.isSendingReqAnswer,
      sendAddGroupReqErrorMessage:
          sendAddGroupReqErrorMessage ?? this.sendAddGroupReqErrorMessage,
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
    sendingAddGroupReq, // <-- ekle!
    sendAddGroupReqFailureOrRequests, // <-- ekle!
    isSendingReqAnswer,
    sendAddGroupReqErrorMessage ?? '',
  ];
}
