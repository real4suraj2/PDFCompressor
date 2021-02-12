import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class Pdf extends StatefulWidget {
  Pdf(this.url);
  final String url;

  @override
  _PdfState createState() => _PdfState();
}

class _PdfState extends State<Pdf> {
  PDFViewController _pdfController;
  String _filepath = '';
  double _page = 0;
  double _total = 0;

  Future<String> saveThumbnail() async {
    if (_filepath != '') return _filepath;
    File file = await DefaultCacheManager().getSingleFile(widget.url);
    Stream<PdfRaster> rasters = Printing.raster(await file.readAsBytes());
    final imageData = (await rasters.first).toPng();
    String dir = (await getExternalStorageDirectory()).path;
    String filename = new DateTime.now().toString() + '.png';
    File image = new File('$dir/$filename');
    await image.writeAsBytes(await imageData);
    print('Thumbnail Saved!');
    setState(() {
      _filepath = file.path;
    });
    return file.path;
  }

  Widget pdfWidget() {
    return FutureBuilder(
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.none &&
                snap.hasData == null ||
            snap.data == null) {
          return Container(
              child: Center(
                  child: Text(
            'Please Wait... \n Make sure to verify the provided URL is correct',
            style: TextStyle(color: Color(0xffbf8f8f2)),
            textAlign: TextAlign.center,
          )));
        }
        if (snap.data.toString().substring(
                snap.data.toString().length - 3, snap.data.toString().length) !=
            'pdf')
          return Container(
              child: Center(
                  child: Text('Invalid Url!',
                      style: TextStyle(color: Color(0xffbf8f8f2)))));
        return Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: Center(
                child: PDF(
                  autoSpacing: false,
                  pageFling: true,
                  fitPolicy: FitPolicy.WIDTH,
                  onPageChanged: (int page, int total) {
                    // print('page change: $page/$total');
                    if (_total == 0)
                      setState(() {
                        _total = total.toDouble();
                      });

                    setState(() {
                      _page = page.toDouble();
                    });
                  },
                  onViewCreated: (PDFViewController pdfController) async {
                    setState(() {
                      _pdfController = pdfController;
                    });
                    saveThumbnail();
                  },
                ).fromPath(snap.data),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 20,
                height: MediaQuery.of(context).size.height - 100,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Slider(
                    value: _page.toDouble(),
                    min: 0,
                    max: _total > 0 ? _total - 1 : _total,
                    onChanged: (value) async {
                      if (value.toInt() != _page.toInt())
                        await _pdfController.setPage(value.toInt());
                      _page = value;
                      setState(() {
                        _page = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
      future: saveThumbnail(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pdfWidget();
  }
}
