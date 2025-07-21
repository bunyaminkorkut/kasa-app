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
