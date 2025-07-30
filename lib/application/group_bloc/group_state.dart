part of 'group_bloc.dart';

final class GroupState extends Equatable {
  const GroupState({
    required this.createGroupFailOrSuccess,
    required this.getGroupsFailureOrGroups,
    required this.groupsOption,
    required this.getGroupRequestsFailureOrRequests,
    required this.requestsOption,
    required this.sendingAddGroupReq,
    required this.sendAddGroupReqFailureOrRequests,
    required this.createExpenseFailOrSuccess,
    required this.payExpenseFailOrSuccess,
    required this.creatingExpense,
    required this.isSendingReqAnswer,
    this.sendAddGroupReqErrorMessage,
    this.isFetchingRequests = false,
    this.isFetchingData = false,
    this.isCreatingGroup = false,
    this.isPayingExpense = false,
  });

  factory GroupState.initial() {
    return GroupState(
      getGroupsFailureOrGroups: none(),
      createGroupFailOrSuccess: none(),
      groupsOption: none(),
      getGroupRequestsFailureOrRequests: none(),
      sendAddGroupReqFailureOrRequests: none(),
      createExpenseFailOrSuccess: none(),
      payExpenseFailOrSuccess: none(),
      requestsOption: none(),
      isSendingReqAnswer: -1,
      sendAddGroupReqErrorMessage: null,
      isFetchingRequests: false,
      creatingExpense: false,
      sendingAddGroupReq: false,
      isPayingExpense: false,
      isFetchingData: false,
      isCreatingGroup: false,
    );
  }

  final Option<FailureOr<KtList<GroupData>>> getGroupsFailureOrGroups;
  final Option<KtList<GroupData>> groupsOption;
  final Option<FailureOr<KtList<GroupRequestData>>>
  getGroupRequestsFailureOrRequests;
  final Option<KtList<GroupRequestData>> requestsOption;
  final Option<bool> sendAddGroupReqFailureOrRequests;
  final Option<bool> createGroupFailOrSuccess;
  final Option<bool> createExpenseFailOrSuccess;
  final Option<bool> payExpenseFailOrSuccess;
  final bool isPayingExpense;
  final bool isFetchingData;
  final bool isFetchingRequests;
  final bool sendingAddGroupReq;
  final bool creatingExpense;
  final bool isCreatingGroup;
  final int isSendingReqAnswer;
  final String? sendAddGroupReqErrorMessage;

  GroupState copyWith({
    Option<FailureOr<KtList<GroupData>>>? getGroupsFailureOrGroups,
    Option<KtList<GroupData>>? groupsOption,
    Option<FailureOr<KtList<GroupRequestData>>>?
    getGroupRequestsFailureOrRequests,
    Option<KtList<GroupRequestData>>? requestsOption,
    Option<bool>? sendAddGroupReqFailureOrRequests,
    Option<bool>? createGroupFailOrSuccess,
    bool? isFetchingData,
    bool? isFetchingRequests,
    bool? isCreatingGroup,
    bool? sendingAddGroupReq,
    int? isSendingReqAnswer,
    String? sendAddGroupReqErrorMessage,
    Option<bool>? createExpenseFailOrSuccess,
    bool? creatingExpense,
    Option<bool>? payExpenseFailOrSuccess,
    bool? isPayingExpense,
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
      createExpenseFailOrSuccess:
          createExpenseFailOrSuccess ?? this.createExpenseFailOrSuccess,
      creatingExpense: creatingExpense ?? this.creatingExpense,
      createGroupFailOrSuccess: createGroupFailOrSuccess ?? this.createGroupFailOrSuccess,
      isCreatingGroup: isCreatingGroup ?? this.isCreatingGroup,
      payExpenseFailOrSuccess: payExpenseFailOrSuccess ?? this.payExpenseFailOrSuccess,
      isPayingExpense: isPayingExpense ?? this.isPayingExpense,
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
    sendingAddGroupReq, 
    sendAddGroupReqFailureOrRequests, 
    isSendingReqAnswer,
    sendAddGroupReqErrorMessage ?? '',
    creatingExpense,
    createExpenseFailOrSuccess,
    createGroupFailOrSuccess,
    isCreatingGroup,
    payExpenseFailOrSuccess,
    isPayingExpense,
  ];
}
