import 'dart:io';

import 'package:car_pool/assets/custom_widgets.dart';
import 'package:car_pool/screens/profile/cubit/user_details_cubit.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _studentIDController = TextEditingController();
  final TextEditingController _studentEmiratesIdController =
      TextEditingController();
  final TextEditingController _studentRoleController = TextEditingController();
  final TextEditingController _studentAgeController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _studentEmailController = TextEditingController();
  final TextEditingController _majorDepartmentController =
      TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _driversLicenseNumberController =
      TextEditingController();
  final TextEditingController _carRegistrationNumberController =
      TextEditingController();
  final TextEditingController _vehiclePlateNumberController =
      TextEditingController();
  final TextEditingController _vehicleColorTypeController =
      TextEditingController();
  final TextEditingController _numberOfSeatsController =
      TextEditingController();

  bool isEditable = false;

  // bool isDriver = false;

  void showSuccessAlert(String? message) {
    if (mounted) {
      QuickAlert.show(
        context: context,
        text: message ?? "Home Location Saved!",
        showConfirmBtn: false,
        type: QuickAlertType.success,
      );
    }
  }

  void showErrorAlert(String errorMessage) {
    if (mounted) {
      QuickAlert.show(
        context: context,
        text: errorMessage,
        showConfirmBtn: true,
        type: QuickAlertType.error,
      );
    }
  }

  Position? _currentPosition;

//? profile image
  final ImagePicker _picker = ImagePicker();
  File? selectedFile;

  Future getImage() async {
    XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: selectedImage.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          selectedFile = File(croppedFile.path);
        });
      } else {
        setState(() {
          selectedFile = File(selectedImage.path);
        });
      }
    }
  }

  Future uploadImageToFirebase() async {
    if (selectedFile == null) {
      return;
    }
    File file = selectedFile!;
    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_pic/${file.path}');

      // Upload the file to Firebase Storage
      TaskSnapshot snapshot = await storageReference.putFile(file);

      // Retrieve the uploaded file's download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(AuthService().currentUser!.uid)
          .update({'avatarURL': downloadUrl});

      return downloadUrl;
    } on FirebaseException catch (e) {
      print(e.code);
    }
  }

  void _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      _currentPosition = await Geolocator.getCurrentPosition();
      if (_currentPosition != null) {
        try {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(AuthService().currentUser!.uid)
              .update({
            'latitude': _currentPosition!.latitude,
            'longitude': _currentPosition!.longitude
          });
          showSuccessAlert(null);
        } catch (e) {
          showErrorAlert(
              "Unexpected error occurred while updating location . Please try again");
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('Profile'),
      ),
      body: BlocBuilder<UserDetailsCubit, UserDetailsState>(
        builder: (context, state) {
          return state.maybeWhen(
            orElse: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            loaded: (model) {
              _studentNameController.text = model.studentName;
              _studentIDController.text = model.studentID;
              _studentEmiratesIdController.text = model.emiratesIDNumber;
              _studentEmailController.text = model.email;
              _studentRoleController.text = model.studentRole;
              _studentAgeController.text = model.studentAge.toString();
              _majorDepartmentController.text = model.majorDepartment;
              _homeAddressController.text =
                  "${model.latitude},  ${model.longitude}";
              _driversLicenseNumberController.text =
                  model.driversLicenseNumber ?? "";
              _carRegistrationNumberController.text =
                  model.carRegistrationNumber ?? "";
              _vehiclePlateNumberController.text =
                  model.vehiclePlateNumber ?? "";
              _vehicleColorTypeController.text = model.vehicleColorType ?? "";
              _numberOfSeatsController.text =
                  (model.numberOfSeats ?? 0).toString();
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 50),
                      Stack(
                        children: [
                          if (selectedFile == null)
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(model.avatarURL ??
                                  'https://via.placeholder.com/150'),
                            ),
                          if (selectedFile != null)
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(selectedFile!),
                            ),
                          if (selectedFile == null)
                            Positioned(
                              right: -12,
                              bottom: -12,
                              child: IconButton(
                                onPressed: () {
                                  getImage();
                                },
                                icon: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          if (selectedFile != null)
                            Positioned(
                              right: -12,
                              bottom: -12,
                              child: IconButton(
                                onPressed: () {
                                  // getImage();
                                  uploadImageToFirebase();
                                },
                                icon: const Icon(
                                  Icons.done,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        model.studentName,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        model.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // if (model.type == 'student')
                      //   const Text(
                      //     'Home address',
                      //     style: TextStyle(
                      //       fontSize: 18,
                      //       color: Colors.black,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // const SizedBox(height: 10),
                      // if ((model.latitude == null || model.longitude == null) &&
                      //     model.type == 'student')
                      //   const Text(
                      //     'You have to setup your home location first',
                      //     style: TextStyle(
                      //       fontSize: 14,
                      //       color: Colors.red,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //     textAlign: TextAlign.center,
                      //   ),
                      // if ((model.latitude == null || model.longitude == null) &&
                      //     model.type == 'student')
                      //   Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 20),
                      //     child: ElevatedButton(
                      //         onPressed: () {
                      //           _getCurrentLocation();
                      //         },
                      //         child: const Text("Save home location")),
                      //   ),
                      // if ((model.latitude != null && model.longitude != null) &&
                      //     model.type == 'student')
                      //   Text(
                      //     "${model.latitude},${model.longitude}",
                      //     style: TextStyle(
                      //       fontSize: 14,
                      //       color: Colors.black.withOpacity(0.6),
                      //     ),
                      //     textAlign: TextAlign.center,
                      //   ),
                      // --------------------------------------------------
                      if ((model.latitude != null && model.longitude != null))
                        MyTextFormField(
                          label: "Home Address (Lat, Lon)",
                          readOnly: true,
                          controller: _homeAddressController,
                          hintText: 'Home Address',
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          obscureText: false,
                          validator: (String? value) {
                            if (_homeAddressController.text.isEmpty) {
                              return "";
                            }
                            return null;
                          },
                        ),
                      if ((model.latitude == null || model.longitude == null))
                        const Text(
                          'You have to setup your home location first',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if ((model.latitude == null || model.longitude == null))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: ElevatedButton(
                              onPressed: () {
                                _getCurrentLocation();
                              },
                              child: const Text("Save home location")),
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      MyTextFormField(
                        readOnly: true,
                        label: "Student ID",
                        controller: _studentIDController,
                        hintText: 'Student ID',
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: false,
                        validator: (String? value) {
                          if (_studentIDController.text.isEmpty) {
                            return "Please enter your student ID";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      model.type != "student"
                          ? Column(
                              children: [
                                MyTextFormField(
                                  readOnly: true,
                                  label: "Emirates ID",
                                  controller: _studentEmiratesIdController,
                                  hintText: 'Emirates ID',
                                  autoValidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  obscureText: false,
                                  validator: (String? value) {
                                    if (_studentEmiratesIdController
                                        .text.isEmpty) {
                                      return "Please enter your Emirates ID";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            )
                          : const SizedBox(),
                      MyTextFormField(
                        readOnly: true,
                        label: "Email",
                        controller: _studentEmailController,
                        hintText: 'Email',
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: false,
                        validator: (String? value) {
                          if (_studentEmailController.text.isEmpty) {
                            return "Please enter your student Email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(),
                      isEditable == false
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      isEditable = true;
                                    });
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text(
                                    "Edit",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 20.0),
                              ],
                            )
                          : const SizedBox(),

                      MyTextFormField(
                        readOnly: !isEditable,
                        label: "Name",
                        controller: _studentNameController,
                        hintText: 'Name',
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (_studentNameController.text.isEmpty) {
                            return 'Name cannot be Empty';
                          }
                          return null; // implies validation has passed
                        },
                        obscureText: false,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      MyTextFormField(
                          readOnly: !isEditable,
                          label: "Role",
                          controller: _studentRoleController,
                          hintText: 'Role',
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (_studentRoleController.text.isEmpty) {
                              return 'Please enter your student role';
                            }
                            return null; // implies validation has passed
                          },
                          obscureText: false),

                      const SizedBox(
                        height: 20,
                      ),
                      //password
                      MyTextFormField(
                        readOnly: !isEditable,
                        isNumber: true,
                        label: "Age",
                        controller: _studentAgeController,
                        hintText: 'Age',
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          //final _passwordTrimController = _passwordConfirmController.text.trim();
                          if (_studentAgeController.text.isEmpty) {
                            return 'Age cannot be Empty';
                          }
                          return null; // implies validation has passed
                        },
                        obscureText: false,
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      MyTextFormField(
                        readOnly: !isEditable,
                        label: "Major Department",
                        controller: _majorDepartmentController,
                        hintText: 'Major department',
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (_majorDepartmentController.text.isEmpty) {
                            return 'Department cannot be Empty';
                          }
                          return null; // implies validation has passed
                        },
                        obscureText: false,
                      ),
                      const SizedBox(height: 20.0),
                      model.type != "student"
                          ? Column(
                              children: [
                                MyTextFormField(
                                  readOnly: !isEditable,
                                  label: "License Number",
                                  controller: _driversLicenseNumberController,
                                  hintText: 'License Number',
                                  autoValidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (_driversLicenseNumberController
                                        .text.isEmpty) {
                                      return 'License number cannot be empty';
                                    }
                                    return null; // implies validation has passed
                                  },
                                  obscureText: false,
                                ),
                                const SizedBox(height: 20.0),
                              ],
                            )
                          : const SizedBox(),
                      model.type != "student"
                          ? Column(
                              children: [
                                MyTextFormField(
                                  readOnly: !isEditable,
                                  label: "Vehicle Registration Number",
                                  controller: _carRegistrationNumberController,
                                  hintText: 'Vehicle Registration Number',
                                  autoValidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (_carRegistrationNumberController
                                        .text.isEmpty) {
                                      return 'Vehicle registration number cannot be empty';
                                    }
                                    return null; // implies validation has passed
                                  },
                                  obscureText: false,
                                ),
                                const SizedBox(height: 20.0),
                              ],
                            )
                          : const SizedBox(),
                      model.type != "student"
                          ? Column(
                              children: [
                                MyTextFormField(
                                  readOnly: !isEditable,
                                  label: "Vehicle Plate Number",
                                  controller: _vehiclePlateNumberController,
                                  hintText: 'Vehicle Plate Number',
                                  autoValidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (_vehiclePlateNumberController
                                        .text.isEmpty) {
                                      return 'Vehicle plate number cannot be empty';
                                    }
                                    return null; // implies validation has passed
                                  },
                                  obscureText: false,
                                ),
                                const SizedBox(height: 20.0),
                              ],
                            )
                          : const SizedBox(),
                      model.type != "student"
                          ? Column(
                              children: [
                                MyTextFormField(
                                  readOnly: !isEditable,
                                  label: "Vehicle Color",
                                  controller: _vehicleColorTypeController,
                                  hintText: 'Vehicle color',
                                  autoValidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (_vehicleColorTypeController
                                        .text.isEmpty) {
                                      return 'Vehicle color cannot be empty';
                                    }
                                    return null; // implies validation has passed
                                  },
                                  obscureText: false,
                                ),
                                const SizedBox(height: 20.0),
                              ],
                            )
                          : const SizedBox(),
                      model.type != "student"
                          ? Column(
                              children: [
                                MyTextFormField(
                                  isNumber: true,
                                  readOnly: !isEditable,
                                  label: "No of Seats",
                                  controller: _numberOfSeatsController,
                                  hintText: 'No of seats',
                                  autoValidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (_numberOfSeatsController.text.isEmpty) {
                                      return 'No of seats cannot be empty';
                                    }
                                    return null; // implies validation has passed
                                  },
                                  obscureText: false,
                                ),
                                const SizedBox(height: 20.0),
                              ],
                            )
                          : const SizedBox(),
                      isEditable == true
                          ? Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (model.type == 'student') {
                                      if (_studentNameController.text.trim().isNotEmpty &&
                                          _studentRoleController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _studentAgeController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _majorDepartmentController.text
                                              .trim()
                                              .isNotEmpty) {
                                        setState(() {
                                          isEditable = false;
                                        });

                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(AuthService().currentUser!.uid)
                                            .update({
                                          'studentName': _studentNameController
                                              .text
                                              .trim(),
                                          'studentRole': _studentRoleController
                                              .text
                                              .trim(),
                                          'studentAge': int.parse(
                                              _studentAgeController.text
                                                  .trim()),
                                          'majorDepartment':
                                              _majorDepartmentController.text
                                                  .trim(),
                                        });

                                        showSuccessAlert(
                                            "Details edited successfully");
                                      } else {
                                        showErrorAlert(
                                            "All the fields are required");
                                      }
                                    } else if (model.type == 'driver') {
                                      //todo check the other fileds also

                                      if (_studentNameController.text.trim().isNotEmpty &&
                                          _studentRoleController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _studentAgeController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _majorDepartmentController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _driversLicenseNumberController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _carRegistrationNumberController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _vehiclePlateNumberController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _vehicleColorTypeController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _numberOfSeatsController.text
                                              .trim()
                                              .isNotEmpty) {
                                        setState(() {
                                          isEditable = false;
                                        });

                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(AuthService().currentUser!.uid)
                                            .update({
                                          'studentName': _studentNameController
                                              .text
                                              .trim(),
                                          'studentRole': _studentRoleController
                                              .text
                                              .trim(),
                                          'studentAge': int.parse(
                                              _studentAgeController.text
                                                  .trim()),
                                          'majorDepartment':
                                              _majorDepartmentController.text
                                                  .trim(),
                                          'driversLicenseNumber':
                                              _driversLicenseNumberController
                                                  .text
                                                  .trim(),
                                          'carRegistrationNumber':
                                              _carRegistrationNumberController
                                                  .text
                                                  .trim(),
                                          'vehiclePlateNumber':
                                              _vehiclePlateNumberController.text
                                                  .trim(),
                                          'vehicleColorType':
                                              _vehicleColorTypeController.text
                                                  .trim(),
                                          'numberOfSeats': int.parse(
                                              _numberOfSeatsController.text
                                                  .trim())
                                        });

                                        showSuccessAlert(
                                            "Details edited successfully");
                                      } else {
                                        showErrorAlert(
                                            "All the fields are required");
                                      }
                                    }
                                  },
                                  child: const MyButton(
                                    text: 'Save',
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 50.0),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
