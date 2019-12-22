import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transfer',
      theme: ThemeData(
        backgroundColor: Colors.purple,
        accentColor: Colors.white,
        primaryColor: Colors.lightBlue,
        cardColor: Colors.amber,
      ),
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
  final picker = Picker();

  String url;
  double opacityLoad = 0.0;
  bool multipleFiles = false;

  void msgSnackBar(String msg) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
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
              brightness: Brightness.dark,
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
                        picker.getUrl(multipleFiles).then((String urlTransfer) {
                          setState(() {
                            url = urlTransfer;
                          });
                        }).catchError((error) {
                          msgSnackBar('Error subiendo el archivo');
                          setState(() {
                            opacityLoad = 0.0;
                          });
                        });
                        setState(() {
                          url = 'subiendo el archivo...';
                          opacityLoad = 1.0;
                        });
                      }),
                  Card(
                    elevation: 8.0,
                    color: Theme.of(context).cardColor,
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              'Selecciona para subir multiples archivos en ZIP',
                              style: TextStyle(color: Theme.of(context).accentColor),
                            ),
                            Switch(
                              value: multipleFiles,
                              activeColor: Theme.of(context).accentColor,
                              activeTrackColor: Theme.of(context).primaryColor,
                              onChanged: (valor) {
                                setState(() {
                                  multipleFiles = valor;
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
                    opacity: opacityLoad,
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
                                    msgSnackBar('Link copiado al portapapeles');
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
