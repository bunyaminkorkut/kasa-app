part of 'group_bloc.dart';

sealed class GroupEvent {
  const GroupEvent();
}

class _GroupEventGetMyGroups extends GroupEvent {
  _GroupEventGetMyGroups({required this.jwtToken});
  final String jwtToken;
  List<Object?> get props => [jwtToken];
}

class _GroupEventGetGroupRequests extends GroupEvent {
  _GroupEventGetGroupRequests({required this.jwtToken});
  final String jwtToken;
  List<Object?> get props => [jwtToken];
}

class _GroupEventSendAnswerRequest extends GroupEvent {
  _GroupEventSendAnswerRequest({
    required this.jwtToken,
    required this.requestId,
    required this.isAccepting,
  });
  final String jwtToken;
  final int requestId;
  final bool isAccepting; // true for accept, false for reject
  List<Object?> get props => [jwtToken, requestId, isAccepting];
}

class _GroupEventSendAddRequest extends GroupEvent {
  _GroupEventSendAddRequest({
    required this.jwtToken,
    required this.groupId,
    required this.userEmail,
  });
  final String jwtToken;
  final int groupId;
  final String userEmail; // true for accept, false for reject
  List<Object?> get props => [jwtToken, groupId, userEmail];
}

class _GroupEventCreateExpense extends GroupEvent {
  _GroupEventCreateExpense({
    required this.jwtToken,
    required this.expenseData
  });
  final String jwtToken;
  final CreateExpenseData expenseData; // true for accept, false for reject
  List<Object?> get props => [jwtToken, expenseData];
}

class _GroupEventCreateGroup extends GroupEvent {
  _GroupEventCreateGroup({
    required this.jwtToken,
    required this.groupName
  });
  final String jwtToken;
  final String groupName; // true for accept, false for reject
  List<Object?> get props => [jwtToken, groupName];
}
