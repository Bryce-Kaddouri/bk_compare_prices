import 'package:intl/intl.dart';

class DateHelper {
  static String getFormattedDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy HH:mm').format(dateTime);
  }
}
