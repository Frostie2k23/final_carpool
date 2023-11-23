import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:car_pool/classes/student.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_details_state.dart';
part 'user_details_cubit.freezed.dart';

class UserDetailsCubit extends Cubit<UserDetailsState> {
  StreamSubscription<Student>? _userDatastreamSubscription;
  StreamSubscription<User?>? _currentUserSubscription;

  UserDetailsCubit() : super(const UserDetailsState.initial()) {
    emit(const UserDetailsState.loading());

    _currentUserSubscription =
        AuthService().authStateChanges.listen((currentUser) {
      if (currentUser != null) {
        _userDatastreamSubscription?.cancel();

        _userDatastreamSubscription = FirebaseFirestore.instance
            .collection("users")
            .doc(AuthService().currentUser!.uid)
            .snapshots()
            .map((event) {
          // print(event);
          return Student.fromJson(event.data()!);
        }).listen((event) {
          emit(UserDetailsState.loaded(event));
        });
      } else {
        _userDatastreamSubscription?.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _userDatastreamSubscription?.cancel();

    _currentUserSubscription?.cancel();
    return super.close();
  }
}
