import 'package:flutter/material.dart';
import '../../core/constants/finder_colors.dart';

/// Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: FinderColors.primaryBlue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BONUS: View Profile Preview Card
                _buildProfilePreviewCard(),

                const SizedBox(height: 32),

                // ACCOUNT Section
                Text(
                  'ACCOUNT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Edit Profile
                _buildMenuItem(
                  icon: Icons.person_outline,
                  iconColor: FinderColors.primaryBlue,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () {
                    Navigator.pushNamed(context, '/edit-profile');
                  },
                  trailingWidget: ClipOval(
                    child: Image.asset(
                      'assets/images/avatar_placeholder.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 32,
                          height: 32,
                          color: FinderColors.primaryBlue.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            size: 20,
                            color: FinderColors.primaryBlue,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // My Posts
                _buildMenuItem(
                  icon: Icons.grid_view_outlined,
                  iconColor: FinderColors.primaryBlue,
                  title: 'My Posts',
                  subtitle: 'Manage your listings',
                  onTap: () {
                    Navigator.pushNamed(context, '/my-posts');
                  },
                ),

                const SizedBox(height: 16),

                // Verify Account
                _buildMenuItem(
                  icon: Icons.verified_user_outlined,
                  iconColor: FinderColors.primaryBlue,
                  title: 'Verify Account',
                  subtitle: 'Complete KYC verification',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/privacy-policy',
                      arguments: {'isFromOnboarding': true},
                    );
                  },
                ),

                const SizedBox(height: 32),

                // PRIVACY Section
                Text(
                  'PRIVACY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Change Password
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  iconColor: FinderColors.primaryBlue,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: () {
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),

                const SizedBox(height: 16),

                // Privacy Policy
                _buildMenuItem(
                  icon: Icons.shield_outlined,
                  iconColor: FinderColors.primaryBlue,
                  title: 'Privacy Policy',
                  subtitle: 'Read our data policy and terms',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/privacy-policy',
                      arguments: {'isFromOnboarding': false},
                    );
                  },
                ),

                const SizedBox(height: 32),

                // NOTIFICATIONS Section
                Text(
                  'NOTIFICATIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Notifications Toggle
                _buildNotificationToggle(),

                const SizedBox(height: 32),

                // PREFERENCES Section
                Text(
                  'PREFERENCES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Language
                _buildMenuItem(
                  icon: Icons.language,
                  iconColor: FinderColors.primaryBlue,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () {
                    // TODO: Language selection
                  },
                ),

                const SizedBox(height: 16),

                // Support
                _buildMenuItem(
                  icon: Icons.help_outline,
                  iconColor: FinderColors.primaryBlue,
                  title: 'Support & Help',
                  subtitle: 'Get assistance and view FAQs',
                  onTap: () {
                    Navigator.pushNamed(context, '/support');
                  },
                ),

                const SizedBox(height: 16),

                // About
                _buildMenuItem(
                  icon: Icons.info_outline,
                  iconColor: FinderColors.primaryBlue,
                  title: 'About',
                  subtitle: 'App version 1.0.0',
                  onTap: () {
                    // TODO: Show about page
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePreviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FinderColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: FinderColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/avatar_placeholder.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    size: 35,
                    color: FinderColors.primaryBlue,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Joly Marwan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Joly151@gmail.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailingWidget,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FinderColors.primaryBlue, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: FinderColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (trailingWidget != null) ...[
              trailingWidget,
              const SizedBox(width: 12),
            ],
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FinderColors.primaryBlue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: FinderColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: FinderColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Push Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: FinderColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notificationsEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
            activeThumbColor: FinderColors.primaryBlue,
            activeTrackColor: FinderColors.primaryBlue.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
