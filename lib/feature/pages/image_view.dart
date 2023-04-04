import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewPage extends StatelessWidget {
  const ImageViewPage({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          child: PhotoView(
            imageProvider: NetworkImage(url,),
          ),
        ),
      ),
    );
  }
}
