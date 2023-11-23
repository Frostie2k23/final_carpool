import 'package:emailjs/emailjs.dart';

Future<void> contactParent(String parentEmail, String studentName) async {
  Map<String, dynamic> templateParams = {
    'to_name': 'Parent',
    'from_name': "Carpool App",
    'message': 'Your child $studentName is in a emergency',
    'to_email': parentEmail,
  };

  try {
    await EmailJS.send(
      'service_7uzr93h',
      'template_k7p92u9',
      templateParams,
      const Options(
        publicKey: 'EPF39JPbabz7gyuth',
        privateKey: 'sX5EkQxW35NUUDYIhtJfq',
      ),
    );
    print('SUCCESS!');
  } catch (error) {
    print(parentEmail);
    print(error.toString());
  }
}
