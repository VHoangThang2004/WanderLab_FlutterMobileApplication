import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (context.mounted) {
      // Remove all routes and push LoginScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showEditProfileDialog(BuildContext context, String currentName) {
    final nameController = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Họ và Tên',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final success = await authProvider.updateProfile(newName);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Cập nhật thành công!' : authProvider.errorMessage)),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu hiện tại',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentPass = currentPasswordController.text;
              final newPass = newPasswordController.text;
              final confirmPass = confirmPasswordController.text;
              
              if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin')));
                return;
              }
              if (newPass != confirmPass) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu mới không khớp')));
                return;
              }
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.changePassword(currentPass, newPass);
              
              if (ctx.mounted) {
                if (success) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đổi mật khẩu thành công!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authProvider.errorMessage)),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Avatar & Name
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                          child: user.avatarUrl == null
                              ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Settings Group
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingItem(
                          context,
                          icon: Icons.person_outline,
                          title: 'Chỉnh sửa thông tin',
                          onTap: () => _showEditProfileDialog(context, user.fullName),
                        ),
                        const Divider(height: 1),
                        _buildSettingItem(
                          context,
                          icon: Icons.lock_outline,
                          title: 'Đổi mật khẩu',
                          onTap: () => _showChangePasswordDialog(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildSettingItem(
                      context,
                      icon: Icons.logout,
                      title: 'Đăng xuất',
                      textColor: Colors.red,
                      iconColor: Colors.red,
                      hideArrow: true,
                      onTap: () => _handleLogout(context),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    bool hideArrow = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: hideArrow ? null : const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
