import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:path/path.dart';
import 'package:async/async.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transfer',
      theme: ThemeData(
          backgroundColor: Colors.purple, accentColor: Colors.white, primaryColor: Colors.lightBlue, cardColor: Colors.amber),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final controller = PageController();

  String url = "Esperando al archivo...";
  bool peticion = false;
  double opacidadCargado = 0.0;
  bool multiplesArchivos = false;

  Future<File> _elegir() async {
    return await FilePicker.getFile();
  }

  Future<Map<String, String>> _elegirVariosFicheros() async {
    return await FilePicker.getMultiFilePath();
  }

  Future<File> _crearZip(Map<String, String> ficheros) async {
    var encoder = ZipFileEncoder();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    encoder.create(tempPath + '/miZip.zip');

    ficheros.forEach((String nombre, String ruta) => encoder.addFile(File(ruta)));

    encoder.close();
    return File(tempPath + '/miZip.zip');
  }

  Future<String> _enviar(File archivo, String url) async {
    var stream = new http.ByteStream(DelegatingStream.typed(archivo.openRead()));
    var length = await archivo.length();
    var uri = Uri.parse(url + basename(archivo.path));

    var request = http.MultipartRequest("PUT", uri);
    var multipartFile = http.MultipartFile('file', stream, length, filename: basename(archivo.path));
    request.files.add(multipartFile);

    var peticionHttp = await request.send();
    var respuestaPeticion = await peticionHttp.stream.bytesToString();

    return respuestaPeticion;
  }

  void mostrarMensajeSnack(String mensaje) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Theme.of(context).backgroundColor, Theme.of(context).primaryColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
              title: Text(
                'Transfiere tus archivos',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    height: MediaQuery.of(context).size.height * 0.30,
                    minWidth: MediaQuery.of(context).size.width * 0.7,
                    child: Icon(Icons.attach_file),
                    padding: EdgeInsets.all(0.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    elevation: 10,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onPressed: () {
                      if (multiplesArchivos) {
                        _elegirVariosFicheros().then((Map<String, String> ficheros) {
                          _crearZip(ficheros).then((File zip) {
                            peticion = true;
                            setState(() {
                              url = 'Subiendo el archivo';
                            });
                            _enviar(zip, "https://transfer.sh/").then((String urlTemp) {
                              setState(() {
                                url = urlTemp;
                                opacidadCargado = 1.0;
                              });
                            });
                          });
                        });
                      } else {
                        _elegir().then((File fichero) {
                          peticion = true;
                          setState(() {
                            url = 'Subiendo el archivo';
                          });
                          _enviar(fichero, "https://transfer.sh/").then((String urlTemp) {
                            setState(() {
                              url = urlTemp;
                              opacidadCargado = 1.0;
                            });
                          });
                        });
                      }
                    },
                  ),
                  Card(
                    elevation: 8.0,
                    color: Theme.of(context).cardColor,
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text('Selecciona para subir multiples archivos en ZIP', style: TextStyle(color: Theme.of(context).accentColor),),
                            Switch(
                              value: multiplesArchivos,
                              activeColor: Theme.of(context).accentColor,
                              activeTrackColor: Theme.of(context).primaryColor,
                              onChanged: (valor) {
                                setState(() {
                                  multiplesArchivos = valor;
                                });
                              },
                            )
                          ],
                        )),
                  ),
                  Card(
                    elevation: 8.0,
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        'Sube tu archivo para generar un link',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: Duration(seconds: 1, microseconds: 200),
                    opacity: opacidadCargado,
                    child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          elevation: 8.0,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: AutoSizeText(
                                    '$url',
                                    style: TextStyle(color: Theme.of(context).accentColor),
                                    maxLines: 1,
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  child: VerticalDivider(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.content_copy),
                                  color: Theme.of(context).accentColor,
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: url));
                                    mostrarMensajeSnack('Link copiado al portapapeles');
                                  },
                                )
                              ],
                            ),
                          ),
                        )),
                  )
                ],
              ),
            )));
  }
}
