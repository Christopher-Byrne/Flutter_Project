import 'dart:ffi';
import 'dart:js';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
   Future<Void> _getImageFromGallery(context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    // Do something with the picked image, like display it in an Image widget
    if (pickedImage != null) {
      // You can use the pickedImage.path to display the image
        // Navigate to the new page when the button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImagePage()),
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Test App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold
            )
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _getImageFromGallery(context),
          child: Text("Select Image"),
        ),
      ),
    );
  }

}

class ImagePage extends StatelessWidget {
  const ImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}