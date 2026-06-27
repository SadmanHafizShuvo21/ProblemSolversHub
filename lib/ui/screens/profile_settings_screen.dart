import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:problem_solvers_hub/core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:problem_solvers_hub/features/auth/domain/entities/user.dart';
import 'package:problem_solvers_hub/features/auth/presentation/providers/auth_providers.dart';

const _availableSkills = [
  'Flutter',
  'Dart',
  'Firebase',
  'UI/UX',
  'API Design',
  'Database',
  'DevOps',
  'Machine Learning',
  'React',
  'Node.js',
  'Python',
  'Java',
  'Swift',
  'Kotlin',
  'AWS',
  'Docker',
  'Kubernetes',
  'GraphQL',
  'REST API',
  'Microservices',
];

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _githubController = TextEditingController();
  final _twitterController = TextEditingController();
  final _leetcodeController = TextEditingController();
  final _linkedinController = TextEditingController();
  
  String _theme = 'system';
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _publicProfile = true;
  List<String> _skills = [];
  Uint8List? _profileImageBytes;
  String? _profileUrl;
  bool _saving = false;
  bool _isUploadingImage = false;
  bool _hasPopulated = false;
  Color? _selectedPrimaryColor;
  Color? _selectedBackgroundColor;

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _githubController.dispose();
    _twitterController.dispose();
    _leetcodeController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (photo == null) return;

    final bytes = await photo.readAsBytes();
    setState(() {
      _profileImageBytes = bytes;
      _isUploadingImage = true;
    });

    // Simulate upload delay for UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo selected. Save to update profile picture.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    });
  }

  Future<void> _saveProfile(User user) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _saving = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      String? photoUrl = _profileUrl;

      // FIX 1: Check if image bytes exist before uploading
      if (_profileImageBytes != null) {
        photoUrl = await authNotifier.uploadProfileImage(_profileImageBytes!);
      }

      final updatedUser = await authNotifier.updateProfile(
        userId: user.id,
        displayName: _displayNameController.text.trim(),
        photoUrl: photoUrl,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        githubUsername: _githubController.text.trim().isEmpty ? null : _githubController.text.trim(),
        twitterUsername: _twitterController.text.trim().isEmpty ? null : _twitterController.text.trim(),
        leetcodeUsername: _leetcodeController.text.trim().isEmpty ? null : _leetcodeController.text.trim(),
        linkedinUsername: _linkedinController.text.trim().isEmpty ? null : _linkedinController.text.trim(),
        skills: _skills,
        theme: _theme,
        emailNotifications: _emailNotifications,
        pushNotifications: _pushNotifications,
        publicProfile: _publicProfile,
      );

      if (!mounted) return;
      if (updatedUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // FIX 2: Use context.pop() after successful save
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Unable to save profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              const Text('Delete Account'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This action is permanent and cannot be undone.'),
              SizedBox(height: 12),
              Text(
                'You will lose:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text('• All your posts and comments'),
              Text('• Your reputation and badges'),
              Text('• Saved problems and solutions'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ref.read(authProvider.notifier).deleteAccount();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/auth');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete account failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _populateFromUser(User user) {
    _displayNameController.text = user.displayName;
    _bioController.text = user.bio ?? '';
    _locationController.text = user.location ?? '';
    _websiteController.text = user.website ?? '';
    _githubController.text = user.githubUsername ?? '';
    _twitterController.text = user.twitterUsername ?? '';
    _leetcodeController.text = user.leetcodeUsername ?? '';
    _linkedinController.text = user.linkedinUsername ?? '';
    _theme = user.theme;
    _emailNotifications = user.emailNotifications;
    _pushNotifications = user.pushNotifications;
    _publicProfile = user.publicProfile;
    _skills = List<String>.from(user.skills);
    _profileUrl = user.photoUrl;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return authState.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Profile Settings')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Profile Settings')),
        body: Center(child: Text('Error loading settings: $error')),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile Settings')),
            body: const Center(child: Text('You must be logged in to update settings.')),
          );
        }

        if (!_hasPopulated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _populateFromUser(user);
              _hasPopulated = true;
            });
          });
        }

        final image = _profileImageBytes != null
            ? Image.memory(_profileImageBytes!, fit: BoxFit.cover)
            : (user.photoUrl != null
                ? Image.network(user.photoUrl!, fit: BoxFit.cover)
                : null);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F7FA),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            title: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: _saving ? null : () => _saveProfile(user),
                  style: TextButton.styleFrom(
                    backgroundColor: _saving ? Colors.grey[300] : const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Profile Image Section - LinkedIn Style
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.transparent : const Color.fromRGBO(0, 0, 0, 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Photo - Facebook/LeetCode Style
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF4F46E5),
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4F46E5).withAlpha(40),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: image ??
                                        Center(
                                          child: Text(
                                            user.displayName.isNotEmpty
                                                ? user.displayName[0].toUpperCase()
                                                : '?',
                                            style: TextStyle(
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : const Color(0xFF4F46E5),
                                            ),
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            if (_isUploadingImage)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withAlpha(180),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: _pickProfileImage,
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap the camera icon to change photo',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Personal Info Section - LinkedIn Style
                  _buildSectionCard(
                    isDark: isDark,
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    child: Column(
                      children: [
                        _buildStyledTextField(
                          controller: _displayNameController,
                          label: 'Full Name',
                          icon: Icons.person,
                          isDark: isDark,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildStyledTextField(
                          controller: _bioController,
                          label: 'Bio',
                          icon: Icons.description,
                          isDark: isDark,
                          maxLines: 3,
                          hint: 'Tell us about yourself...',
                        ),
                        const SizedBox(height: 16),
                        _buildStyledTextField(
                          controller: _locationController,
                          label: 'Location',
                          icon: Icons.location_on,
                          isDark: isDark,
                          hint: 'City, Country',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Social Links Section - LinkedIn Style
                  _buildSectionCard(
                    isDark: isDark,
                    icon: Icons.link,
                    title: 'Social & Professional Links',
                    child: Column(
                      children: [
                        _buildStyledTextField(
                          controller: _websiteController,
                          label: 'Website',
                          icon: Icons.language,
                          isDark: isDark,
                          hint: 'https://yourwebsite.com',
                        ),
                        const SizedBox(height: 12),
                        _buildStyledTextField(
                          controller: _githubController,
                          label: 'GitHub',
                          icon: Icons.code,
                          isDark: isDark,
                          hint: 'username',
                          prefix: '@',
                        ),
                        const SizedBox(height: 12),
                        _buildStyledTextField(
                          controller: _twitterController,
                          label: 'Twitter/X',
                          icon: Icons.alternate_email,
                          isDark: isDark,
                          hint: 'username',
                          prefix: '@',
                        ),
                        const SizedBox(height: 12),
                        _buildStyledTextField(
                          controller: _leetcodeController,
                          label: 'LeetCode',
                          icon: Icons.data_usage,
                          isDark: isDark,
                          hint: 'username',
                        ),
                        const SizedBox(height: 12),
                        _buildStyledTextField(
                          controller: _linkedinController,
                          label: 'LinkedIn',
                          icon: Icons.work,
                          isDark: isDark,
                          hint: 'username',
                          prefix: 'in/',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Skills Section - LeetCode Style
                  _buildSectionCard(
                    isDark: isDark,
                    icon: Icons.star,
                    title: 'Skills & Expertise',
                    subtitle: 'Select your technical skills',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableSkills.map((skill) {
                            final selected = _skills.contains(skill);
                            return FilterChip(
                              selected: selected,
                              label: Text(skill),
                              onSelected: (value) {
                                setState(() {
                                  if (value) {
                                    _skills = [..._skills, skill];
                                  } else {
                                    _skills = _skills.where((item) => item != skill).toList();
                                  }
                                });
                              },
                              selectedColor: const Color(0xFF4F46E5).withAlpha(30),
                              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                              checkmarkColor: const Color(0xFF4F46E5),
                              side: BorderSide(
                                color: selected
                                    ? const Color(0xFF4F46E5)
                                    : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            );
                          }).toList(),
                        ),
                        if (_skills.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${_skills.length} skills selected',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    setState(() => _skills = []);
                                  },
                                  child: const Text('Clear all'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Preferences Section - Facebook Style
                  _buildSectionCard(
                    isDark: isDark,
                    icon: Icons.settings,
                    title: 'Preferences',
                    child: Column(
                      children: [
                        _buildStyledSwitch(
                          isDark: isDark,
                          title: 'Email Notifications',
                          subtitle: 'Receive updates and activity alerts',
                          value: _emailNotifications,
                          onChanged: (value) => setState(() => _emailNotifications = value),
                        ),
                        _buildStyledSwitch(
                          isDark: isDark,
                          title: 'Push Notifications',
                          subtitle: 'Get real-time notifications',
                          value: _pushNotifications,
                          onChanged: (value) => setState(() => _pushNotifications = value),
                        ),
                        _buildStyledSwitch(
                          isDark: isDark,
                          title: 'Public Profile',
                          subtitle: 'Make your profile visible to everyone',
                          value: _publicProfile,
                          onChanged: (value) => setState(() => _publicProfile = value),
                        ),
                        const Divider(height: 24),
                        _buildStyledDropdown(
                          isDark: isDark,
                          value: _theme,
                          label: 'Theme Preference',
                          icon: Icons.palette,
                          items: const [
                            DropdownMenuItem(value: 'system', child: Text('🌓 System Default')),
                            DropdownMenuItem(value: 'light', child: Text('☀️ Light')),
                            DropdownMenuItem(value: 'dark', child: Text('🌙 Dark')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _theme = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Theme Colors Section - Live preview and selection
                  _buildSectionCard(
                    isDark: isDark,
                    icon: Icons.color_lens_outlined,
                    title: 'Theme Colors',
                    subtitle: 'Pick a primary accent and background',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Primary color', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          children: [
                            ...[0xFF4F46E5, 0xFF06B6D4, 0xFF10B981, 0xFFF97316, 0xFFEF4444, 0xFF8B5CF6].map((hex) {
                              final c = Color(hex);
                              final selected = (ref.read(themeNotifierProvider).primary.value == c.value);
                              return GestureDetector(
                                onTap: () {
                                  ref.read(themeNotifierProvider).updatePrimary(c);
                                  setState(() => _selectedPrimaryColor = c);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  width: selected ? 48 : 40,
                                  height: selected ? 48 : 40,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      if (selected) BoxShadow(color: c.withOpacity(0.32), blurRadius: 12, offset: const Offset(0,6)),
                                    ],
                                    border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                                  ),
                                ),
                              );
                            }).toList(),
                            GestureDetector(
                              onTap: () async {
                                final hex = await showDialog<String?>(
                                  context: context,
                                  builder: (context) {
                                    final controller = TextEditingController();
                                    return AlertDialog(
                                      title: const Text('Enter hex color'),
                                      content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(hintText: 'e.g. FF0066 or #FF0066'),
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                                          child: const Text('Apply'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (hex != null && hex.isNotEmpty) {
                                  String h = hex.replaceAll('#', '');
                                  if (h.length == 6) h = 'FF$h';
                                  try {
                                    final c = Color(int.parse(h, radix: 16));
                                    ref.read(themeNotifierProvider).updatePrimary(c);
                                    setState(() => _selectedPrimaryColor = c);
                                  } catch (_) {}
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Center(child: Icon(Icons.add, size: 20)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Background color', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          children: [
                            ...[0xFFF8FAFC, 0xFFFFFFFF, 0xFFF5F7FA, 0xFF0A0A0A].map((hex) {
                              final c = Color(hex);
                              final selected = (ref.read(themeNotifierProvider).background.value == c.value);
                              return GestureDetector(
                                onTap: () {
                                  ref.read(themeNotifierProvider).updateBackground(c);
                                  setState(() => _selectedBackgroundColor = c);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  width: selected ? 56 : 48,
                                  height: selected ? 36 : 32,
                                  decoration: BoxDecoration(
                                    color: c,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Reset to defaults
                                ref.read(themeNotifierProvider).updateFromMap({
                                  'primary': const Color(0xFF4F46E5),
                                  'background': const Color(0xFFF8FAFC),
                                });
                                setState(() {
                                  _selectedPrimaryColor = null;
                                  _selectedBackgroundColor = null;
                                });
                              },
                              child: const Text('Reset'),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Primary color updated (session only).')));
                              },
                              child: const Text('Save to profile later'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Account Management Section - Facebook Style
                  _buildSectionCard(
                    isDark: isDark,
                    icon: Icons.shield,
                    title: 'Account Management',
                    child: Column(
                      children: [
                        _buildStyledButton(
                          isDark: isDark,
                          icon: Icons.logout,
                          label: 'Log Out',
                          color: Colors.orange,
                          onPressed: _saving
                              ? null
                              : () async {
                                  await showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        title: const Text('Log Out'),
                                        content: const Text('Are you sure you want to log out?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              await ref.read(authProvider.notifier).logout();
                                              if (context.mounted) context.go('/auth');
                                            },
                                            child: const Text('Log Out'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                        ),
                        const SizedBox(height: 12),
                        _buildStyledButton(
                          isDark: isDark,
                          icon: Icons.delete_forever,
                          label: 'Delete Account',
                          color: Colors.red,
                          isDestructive: true,
                          onPressed: _saving ? null : _confirmDeleteAccount,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  // Custom Widget Builders
  Widget _buildSectionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF4F46E5),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    String? hint,
    String? prefix,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        prefixStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF4F46E5),
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildStyledSwitch({
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4F46E5),
            activeTrackColor: const Color(0xFF4F46E5).withAlpha(77),
          ),
        ],
      ),
    );
  }

  // FIX 3: Fixed generic type T to be explicit
  Widget _buildStyledDropdown({
    required bool isDark,
    required String value, // Changed from T to String
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items, // Changed from List<DropdownMenuItem<T>> to List<DropdownMenuItem<String>>
    required ValueChanged<String?> onChanged, // Changed from ValueChanged<T?> to ValueChanged<String?>
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>( // Changed from DropdownButtonFormField<T> to DropdownButtonFormField<String>
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF4F46E5)),
          border: InputBorder.none,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        dropdownColor: isDark ? Colors.grey[900] : Colors.white,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStyledButton({
    required bool isDark,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: isDestructive
                ? color.withAlpha(77)
                : color.withAlpha(77),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: isDestructive
              ? color.withAlpha(13)
              : Colors.transparent,
        ),
      ),
    );
  }
}