import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DateService {
  static dateInMillisAsString() {
    initializeDateFormatting();
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    return formatter.format(now);
  }
}