import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:xiaomi_scale_example/model/feedback_form.dart';

class FormController {
  final void Function(String) callback;

  static const String URL = 'https://script.google.com/macros/s/AKfycbzVJCtSNT_-plpPi2G0O-aly2zRZPUJ2-IcCwICQpqq9QRaQveDCnu-5SpZMC4etOlG/exec';

  static const STATUS_SUCCESS = 'SUCCESS';

  FormController(this.callback);

  void submitForm(FeedbackForm feedbackForm) async {
    try {
      await http
          .get(
        Uri.parse(URL + feedbackForm.toParams()),
      )
          .then((res) {
        callback(convert.jsonDecode(res.body)['status']);
      });
    } catch (error) {
      print(error);
    }
  }
}
