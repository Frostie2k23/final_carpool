import 'package:flutter/material.dart';

class Student {
  //personal
  final String studentID;
  final String studentRole;
  final int studentAge;
  final String studentName;
  final String majorDepartment;
  //vehicle
  final String? driversLicenseNumber;
  final String? carRegistrationNumber;
  final String? vehiclePlateNumber;
  final String? vehicleColorType;
  final int? numberOfSeats;
  // Emirates ID
  final String emiratesIDNumber;
  String? avatarURL;
  //! new fields
  final String id;
  final String email;
  final String type;
  final String? parentEmail;

  //! Field data
  final bool basicDetailsAdded;
  final bool driverDetailsAdded;

  //! home Location
  final double? latitude;
  final double? longitude;

  final Map<String, Map<String, TimeOfDay>> sessionTimes;

  //! on a trip
  final bool onATrip;

//currnet trip id
  final String? currentTripId;

  final bool isAvailable;

  final num points;

  Student({
    this.studentID = '',
    this.studentRole = '',
    this.studentAge = 0,
    this.studentName = '',
    this.majorDepartment = '',
    this.emiratesIDNumber = '',
    this.id = '',
    this.email = '',
    this.type = '',
    this.basicDetailsAdded = false,
    this.driverDetailsAdded = false,
    this.driversLicenseNumber,
    this.carRegistrationNumber,
    this.vehiclePlateNumber,
    this.vehicleColorType,
    this.numberOfSeats,
    this.parentEmail,
    this.latitude,
    this.longitude,
    this.sessionTimes = const {},
    this.isAvailable = false,
    this.onATrip = false,
    this.currentTripId,
    this.avatarURL,
    this.points = 0,
  });

  // method to convert Student object to JSON
  Map<String, dynamic> toJson() {
    return {
      'studentID': studentID,
      'studentRole': studentRole,
      'studentAge': studentAge,
      'studentName': studentName,
      'majorDepartment': majorDepartment,
      'driversLicenseNumber': driversLicenseNumber,
      'carRegistrationNumber': carRegistrationNumber,
      'vehiclePlateNumber': vehiclePlateNumber,
      'vehicleColorType': vehicleColorType,
      'numberOfSeats': numberOfSeats,
      'emiratesIDNumber': emiratesIDNumber,
      'id': id,
      'email': email,
      'type': type,
      'parent_email': parentEmail,
      'driver_details_added': driverDetailsAdded,
      'basic_details_added': basicDetailsAdded,
      'latitude': latitude,
      'longitude': longitude,
      'sessionTimes': sessionTimes.map((key, value) => MapEntry(key, {
            'start': '${value['start']?.hour}:${value['start']?.minute}',
            'end': '${value['end']?.hour}:${value['end']?.minute}',
          })),
      'isAvailable': isAvailable,
      'onATrip': onATrip,
      'currentTripId': currentTripId,
      'avatarURL': avatarURL,
      'points': points
    };
  }

  // factory method to convert JSON to Student object
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentID: json['studentID'],
      studentRole: json['studentRole'],
      studentAge: json['studentAge'],
      studentName: json['studentName'],
      majorDepartment: json['majorDepartment'],
      emiratesIDNumber: json['emiratesIDNumber'],
      id: json['id'],
      email: json['email'],
      type: json['type'],
      driversLicenseNumber: json['driversLicenseNumber'],
      carRegistrationNumber: json['carRegistrationNumber'],
      vehiclePlateNumber: json['vehiclePlateNumber'],
      vehicleColorType: json['vehicleColorType'],
      numberOfSeats: json['numberOfSeats'],
      parentEmail: json['parent_email'],
      avatarURL: json['avatarURL'],
      basicDetailsAdded: json['basic_details_added'],
      driverDetailsAdded: json['driver_details_added'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      sessionTimes:
          (json['sessionTimes'] as Map<String, dynamic>).map((key, value) {
        var startParts = (value['start'] as String).split(':');
        var endParts = (value['end'] as String).split(':');
        return MapEntry(key, {
          'start': TimeOfDay(
              hour: int.parse(startParts[0]), minute: int.parse(startParts[1])),
          'end': TimeOfDay(
              hour: int.parse(endParts[0]), minute: int.parse(endParts[1])),
        });
      }),
      isAvailable: json['isAvailable'],
      onATrip: json['onATrip'],
      currentTripId: json['currentTripId'],
      points: json['points'],
    );
  }
}
