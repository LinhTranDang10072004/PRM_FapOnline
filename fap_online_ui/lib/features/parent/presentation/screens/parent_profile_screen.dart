import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fap_online_ui/features/parent/data/models/parent_models.dart';
import 'package:fap_online_ui/provider/auth_provider.dart';
import '../providers/parent_profile_provider.dart';
import 'package:fap_online_ui/utils/display_utils.dart';
import 'package:fap_online_ui/config/app_routes.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _dobController = TextEditingController();
  String? _gender;
  bool _prefilled = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _avatarUrlController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _bindProfile(ParentProfileData profile) {
    _fullNameController.text = profile.fullName ?? '';
    _emailController.text = profile.email ?? '';
    _phoneController.text = profile.phone ?? '';
    _addressController.text = profile.address ?? '';
    _avatarUrlController.text = profile.avatarUrl ?? '';
    _dobController.text = profile.dateOfBirth ?? '';
    _gender = _normalizeGender(profile.gender);
    _prefilled = true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParentProfileProvider>();
    final profile = provider.profile;

    if (profile != null && !_prefilled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_prefilled && provider.profile != null) {
          setState(() => _bindProfile(provider.profile!));
        }
      });
    }

    if (provider.isLoading && profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && profile == null) {
      return _ProfileError(
        message: provider.error!,
        onRetry: provider.load,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _ProfileHeader(profile: profile),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField(
                      controller: _fullNameController,
                      label: 'Full name',
                      validator: (value) => value == null || value.trim().isEmpty ? 'Full name is required' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _emailController,
                      label: 'Email',
                      readOnly: true,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _phoneController,
                      label: 'Phone',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _dobController,
                      label: 'Date of birth',
                      hintText: 'YYYY-MM-DD',
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'MALE', child: Text('Male')),
                        DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                        DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                      ],
                      onChanged: (value) => setState(() => _gender = value),
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _addressController,
                      label: 'Address',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _avatarUrlController,
                      label: 'Avatar URL',
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: provider.isSaving
                            ? null
                            : () async {
                                final profileProvider = context.read<ParentProfileProvider>();
                                final messenger = ScaffoldMessenger.of(context);
                                if (!_formKey.currentState!.validate()) return;
                                final updated = ParentProfileData(
                                  fullName: _fullNameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                  dateOfBirth: _dobController.text.trim(),
                                  gender: _gender,
                                  address: _addressController.text.trim(),
                                  avatarUrl: _avatarUrlController.text.trim(),
                                );
                                final success = await profileProvider.saveProfile(updated);
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'Profile saved' : profileProvider.error ?? 'Unable to save profile'),
                                  ),
                                );
                              },
                        child: provider.isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              )
                            : const Text('Save profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  String? _normalizeGender(String? gender) {
    if (gender == null) return null;
    final value = gender.trim().toUpperCase();
    switch (value) {
      case 'MALE':
      case 'FEMALE':
      case 'OTHER':
        return value;
      default:
        return null;
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final ParentProfileData? profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasAvatar = (profile?.avatarUrl ?? '').trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: scheme.primaryContainer,
            backgroundImage: hasAvatar ? NetworkImage(profile!.avatarUrl!) : null,
            child: hasAvatar ? null : Icon(Icons.person, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayText(profile?.fullName, fallback: 'Parent profile'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(displayText(profile?.email)),
                const SizedBox(height: 6),
                Text(
                  '${displayText(profile?.phone)} • ${displayText(profile?.gender)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ProfileError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 12),
            Text(
              'Could not load profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
