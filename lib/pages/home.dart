import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _getImageFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePage(imagePath: pickedImage.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Test App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _getImageFromGallery(context),
          child: const Text("Select Image"),
        ),
      ),
    );
  }
}

class ImagePage extends StatefulWidget {
  final String imagePath;

  const ImagePage({super.key, required this.imagePath});

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  late String hexCode = ''; // Initialize with an empty string

  @override
  void initState() {
    super.initState();
    // Read the image file and compute the hex code
    _computeHexCode(widget.imagePath);
  }

  Future<void> _computeHexCode(String imagePath) async {
    try {
      // Read the image file as bytes
      final bytes = await File(imagePath).readAsBytes();
      // Convert bytes to hex string
      hexCode = bytesToHex(bytes);
      setState(() {}); // Update the UI
    } catch (e) {
      // Handle any errors that occur during file reading
      hexCode = "Error reading file: $e";
      setState(() {});
    }
  }

  String bytesToHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (var byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selected Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.file(File(widget.imagePath)),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  readOnly: true,  // Make the TextField read-only
                  maxLines: null,  // Allow for multiple lines
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Hex Code',
                  ),
                  controller: TextEditingController(text: hexCode),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
