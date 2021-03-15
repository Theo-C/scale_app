import 'dart:ffi';

class FeedbackForm {

  String _id;
  String _name;
  String _weight;
  String _wasteType;
  String _date;

  FeedbackForm(this._id, this._name, this._weight, this._wasteType, this._date);

  String toParams() => "?id=$_id&name=$_name&weight=$_weight&wasteType=$_wasteType&date=$_date";
}