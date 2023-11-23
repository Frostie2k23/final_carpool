import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:car_pool/models/trip_model.dart';
import 'package:car_pool/screens/trip/trips_event.dart';
import 'package:car_pool/screens/trip/trips_state.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripsBloc extends Bloc<TripsEvent, TripState> {
  final FirebaseFirestore firestore;

  TripsBloc({
    required this.firestore,
  }) : super(TripState()) {
    on<TripStartedEvent>(_onTripStarted);
    on<ListenToTripDocEvent>(_onListenToTripDocEvent);
    on<DriverArrivingEvent>(_onDriverArriving);
    on<DriverArrivedEvent>(_onDriverArrived);
    on<TripDataReceived>(_onTripDataReceived);
    // on<StartTrip>(_onStartTrip);
    // on<EndTrip>(_onEndTrip);
    on<OngoingTrip>(_onGoingTrip);
    on<InProgressEvent>(_inProgress);

    //driver
    on<TripCompletedEvent>(_onCompleted);

    //customer
    on<DriverArrivedToCustomerEvent>(_onDriverArrivedToCustomerEvent);
    on<TripInProgressCustomerEvent>(_onTripInProgressCustomerEvent);
    on<TripCompletedCustomerEvent>(_onTripCompletedCustomerEvent);
    on<TripResetValuesCustomerEvent>(_onTripResetValuesCustomerEvent);
  }

  FutureOr<void> _onGoingTrip(OngoingTrip event, Emitter<TripState> emit) {
    emit(state.copyWith(
      status: CurrentTripStatus.driverArriving,
      trip: event.trip,
    ));

    add(ListenToTripDocEvent());
  }

  Future<void> _onTripStarted(
      TripStartedEvent event, Emitter<TripState> emit) async {
    if (AuthService().currentUser == null) {
      return;
    }
    final userDoc = await firestore
        .collection('users')
        .doc(AuthService().currentUser!.uid)
        .get();
    final currentTripId = userDoc.get('currentTripId');
    final onTrip = userDoc.get('onATrip');

    if (onTrip && currentTripId != null) {
      final tripDoc =
          await firestore.collection('trips').doc(currentTripId).get();
      final trip = Trip.fromJson(tripDoc.data()!);

      if (trip.status == TripStatus.inProgress) {
        emit(state.copyWith(
          status: CurrentTripStatus.inProgress,
          trip: trip,
        ));
      } else if (trip.status == TripStatus.driverArriving) {
        emit(state.copyWith(
          status: CurrentTripStatus.driverArriving,
          trip: trip,
        ));
      } else if (trip.status == TripStatus.driverArrived) {
        emit(state.copyWith(
          status: CurrentTripStatus.driverArrived,
          trip: trip,
        ));
      }
    }
  }

  Future<void> _onDriverArriving(
      DriverArrivingEvent event, Emitter<TripState> emit) async {
    emit(state.copyWith(
      status: CurrentTripStatus.driverArriving,
      // trip: trip,
    ));
  }

  Future<void> _onDriverArrived(
      DriverArrivedEvent event, Emitter<TripState> emit) async {
    if (state.trip != null) {
      await FirebaseFirestore.instance
          .collection("trips")
          .doc(state.trip!.id)
          .update({'status': tripStatusToString(TripStatus.driverArrived)});
      emit(state.copyWith(
        status: CurrentTripStatus.driverArrived,
        // trip: trip,
      ));
    } else {
      print("trip is null");
    }
  }

  Future<void> _inProgress(
      InProgressEvent event, Emitter<TripState> emit) async {
    if (state.trip != null) {
      await FirebaseFirestore.instance
          .collection("trips")
          .doc(state.trip!.id)
          .update({'status': tripStatusToString(TripStatus.inProgress)});
      emit(state.copyWith(
        status: CurrentTripStatus.inProgress,
        // trip: trip,
      ));
    } else {
      print("trip is null");
    }
  }

  Future<void> _onCompleted(
      TripCompletedEvent event, Emitter<TripState> emit) async {
    if (state.trip != null) {
      await FirebaseFirestore.instance
          .collection("trips")
          .doc(state.trip!.id)
          .update({'status': tripStatusToString(TripStatus.completed)});

      final tripDistance = double.parse(state.trip!.tripDistance.split(" ")[0]);

      //update points on driver acc
      await FirebaseFirestore.instance
          .collection("users")
          .doc(AuthService().currentUser!.uid)
          .update({
        'points': FieldValue.increment(tripDistance),
        'onATrip': false,
        'currentTripId': null,
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(state.trip!.passengerId)
          .update({
        'onATrip': false,
        'currentTripId': null,
      });

      emit(state.copyWith(
        status: CurrentTripStatus.completed,
        // trip: trip,
      ));
    } else {
      print("trip is null");
    }
  }

  // Future<void> _onStartTrip(StartTrip event, Emitter<TripState> emit) async {
  //   emit(state.copyWith(
  //     status: TripStatus.inProgress,
  //     trip: event.trip,
  //   ));
  //   // Here you can add the logic to start the trip
  // }

  // Future<void> _onEndTrip(EndTrip event, Emitter<TripState> emit) async {
  //   emit(state.copyWith(
  //     status: TripStatus.completed,
  //   ));
  //   // Here you can add the logic to end the trip
  // }

  FutureOr<void> _onListenToTripDocEvent(
      ListenToTripDocEvent event, Emitter<TripState> emit) {
    if (state.trip != null) {
      FirebaseFirestore.instance
          .collection("trips")
          .doc(state.trip!.id)
          .snapshots()
          .map((event) => Trip.fromJson(event.data()!))
          .listen((event) {
        add(TripDataReceived(event));
      });
    }
  }

  FutureOr<void> _onTripDataReceived(
      TripDataReceived event, Emitter<TripState> emit) {
    emit(state.copyWith(trip: event.trip));
  }

  FutureOr<void> _onDriverArrivedToCustomerEvent(
      DriverArrivedToCustomerEvent event, Emitter<TripState> emit) {
    emit(state.copyWith(
      status: CurrentTripStatus.driverArrived,
      // trip: trip,
    ));
  }

  FutureOr<void> _onTripInProgressCustomerEvent(
      TripInProgressCustomerEvent event, Emitter<TripState> emit) {
    emit(state.copyWith(
      status: CurrentTripStatus.inProgress,
    ));
  }

  FutureOr<void> _onTripCompletedCustomerEvent(
      TripCompletedCustomerEvent event, Emitter<TripState> emit) {
    emit(state.copyWith(
      status: CurrentTripStatus.completed,
    ));
  }

  FutureOr<void> _onTripResetValuesCustomerEvent(
      TripResetValuesCustomerEvent event, Emitter<TripState> emit) {
    emit(state.copyWith(status: CurrentTripStatus.initial, trip: null));
  }
}
