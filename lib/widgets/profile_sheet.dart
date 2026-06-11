import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../core/colors.dart';

class ProfileSheet extends StatefulWidget {
  final String uid;
  const ProfileSheet({super.key, required this.uid});

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _cropController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _cropController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      if (doc.exists && doc.data() != null) {
        _user = UserModel.fromMap(doc.data()!);
        _nameController.text = _user!.name;
        _locationController.text = _user!.location;
        _cropController.text = _user!.crop;
      }
    } catch (e) {
      // Ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updates = <String, dynamic>{
        'name': name,
        'location': _locationController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (_user?.role == 'farmer') {
        updates['crop'] = _cropController.text.trim();
      }

      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update(updates);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.primary),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      if (mounted) {
        // Sign out resets cache and navigates to auth via router.
        context.go('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final surfaceTintB = isDark ? AppColors.darkSurfaceTintB : AppColors.lightSurfaceTintB;
    final danger = isDark ? AppColors.darkDanger : AppColors.lightDanger;
    final inputFill = isDark ? Colors.grey.shade900 : Colors.grey.shade100;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: _isLoading
              ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
              : _user == null
                  ? const Center(child: Text('Failed to load profile.'))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: surfaceTintB.withValues(alpha: 0.2),
                              child: Text(
                                _user != null && _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ink)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(_user!.role.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        TextField(
                          controller: _nameController,
                          style: TextStyle(color: ink),
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextField(
                          controller: _locationController,
                          style: TextStyle(color: ink),
                          decoration: InputDecoration(
                            labelText: 'Location',
                            labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_user!.role == 'farmer') ...[
                          TextField(
                            controller: _cropController,
                            style: TextStyle(color: ink),
                            decoration: InputDecoration(
                              labelText: 'Crop',
                              labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
                              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Mobile is read-only because it is the login identity (mapped to the Auth email).
                        TextField(
                          controller: TextEditingController(text: _user!.mobile),
                          readOnly: true,
                          style: TextStyle(color: ink.withValues(alpha: 0.7)),
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
                            prefixIcon: Icon(Icons.lock, size: 16, color: ink.withValues(alpha: 0.4)),
                            filled: true,
                            fillColor: inputFill,
                            border: UnderlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSaving
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                        
                        TextButton.icon(
                          onPressed: _handleLogout,
                          icon: Icon(Icons.logout, color: danger),
                          label: Text('Log Out', style: TextStyle(color: danger, fontSize: 16, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: danger.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _cropController.dispose();
    super.dispose();
  }
}
