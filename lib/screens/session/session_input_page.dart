import 'package:car_pool/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class SessionInputPage extends StatefulWidget {
  const SessionInputPage({Key? key, required this.sessionTimes})
      : super(key: key);
  final Map<String, Map<String, TimeOfDay>> sessionTimes;

  @override
  _SessionInputPageState createState() => _SessionInputPageState();
}

class _SessionInputPageState extends State<SessionInputPage> {
  late Map<String, Map<String, TimeOfDay>> sessionTimes;

  void showSuccessAlert() {
    if (mounted) {
      QuickAlert.show(
        context: context,
        text: "Sessions updated successfully !",
        showConfirmBtn: false,
        type: QuickAlertType.success,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    sessionTimes = widget.sessionTimes.isNotEmpty
        ? widget.sessionTimes
        : {
            'Monday': {
              'start': const TimeOfDay(hour: 9, minute: 0),
              'end': const TimeOfDay(hour: 17, minute: 0)
            },
            'Tuesday': {
              'start': const TimeOfDay(hour: 9, minute: 0),
              'end': const TimeOfDay(hour: 17, minute: 0)
            },
            'Wednesday': {
              'start': const TimeOfDay(hour: 9, minute: 0),
              'end': const TimeOfDay(hour: 17, minute: 0)
            },
            'Thursday': {
              'start': const TimeOfDay(hour: 9, minute: 0),
              'end': const TimeOfDay(hour: 17, minute: 0)
            },
            'Friday': {
              'start': const TimeOfDay(hour: 9, minute: 0),
              'end': const TimeOfDay(hour: 17, minute: 0)
            },
            'Saturday': {
              'start': const TimeOfDay(hour: 9, minute: 0),
              'end': const TimeOfDay(hour: 17, minute: 0)
            },
            'Sunday': {
              'start': const TimeOfDay(hour: 9, minute: 0),
              'end': const TimeOfDay(hour: 17, minute: 0)
            },
          };
  }

  Future<TimeOfDay?> _selectTime(
      BuildContext context, String day, String timeType) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: sessionTimes[day]![timeType]!,
    );
    if (pickedTime != null) {
      setState(() {
        sessionTimes[day]![timeType] = pickedTime;
      });
    }
    return pickedTime;
  }

  @override
  Widget build(BuildContext context) {
    var daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    var sortedKeys = sessionTimes.keys.toList(growable: false)
      ..sort(
          (k1, k2) => daysOfWeek.indexOf(k1).compareTo(daysOfWeek.indexOf(k2)));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Input'),
        backgroundColor: Colors.redAccent,
        elevation: 25,
      ),
      body: ListView.builder(
        itemCount: sessionTimes.length,
        itemBuilder: (context, index) {
          String day = sortedKeys[index];
          return ListTile(
            title: Text(day),
            isThreeLine: true,
            subtitle: Row(
              children: [
                Text(
                    'Start Time: ${sessionTimes[day]!['start']!.format(context)}\nEnd Time: ${sessionTimes[day]!['end']!.format(context)}'),
                // const SizedBox(width: 10),
                // Text('End Time: ${sessionTimes[day]!['end']!.format(context)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.start),
                  onPressed: () {
                    _selectTime(context, day, 'start');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () {
                    _selectTime(context, day, 'end');
                  },
                ),
              ],
            ),
            onTap: () {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.save),
        onPressed: () {
          // Save the session times to the database or perform any other action
          print(sessionTimes);

          final jsonSessionTimes =
              sessionTimes.map((key, value) => MapEntry(key, {
                    'start':
                        '${value['start']?.hour}:${value['start']?.minute}',
                    'end': '${value['end']?.hour}:${value['end']?.minute}',
                  }));
          FirebaseFirestore.instance
              .collection("users")
              .doc(AuthService().currentUser!.uid)
              .update({'sessionTimes': jsonSessionTimes}).then((value) {
            showSuccessAlert();
          });
        },
      ),
    );
  }
}
