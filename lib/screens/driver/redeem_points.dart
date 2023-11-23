import 'package:car_pool/screens/profile/cubit/user_details_cubit.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RedeemPoints extends StatefulWidget {
  const RedeemPoints({super.key});

  @override
  State<RedeemPoints> createState() => _RedeemPointsState();
}

class _RedeemPointsState extends State<RedeemPoints> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text("Redeem Points"),
        ),
        body: BlocBuilder<UserDetailsCubit, UserDetailsState>(
          builder: (context, state) {
            return state.maybeWhen(
              loaded: (model) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        "Your Points",
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        "${model.points}",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: model.points == 0
                            ? null
                            : () {
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(AuthService().currentUser!.uid)
                                    .update({'points': 0});
                              },
                        child: const Text("Redeem"),
                      ),
                    ),
                  ],
                );
              },
              orElse: () => const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ));
  }
}
