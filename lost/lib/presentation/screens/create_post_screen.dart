import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/finder_colors.dart';
import '../widgets/map_location_picker.dart';
import '../../data/datasources/ai_matching_remote_data_source.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = 'Wallet';
  String _selectedType = 'Lost';
  File? _selectedImage;
  bool _isLoading = false;
  LatLng? _selectedCoordinates;

  // Backend data source
  late final AIMatchingRemoteDataSource _dataSource;

  final List<String> _categories = [
    'Wallet',
    'Phone',
    'Keys',
    'Bag',
    'Electronics',
    'Documents',
    'Jewelry',
    'Clothing',
    'Other',
  ];

  final List<String> _types = ['Lost', 'Found'];

  @override
  void initState() {
    super.initState();
    _dataSource = AIMatchingRemoteDataSource(client: http.Client());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                color: FinderColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Image Source',
              style: TextStyle(
                color: FinderColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A3D91).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, color: Color(0xFF0A3D91)),
              ),
              title: const Text(
                'Camera',
                style: TextStyle(color: FinderColors.textPrimary),
              ),
              subtitle: const Text(
                'Take a new photo',
                style: TextStyle(color: FinderColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A3D91).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF0A3D91),
                ),
              ),
              title: const Text(
                'Gallery',
                style: TextStyle(color: FinderColors.textPrimary),
              ),
              subtitle: const Text(
                'Choose from gallery',
                style: TextStyle(color: FinderColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _openMapPicker() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
          onLocationSelected: (address, coordinates) {
            setState(() {
              _locationController.text = address;
              _selectedCoordinates = coordinates;
            });
          },
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add an image of the item'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        print('📤 Submitting post to backend...');
        print('   Title: ${_titleController.text}');
        print('   Type: ${_selectedType.toLowerCase()}');
        print('   Category: $_selectedCategory');

        // Call backend API
        final result = await _dataSource.createPostWithMatching(
          image: _selectedImage!,
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          location: _locationController.text,
          postType: _selectedType.toLowerCase(),
          latitude: _selectedCoordinates?.latitude,
          longitude: _selectedCoordinates?.longitude,
        );

        print('✅ Backend response received: $result');
        setState(() => _isLoading = false);

        // Navigate to AI matching results with real data from backend
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/ai-matching-results',
            arguments: {
              'postId': result['post_id'],
              'matchesCount': result['matches_count'],
              'matches': result['matches'],
              'success': result['success'],
              // Include user's post data for preview
              'title': _titleController.text,
              'description': _descriptionController.text,
              'category': _selectedCategory,
              'location': _locationController.text,
              'postType': _selectedType,
              'latitude': _selectedCoordinates?.latitude,
              'longitude': _selectedCoordinates?.longitude,
              'imageUrl': _selectedImage?.path ?? '',
            },
          );
        }
      } catch (e) {
        print('❌ Error submitting post: $e');
        setState(() => _isLoading = false);

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _submitPost,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinderColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A3D91),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Report Item',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white70),
                onPressed: () {
                  // Show help dialog
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Upload Section
                GestureDetector(
                  onTap: _showImagePickerModal,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0A3D91),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _selectedImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedImage = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0A3D91,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Color(0xFF0A3D91),
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Add Photo',
                                style: TextStyle(
                                  color: FinderColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tap to upload an image of the item',
                                style: TextStyle(
                                  color: FinderColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Type Selection (Lost/Found)
                const Text(
                  'Type',
                  style: TextStyle(
                    color: FinderColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _types.map((type) {
                    final isSelected = _selectedType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: Container(
                          margin: EdgeInsets.only(
                            right: type == 'Lost' ? 8 : 0,
                            left: type == 'Found' ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0A3D91)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0A3D91)
                                  : FinderColors.lightBrown,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                type == 'Lost'
                                    ? Icons.search
                                    : Icons.check_circle_outline,
                                color: isSelected
                                    ? Colors.white
                                    : FinderColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                type,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : FinderColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Title Field
                _buildLabel('Title'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hint: 'e.g., Black Leather Wallet',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                _buildLabel('Category'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0A3D91)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: FinderColors.textSecondary,
                      ),
                      style: const TextStyle(
                        color: FinderColors.textPrimary,
                        fontSize: 16,
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Description Field
                _buildLabel('Description'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'Describe the item (color, brand, unique features...)',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Location Field with Map Picker
                _buildLabel('Location'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _openMapPicker,
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _locationController,
                      hint: 'Tap to select location from map',
                      prefixIcon: Icons.location_on_outlined,
                      suffixIcon: Icons.map_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a location';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A3D91),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedType == 'Lost'
                                    ? 'Find Matches with AI'
                                    : 'Post & Find Owner',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: FinderColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? prefixIcon,
    IconData? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: FinderColors.textPrimary, fontSize: 16),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: FinderColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: FinderColors.textSecondary)
            : null,
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: const Color(0xFF0A3D91))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A3D91)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A3D91)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A3D91), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
