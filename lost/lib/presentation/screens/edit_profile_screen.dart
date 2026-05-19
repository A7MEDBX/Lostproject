import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/app_messenger.dart';
import '../../core/utils/location_data.dart';
import '../widgets/location_autocomplete_field.dart';
import '../providers/user_provider.dart';

/// Edit Profile Screen
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _addressController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();

  final FocusNode _countryFocus = FocusNode();
  final FocusNode _stateFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _areaFocus = FocusNode();

  String _selectedGender = 'Male';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill from backend user if available, fall back to Firebase.
    final backendUser =
        context.read<UserProvider>().backendUser;
    final firebaseUser = AuthService.instance.currentUser;

    _nameController = TextEditingController(
      text: backendUser?.name ?? firebaseUser?.displayName ?? '',
    );
    _emailController = TextEditingController(
      text: backendUser?.email ?? firebaseUser?.email ?? '',
    );
    _phoneController = TextEditingController(
      text: backendUser?.phoneNumber ?? '',
    );
    _countryController.text = backendUser?.country ?? '';
    _stateController.text = backendUser?.state ?? '';
    _cityController.text = backendUser?.city ?? '';
    _areaController.text = backendUser?.area ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _countryFocus.dispose();
    _stateFocus.dispose();
    _cityFocus.dispose();
    _areaFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blue Curved Top Section
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A3D91),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(150),
                      bottomRight: Radius.circular(150),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/avatar_placeholder.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF0A3D91),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF0A3D91),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

              // User's name from backend
              Text(
                _nameController.text.isEmpty ? 'Your Profile' : _nameController.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

            const SizedBox(height: 30),

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name Field
                    const Text(
                      'Full name',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Email Field
                    const Text(
                      'Email',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Phone Number Field
                    const Text(
                      'Phone Number',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: Image.network(
                              'https://flagcdn.com/w40/us.png',
                              width: 24,
                              height: 16,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 24,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '🌍',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Country Field
                    const Text(
                      'Country',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    LocationAutocompleteField(
                      controller: _countryController,
                      focusNode: _countryFocus,
                      hint: 'Select Country',
                      optionsBuilder: (textEditingValue) => 
                        LocationDataService.getCountries(textEditingValue.text),
                      onSelected: (selection) {
                        setState(() {
                          _countryController.text = selection;
                          _stateController.clear();
                          _cityController.clear();
                        });
                        _stateFocus.requestFocus();
                      },
                      itemPrefixBuilder: LocationDataService.getCountryFlag,
                    ),

                    const SizedBox(height: 20),

                    // State and City Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'State',
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              LocationAutocompleteField(
                                key: ValueKey('state_${_countryController.text}'),
                                controller: _stateController,
                                focusNode: _stateFocus,
                                hint: 'Select State',
                                optionsBuilder: (textEditingValue) =>
                                  LocationDataService.getStates(_countryController.text, textEditingValue.text),
                                onSelected: (selection) {
                                  setState(() {
                                    _stateController.text = selection;
                                    _cityController.clear();
                                  });
                                  _cityFocus.requestFocus();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'City',
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              LocationAutocompleteField(
                                key: ValueKey('city_${_countryController.text}_${_stateController.text}'),
                                controller: _cityController,
                                focusNode: _cityFocus,
                                hint: 'Select City',
                                optionsBuilder: (textEditingValue) =>
                                  LocationDataService.getCities(_countryController.text, _stateController.text, textEditingValue.text),
                                onSelected: (selection) {
                                  setState(() {
                                    _cityController.text = selection;
                                    _areaController.clear();
                                  });
                                  if (_stateController.text != LocationDataService.travelingState) {
                                    _areaFocus.requestFocus();
                                  } else {
                                    _cityFocus.unfocus();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (_stateController.text != LocationDataService.travelingState) ...[
                      const SizedBox(height: 20),
                      // Area Field
                      const Text(
                        'Area / District',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      LocationAutocompleteField(
                        key: ValueKey('area_${_countryController.text}_${_stateController.text}_${_cityController.text}'),
                        controller: _areaController,
                        focusNode: _areaFocus,
                        hint: 'Select Area / District',
                        optionsBuilder: (textEditingValue) =>
                          LocationDataService.getAreas(
                            _countryController.text,
                            _stateController.text,
                            _cityController.text,
                            textEditingValue.text,
                          ),
                        onSelected: (selection) {
                          setState(() {
                            _areaController.text = selection;
                          });
                          _areaFocus.unfocus();
                        },
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Gender Field
                    const Text(
                      'Gender',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                          items: ['Male', 'Female'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedGender = newValue!;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Address Field
                    const Text(
                      'Address',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;

                                setState(() => _isLoading = true);

                                try {
                                  final apiClient = ApiClient(
                                    tokenProvider: AuthService.instance.getIdToken,
                                  );

                                  // Update backend profile
                                  await apiClient.put(
                                    ApiConstants.userProfileEndpoint,
                                    body: {
                                      'name': _nameController.text.trim(),
                                      'phone': _phoneController.text.trim(),
                                      'country': _countryController.text.trim(),
                                      'state': _stateController.text.trim(),
                                      'city': _cityController.text.trim(),
                                      'area': _areaController.text.trim(),
                                    },
                                  );

                                  // Update Firebase display name too
                                  await AuthService.instance.currentUser
                                      ?.updateDisplayName(_nameController.text.trim());

                                  // Reload UserProvider so Profile screen updates
                                  if (mounted) {
                                    await context.read<UserProvider>().loadUser();
                                  }

                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                    AppMessenger.showSuccess('Profile updated successfully!');
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                    AppMessenger.showError('Failed to save changes. Please try again.');
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A3D91),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: const Color(0xFF0A3D91).withOpacity(0.5),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
