import 'dart:io';
import 'package:PDFCompressor/view_pdf.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Compressor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _quality = 2;
  String _filepath = '';
  String _message = '';
  bool _processing = false;
  bool _show = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: android);

    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: _onSelectNotification);
  }

  Future<void> _onSelectNotification(String path) async {
    if (path != 'null') OpenFile.open(path);
  }

  Future<void> _showNotification(bool error, String path) async {
    final android = AndroidNotificationDetails(
        'channel id', 'channel name', 'channel description',
        priority: Priority.high, importance: Importance.max);
    final platform = NotificationDetails(android: android);

    await flutterLocalNotificationsPlugin.show(
        0,
        error ? 'Error Occurred' : 'PDF Compression Successful',
        error
            ? 'There was an error while downloading the file!'
            : 'File successfully downloaded!',
        platform,
        payload: error ? 'null' : path);
  }

  Future<void> handlePick() async {
    FilePickerResult result = await FilePicker.platform
        .pickFiles(allowedExtensions: ['pdf'], type: FileType.custom);

    if (result != null) {
      setState(() {
        _filepath = result.files.single.path;
      });
    } else {
      // User canceled the picker
    }
  }

  Future<void> handleCompress() async {
    setState(() {
      _processing = true;
    });
    if (await Permission.storage.request().isGranted) {
      try {
        print('Starting Compression at lvl : $_quality');
        const String url = 'https://calm-lake-61286.herokuapp.com/upload';
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.fields['quality'] = _quality.toString();
        request.files.add(await http.MultipartFile.fromPath('file', _filepath));
        var res = await request.send();
        if (res.statusCode != 200) throw Error();
        print('Compression Complete');
        var bytes = await res.stream.toBytes();
        String filename =
            new DateTime.now().toString() + _filepath.split('/').last;
        File file = new File('/storage/emulated/0/Download/$filename');
        await file.writeAsBytes(bytes);
        print('File Downloaded!');
        setState(() {
          _message = 'Compression Successful!';
          _processing = false;
        });
        _showNotification(false, file.path);
      } catch (error) {
        setState(() {
          _message = 'Error Occurred!';
          _processing = false;
        });
        print('Error!');
        _showNotification(true, '');
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffb282a36),
      body: _show
          ? ViewPDF()
          : Container(
              width: double.infinity,
              child: _processing
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'PDF Compressor',
                          style: TextStyle(
                            color: Color(0xffbf8f8f2),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _filepath == ''
                                  ? 'No file Selected!'
                                  : (_filepath.split('/').last.length > 25
                                      ? '${_filepath.split('/').last.substring(0, 25)}...'
                                      : _filepath.split('/').last),
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Color(0xffbf8f8f2),
                              ),
                            ),
                            SizedBox(width: 12),
                            RaisedButton(
                              onPressed: () async {
                                await handlePick();
                              },
                              color: Color(0xffbff79c6),
                              child: Text(
                                'Select File',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffbf8f8f2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 22),
                        Text(
                          'Compression Level : $_quality',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffbf8f8f2),
                          ),
                        ),
                        Slider(
                          value: _quality.toDouble() > 4
                              ? 2.0
                              : _quality.toDouble(),
                          divisions: 4,
                          min: 0,
                          max: 4,
                          onChanged: (value) {
                            setState(() {
                              _quality = value.toInt();
                            });
                          },
                        ),
                        SizedBox(height: 22),
                        RaisedButton(
                          onPressed: _filepath == ''
                              ? null
                              : () async {
                                  await handleCompress();
                                },
                          color: Color(0xffb50fa7b),
                          disabledColor: Color(0xffbf8f8f2),
                          disabledTextColor: Colors.grey,
                          child: Text(
                            'Compress',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _filepath == ''
                                  ? Colors.grey
                                  : Color(0xffbf8f8f2),
                            ),
                          ),
                        ),
                        SizedBox(height: 22),
                        _message != ''
                            ? Text(_message,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffbf8f8f2),
                                ))
                            : SizedBox(),
                      ],
                    ),
            ),
      resizeToAvoidBottomInset: false,
      persistentFooterButtons: [
        Container(
          height: 35,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  const String url =
                      'https://github.com/real4suraj2/PDFCompressor';
                  if (await canLaunch(url)) await launch(url);
                },
                child: Image.asset(
                  'assets/git.png',
                  width: 30,
                  height: 30,
                ),
              ),
              SizedBox(width: 12),
              FlatButton(
                onPressed: () {
                  setState(() {
                    _show = !_show;
                  });
                },
                child: Text(
                  _show ? 'Use PDF Compressor' : 'View PDF Online',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xffbf8f8f2),
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
