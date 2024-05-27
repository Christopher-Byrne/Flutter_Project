import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _getImageFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedImage.path);
      final savedImage = await File(pickedImage.path).copy('${appDir.path}/$fileName');


      final prefs = await SharedPreferences.getInstance();
      List<String> cachedImages = prefs.getStringList('cached_images') ?? [];
      cachedImages.add(savedImage.path);
      await prefs.setStringList('cached_images', cachedImages);

      if (!context.mounted) {
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePage(imagePath: pickedImage.path),
        ),
      );
    }
  }

  Future<void> _getCachedImages(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final isAuthenticated = await localAuth.authenticate(
      localizedReason: 'Please authenticate to access cached images',
      options: const AuthenticationOptions(biometricOnly: false),
    );

    if (isAuthenticated) {
      if(!context.mounted){
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CachedImagesPage(),
        ),
      );
    }
  }

    Future<void> _manageCachedImages(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final isAuthenticated = await localAuth.authenticate(
      localizedReason: 'Please authenticate to access cached images',
      options: const AuthenticationOptions(biometricOnly: false),
    );

    if (isAuthenticated) {
      if(!context.mounted){
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ManageCachedImagesPage(),
        ),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('image_assets/logo white.png',
        fit: BoxFit.contain,
        height: 55,),
        backgroundColor: const Color.fromRGBO(0, 150, 250, 1),
        centerTitle: true,
        shadowColor: Colors.blueGrey,
        elevation: 10,
        toolbarHeight: 70,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromRGBO(0, 150, 250, 1),
                fixedSize: const Size(250, 40)
              ),
              onPressed: () => _getImageFromGallery(context),
              child: const Text("Select Image from Gallery"),
            ),
            ElevatedButton(
               style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromRGBO(0, 150, 250, 1),
                fixedSize: const Size(250, 40)
              ),
              onPressed: () => _getCachedImages(context),
              child: const Text("Access Cached Image"),
            ),
            ElevatedButton(
               style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromRGBO(0, 150, 250, 1),
                fixedSize: const Size(250, 40)
              ),
              onPressed: () => _manageCachedImages(context),
              child: const Text("Manage Cached Images"),
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePage extends StatefulWidget {
  final String imagePath;

  const ImagePage({super.key, required this.imagePath});

  @override
  // ignore: library_private_types_in_public_api
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  late String code = ''; // Initialize with an empty string

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
      code = bytesToCode(bytes);
      setState(() {}); // Update the UI
    } catch (e) {
      // Handle any errors that occur during file reading
      code = "Error reading file: $e";
      setState(() {});
    }
  }

  String bytesToCode(List<int> bytes) {
    int hash = 0;
    String pw = "";
    const String charSet = 'abcdefghijk098lmnopqrstuvwxy!£#?*&aABC345DEFGHIJKLMNOP712QRSTUVWXYZ!£#?*&';
    const String nums = '0987612345';
    const String special = '!£#?*&';
    for (var bit in bytes) {
      hash = (hash + (bit ^ (hash << 5)));
    }
    
    for (int i = 0; i < 16; i++){
      if(i == 7){
        pw += nums[hash % nums.length];
        hash ~/= (charSet.length/5);
      }
      else if(i == 10){
        pw += special[hash % special.length];
        hash ~/= (charSet.length/5);
      }
      else{
        pw += charSet[hash % charSet.length];
      hash ~/= (charSet.length/5);
      }
    }
    return pw;
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
            SizedBox(
              width: 300,  // Set a fixed width
              height: 300, // Set a fixed height
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain, // Ensure the image fits within the box
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  readOnly: true,  // Make the TextField read-only
                  maxLines: null,  // Allow for multiple lines
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'PASSPIX CODE',
                  ),
                  controller: TextEditingController(text: code),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CachedImagesPage extends StatelessWidget {
  const CachedImagesPage({super.key});

  Future<List<String>> _loadCachedImages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cached_images') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cached Images'),
      ),
      body: FutureBuilder<List<String>>(
        future: _loadCachedImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading cached images'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cached images found'));
          } else {
            final cachedImages = snapshot.data!;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: cachedImages.length,
              itemBuilder: (context, index) {
                final imagePath = cachedImages[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImagePage(imagePath: imagePath),
                      ),
                    );
                  },
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

void showAlertDialog(BuildContext context, List<String> cachedImages, String imagePath) {
  // Set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: const Text("Delete"),
    onPressed: () async {
      // Remove the image path from the cached images list
      cachedImages.remove(imagePath);
      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('cached_images', cachedImages);
      // Delete the file from the file system
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
      if(!context.mounted){
        return;
      }
      // Pop the dialog
      Navigator.of(context).pop();
      // Refresh the UI by rebuilding the widget
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ManageCachedImagesPage()),
      );
    },
  );

  // Set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Delete Image"),
    content: const Text("Are you sure you want to delete this image?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // Show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class ManageCachedImagesPage extends StatelessWidget {
  const ManageCachedImagesPage({super.key});

  Future<List<String>> _loadCachedImages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cached_images') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Cached Images'),
      ),
      body: FutureBuilder<List<String>>(
        future: _loadCachedImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading cached images'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cached images found'));
          } else {
            final cachedImages = snapshot.data!;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: cachedImages.length,
              itemBuilder: (context, index) {
                final imagePath = cachedImages[index];
                return GestureDetector(
                  onLongPress: () {
                    showAlertDialog(context, cachedImages, imagePath);
                  },
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}