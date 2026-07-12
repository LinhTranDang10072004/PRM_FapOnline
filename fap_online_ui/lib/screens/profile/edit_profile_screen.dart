import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../provider/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/response/profile_dto.dart';
import '../../config/api_endpoints.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  ProfileDTO? _profile;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final profile = context.read<ProfileProvider>().profile;
    if (profile != null) {
      _profile = profile;
      _nameController.text = profile.fullName ?? '';
      _emailController.text = profile.email ?? '';
      _phoneController.text = profile.phone ?? '';
      _addressController.text = profile.address ?? '';
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Chụp ảnh mới'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (image == null || !mounted) return;
      final imageBytes = await image.readAsBytes();
      if (imageBytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể đọc ảnh đã chọn.')),
        );
        return;
      }
      setState(() {
        _selectedImageBytes = imageBytes;
        _selectedImageName = image.name.isNotEmpty ? image.name : 'avatar.jpg';
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể chọn ảnh. Vui lòng thử lại.')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final profileProvider = context.read<ProfileProvider>();

    setState(() {
      _isSaving = true;
    });

    String? newAvatarUrl = _profile?.avatarUrl;

    // Upload image if selected
    if (_selectedImageBytes != null) {
      final uploadedUrl = await profileProvider.uploadAvatar(
        _selectedImageBytes!,
        _selectedImageName ?? 'avatar.jpg',
      );
      if (uploadedUrl == null) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                profileProvider.error ?? 'Không thể tải ảnh đại diện lên.',
              ),
            ),
          );
        }
        return;
      }
      newAvatarUrl = uploadedUrl;
    }

    final updatedProfile = ProfileDTO(
      fullName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      avatarUrl: newAvatarUrl,
    );

    final success = await profileProvider.updateProfile(updatedProfile);

    setState(() {
      _isSaving = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lưu thông tin thành công')));
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.error ?? 'Lưu thông tin thất bại'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Chỉnh sửa thông tin',
            style: AppTextStyles.subtitle,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin', style: AppTextStyles.subtitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryLight.withOpacity(
                          0.2,
                        ),
                        child: _selectedImageBytes != null
                            ? ClipOval(
                                child: Image.memory(
                                  _selectedImageBytes!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (_profile?.avatarUrl != null &&
                                      _profile!.avatarUrl!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        ApiEndpoints.getImageUrl(
                                          _profile!.avatarUrl!,
                                        ),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.person,
                                              size: 40,
                                              color: AppColors.primary,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColors.primary,
                                    )),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _isSaving ? null : _pickImage,
                icon: const Icon(Icons.photo_outlined),
                label: Text(
                  _selectedImageBytes == null
                      ? 'Chọn ảnh đại diện'
                      : 'Đã chọn ảnh mới',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Vui lòng nhập email';
                  if (!value.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Vui lòng nhập SĐT';
                  if (!RegExp(r'^0[0-9]{9,10}$').hasMatch(value)) {
                    return 'SĐT không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _profile?.email ?? '',
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email đăng ký',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  fillColor: AppColors.divider.withOpacity(0.5),
                  filled: true,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Lưu thay đổi'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
