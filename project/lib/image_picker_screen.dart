import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen>
    with TickerProviderStateMixin {
  File? _image;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isLoading = false;
        });
        _animationController.reset();
        _animationController.forward();

        HapticFeedback.lightImpact();

        _showSuccessSnackBar("Image selected successfully!");
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar("Failed to pick image: ${e.toString()}");
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        // For demo, just use the first image
        setState(() {
          _image = File(pickedFiles.first.path);
          _isLoading = false;
        });
        _animationController.reset();
        _animationController.forward();

        HapticFeedback.lightImpact();

        _showSuccessSnackBar("${pickedFiles.length} image(s) selected!");
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar("Failed to pick images: ${e.toString()}");
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Image Source",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: "Camera",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_outlined,
                  label: "Gallery",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.collections_outlined,
                  label: "Multiple",
                  onTap: () {
                    Navigator.pop(context);
                    _pickMultipleImages();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview() {
    if (_image == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 40,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
    HapticFeedback.lightImpact();
    _showSuccessSnackBar("Image removed");
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Image Picker"),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          if (_image != null)
            IconButton(
              onPressed: _removeImage,
              icon: const Icon(Icons.delete_outline),
              tooltip: "Remove image",
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image Display Area
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _image != null
                  ? ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildImageContainer(),
                    )
                  : _buildPlaceholderContainer(),
            ),

            const SizedBox(height: 40),

            // Action Buttons
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Processing image..."),
                  ],
                ),
              )
            else
              Column(
                children: [
                  // Main pick button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showImageSourceBottomSheet,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(
                        _image == null ? "Select Image" : "Change Image",
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text("Camera"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text("Gallery"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 40),

            // Image Info Card
            if (_image != null) _buildImageInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer() {
    return GestureDetector(
      onTap: _showImagePreview,
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _image!,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderContainer() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No image selected",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the button below to select an image",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildImageInfoCard() {
    final file = File(_image!.path);
    final fileSize = file.lengthSync();
    final fileSizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Image Information",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow("File Size", "$fileSizeInMB MB"),
          _buildInfoRow("Path", _image!.path.split('/').last),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
