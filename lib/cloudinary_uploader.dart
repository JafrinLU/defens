import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class CloudinaryUploadPage extends StatefulWidget {
  const CloudinaryUploadPage({super.key});

  @override
  State<CloudinaryUploadPage> createState() => _CloudinaryUploadPageState();
}

class _CloudinaryUploadPageState extends State<CloudinaryUploadPage> {
  File? _image;
  bool _isUploading = false;
  String? _uploadedImageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() => _isUploading = true);

    const cloudName = 'dxhfsxl6l';
    const uploadPreset = 'uploads';

    final url = Uri.parse('https://console.cloudinary.com/app/c-6663cf30915157bb256dbfade29216/settings/upload/presets');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = res.body;
      final imageUrl = RegExp(r'"secure_url":"(.*?)"').firstMatch(data)?.group(1);
      setState(() => _uploadedImageUrl = imageUrl);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload successful!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: ${res.body}")));
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cloudinary Upload")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? const Text("No image selected")
                : Image.file(_image!, height: 200),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick Image"),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: _isUploading ? const CircularProgressIndicator() : const Text("Upload to Cloudinary"),
            ),
            if (_uploadedImageUrl != null) ...[
              const SizedBox(height: 20),
              Text("Uploaded Image URL:"),
              SelectableText(_uploadedImageUrl!),
              Image.network(_uploadedImageUrl!)
            ]
          ],
        ),
      ),
    );
  }
}
