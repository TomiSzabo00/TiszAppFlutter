import 'package:firebase_database/firebase_database.dart' as database;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static storage.Reference ref = storage.FirebaseStorage.instance.ref();
  static uploadImage(XFile file) async {
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssSSS');
    var key = formatter.format(now);
    final images = ref.child('debug/$key.jpg');
    final storage.UploadTask uploadTask = images.putData(
        await file.readAsBytes(),
        storage.SettableMetadata(contentType: 'image/jpeg'));
    final storage.TaskSnapshot downloadUrl = (await uploadTask);
    final String url = (await downloadUrl.ref.getDownloadURL());
    //return url;

    final database.DatabaseReference picsRef =
        database.FirebaseDatabase.instance.ref().child("debug/pics");
    picsRef.child(key).set({
      'fileName': url,
      'author': 'debug',
      'title': 'debug',
    });
  }
}
