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
    required this.addGroupWithGroupTokenFailureOrGroup,
    required this.payExpenseFailOrSuccess,
    required this.creatingExpense,
    required this.isSendingReqAnswer,
    this.sendAddGroupReqErrorMessage,
    this.isDeletingExpense = false,
    this.isFetchingRequests = false,
    this.isAddingGroupWithGroupToken = false,
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
      addGroupWithGroupTokenFailureOrGroup: none(),
      isAddingGroupWithGroupToken: false,
      createExpenseFailOrSuccess: none(),
      payExpenseFailOrSuccess: none(),
      requestsOption: none(),
      isSendingReqAnswer: -1,
      sendAddGroupReqErrorMessage: null,
      isFetchingRequests: false,
      creatingExpense: false,
      sendingAddGroupReq: false,
      isDeletingExpense: false,
      isPayingExpense: false,
      isFetchingData: false,
      isCreatingGroup: false,
    );
  }

  final Option<FailureOr<KtList<GroupData>>> getGroupsFailureOrGroups;
  final Option<FailureOr<UniLinkGroupData>> addGroupWithGroupTokenFailureOrGroup;
  final bool isAddingGroupWithGroupToken;
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
  final bool isDeletingExpense;
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
    Option<FailureOr<UniLinkGroupData>>? addGroupWithGroupTokenFailureOrGroup,
    bool? isFetchingData,
    Option<bool>? createGroupFailOrSuccess,
    bool? isFetchingRequests,
    bool? isCreatingGroup,
    bool? sendingAddGroupReq,
    bool? isDeletingExpense,
    int? isSendingReqAnswer,
    String? sendAddGroupReqErrorMessage,
    Option<bool>? createExpenseFailOrSuccess,
    bool? creatingExpense,
    Option<bool>? payExpenseFailOrSuccess,
    bool? isPayingExpense,
    bool? isAddingGroupWithGroupToken,
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
      createGroupFailOrSuccess:
          createGroupFailOrSuccess ?? this.createGroupFailOrSuccess,
      isCreatingGroup: isCreatingGroup ?? this.isCreatingGroup,
      payExpenseFailOrSuccess: payExpenseFailOrSuccess ?? this.payExpenseFailOrSuccess,
      isPayingExpense: isPayingExpense ?? this.isPayingExpense,
      addGroupWithGroupTokenFailureOrGroup:
          addGroupWithGroupTokenFailureOrGroup ??
          this.addGroupWithGroupTokenFailureOrGroup,
      isAddingGroupWithGroupToken:
          isAddingGroupWithGroupToken ?? this.isAddingGroupWithGroupToken,
      isDeletingExpense: isDeletingExpense ?? this.isDeletingExpense,
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
    isDeletingExpense,
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
