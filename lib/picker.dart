import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';

class Picker {

  Future<File> pick() async {
    return await FilePicker.getFile();
  }

  Future<Map<String, String>> pickMultipleFiles() async {
    return await FilePicker.getMultiFilePath();
  }

  Future<File> makeZip(Map<String, String> ficheros) async {
    var encoder = ZipFileEncoder();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    encoder.create(tempPath + '/miZip.zip');

    ficheros.forEach((String nombre, String ruta) => encoder.addFile(File(ruta)));

    encoder.close();
    return File(tempPath + '/miZip.zip');
  }

  Future<String> upload(File archivo, String url) async {
    var stream = new http.ByteStream(DelegatingStream.typed(archivo.openRead()));
    var length = await archivo.length();
    var uri = Uri.parse(url + basename(archivo.path));

    var request = http.MultipartRequest("PUT", uri);
    var multipartFile = http.MultipartFile('file', stream, length, filename: basename(archivo.path));
    request.files.add(multipartFile);

    return request.send().then((requested) => requested.stream.bytesToString()
    ).catchError((error){
      throw error;
    });
  }

  Future<File> multipleFiles() async {
    Map<String, String> files = await pickMultipleFiles();
    File zip = await makeZip(files);
    return zip;
  }

  Future<String> getUrl(areMultipleFiles) async {
    Map<bool, Function> options = {true: multipleFiles, false: pick};

    File file = await options[areMultipleFiles]();

    return upload(file, "https://transfer.sh/");
  }
}
