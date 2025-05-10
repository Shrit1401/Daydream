import 'package:intl/intl.dart';

String getMonthName(int month) {
  return DateFormat('MMMM').format(DateTime(2000, month));
}
