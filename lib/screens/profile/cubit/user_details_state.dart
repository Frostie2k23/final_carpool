part of 'user_details_cubit.dart';

@freezed
class UserDetailsState with _$UserDetailsState {
  const factory UserDetailsState.initial() = _Initial;

  const factory UserDetailsState.loading() = _Loading;

  const factory UserDetailsState.loaded(Student model) = _Loaded;
  const factory UserDetailsState.errorOccuredWhileLoading(String errorMessage) =
      _ErrorOccuredWhileLoading;
}
