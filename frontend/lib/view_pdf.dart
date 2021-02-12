import 'package:PDFCompressor/pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewPDF extends StatefulWidget {
  @override
  _ViewPDFState createState() => _ViewPDFState();
}

class _ViewPDFState extends State<ViewPDF> {
  TextEditingController _linkController = TextEditingController(text: '');
  bool _show = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: TextField(
                        controller: _linkController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xffbbd93f9),
                          ),
                          hintStyle: TextStyle(
                            fontSize: 13.0,
                            color: Color(0xffbffb86c),
                          ),
                          hintText: 'Enter a PDF Url',
                          contentPadding: EdgeInsets.all(4.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xffbbd93f9),
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xffbbd93f9),
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        style: TextStyle(
                          color: Color(0xffbffb86c),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    RaisedButton(
                      onPressed: () {
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (BuildContext context) =>
                        //         Pdf(_linkController.text),
                        //   ),
                        // );
                        if (!_show)
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                        else
                          _linkController.text = '';
                        setState(() {
                          _show = !_show;
                        });
                      },
                      color: Color(0xffbbd93f9),
                      child: Text(
                        _show ? 'Close' : 'View',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xffbf8f8f2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _show ? Flexible(child: Pdf(_linkController.text)) : SizedBox(),
            ],
          )),
    );
  }
}
