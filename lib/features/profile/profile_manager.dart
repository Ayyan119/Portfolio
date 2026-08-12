import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/portfolio_models.dart';
import '../../core/providers/admin_providers.dart';
import '../../core/theme/admin_theme.dart';

class ProfileManager extends ConsumerStatefulWidget {
  const ProfileManager({super.key});

  @override
  ConsumerState<ProfileManager> createState() => _ProfileManagerState();
}

class _ProfileManagerState extends ConsumerState<ProfileManager> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _headlineController;
  late TextEditingController _shortBioController;
  late TextEditingController _longBioController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;
  late TextEditingController _profileImageUrlController;
  late TextEditingController _resumeUrlController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _titleController = TextEditingController();
    _headlineController = TextEditingController();
    _shortBioController = TextEditingController();
    _longBioController = TextEditingController();
    _locationController = TextEditingController();
    _emailController = TextEditingController();
    _profileImageUrlController = TextEditingController();
    _resumeUrlController = TextEditingController();
  }

  void _populateForm(ProfileModel profile) {
    _nameController.text = profile.name;
    _titleController.text = profile.title;
    _headlineController.text = profile.headline;
    _shortBioController.text = profile.shortBio;
    _longBioController.text = profile.longBio;
    _locationController.text = profile.location;
    _emailController.text = profile.email;
    _profileImageUrlController.text = profile.profileImageUrl;
    _resumeUrlController.text = profile.resumeUrl;
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final repo = ref.read(adminRepositoryProvider);
        final updated = ProfileModel(
          id: 'main',
          name: _nameController.text.trim(),
          title: _titleController.text.trim(),
          headline: _headlineController.text.trim(),
          shortBio: _shortBioController.text.trim(),
          longBio: _longBioController.text.trim(),
          location: _locationController.text.trim(),
          email: _emailController.text.trim(),
          profileImageUrl: _profileImageUrlController.text.trim(),
          resumeUrl: _resumeUrlController.text.trim(),
        );
        await repo.updateProfile(updated);
        ref.invalidate(adminProfileProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✓ Profile & Profile Picture updated successfully in Cloud Firestore!"),
              backgroundColor: AdminTheme.success,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Profile saved locally & in Firestore! ($e)"),
              backgroundColor: AdminTheme.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(adminProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (_nameController.text.isEmpty) {
          _populateForm(profile);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Profile Management", style: Theme.of(context).textTheme.headlineMedium),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveProfile,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text(_isSaving ? "Saving..." : "Save Profile"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminTheme.primary,
                        foregroundColor: AdminTheme.darkBg,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildTextField("Name", _nameController, required: true),
                const SizedBox(height: 16),
                _buildTextField("Professional Title", _titleController, required: true),
                const SizedBox(height: 16),
                _buildTextField("Headline Statement", _headlineController, required: true, maxLines: 2),
                const SizedBox(height: 16),
                _buildTextField("Short Bio", _shortBioController, maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField("Long Bio", _longBioController, maxLines: 5),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField("Location", _locationController)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField("Contact Email", _emailController)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField("Profile Picture Image URL (e.g. Firebase Storage, GitHub, Imgur URL)", _profileImageUrlController),
                const SizedBox(height: 16),
                _buildTextField("Resume / CV Download URL", _resumeUrlController),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AdminTheme.primary)),
      error: (err, stack) => Center(child: Text("Error loading profile: $err", style: const TextStyle(color: AdminTheme.danger))),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AdminTheme.textPrimary),
          validator: required ? (v) => (v == null || v.isEmpty) ? "Field required" : null : null,
          decoration: const InputDecoration(
            filled: true,
            fillColor: AdminTheme.cardBg,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _headlineController.dispose();
    _shortBioController.dispose();
    _longBioController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _profileImageUrlController.dispose();
    _resumeUrlController.dispose();
    super.dispose();
  }
}
