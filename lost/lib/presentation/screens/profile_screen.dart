import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/app_messenger.dart';
import '../providers/user_provider.dart';

/// Profile Screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = AuthService.instance.currentUser;
    final backendUser = context.watch<UserProvider>().backendUser;

    // Prefer backend name; fall back to Firebase displayName.
    final displayName =
        backendUser?.name ?? firebaseUser?.displayName ?? 'Unknown User';
    final email = backendUser?.email ?? firebaseUser?.email ?? '';
    final trustScore = backendUser?.trustScore;
    final verificationStatus = backendUser?.verificationStatus;

    return Scaffold(
      backgroundColor: Colors.white,
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Profile Avatar with Edit Button
              Stack(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0A3D91).withOpacity(0.2),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF0A3D91),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A3D91),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // User Name
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // Email
              Text(
                email,
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),

              // Trust score + verification status badges
              if (trustScore != null || verificationStatus != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    if (trustScore != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A3D91).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFF0A3D91),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Trust ${trustScore.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0A3D91),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (verificationStatus != null)
                      _buildVerificationChip(verificationStatus),
                  ],
                ),
              ],

              const SizedBox(height: 40),

              // Account Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    // My Posts
                    _buildMenuItem(
                      icon: Icons.grid_view,
                      iconColor: const Color(0xFF0A3D91),
                      title: 'My Posts',
                      onTap: () {
                        Navigator.pushNamed(context, '/my-posts');
                      },
                    ),

                    const SizedBox(height: 12),

                    // Edit Profile removed from here

                    // Verify Account (KYC)
                    if (verificationStatus != 'approved') ...[
                      _buildMenuItem(
                        icon: Icons.verified_user_outlined,
                        iconColor: const Color(0xFF0A3D91),
                        title: verificationStatus == 'pending' ? 'Verification Pending' : 'Verify Account',
                        onTap: () async {
                          if (verificationStatus == 'pending') {
                            AppMessenger.showInfo('Your verification request is still pending review.');
                            return;
                          }
                          await Navigator.pushNamed(
                            context,
                            '/privacy-policy',
                            arguments: {'isFromOnboarding': true},
                          );
                          if (context.mounted) {
                            await context.read<UserProvider>().loadUser();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Settings
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      iconColor: const Color(0xFF0A3D91),
                      title: 'Settings',
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),

                    const SizedBox(height: 12),

                    // Support
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      iconColor: const Color(0xFF0A3D91),
                      title: 'Support',
                      onTap: () {
                        Navigator.pushNamed(context, '/support');
                      },
                    ),

                    const SizedBox(height: 12),

                    // Report a Problem
                    _buildMenuItem(
                      icon: Icons.report_problem_outlined,
                      iconColor: const Color(0xFF0A3D91),
                      title: 'Report a problem',
                      onTap: () {
                        Navigator.pushNamed(context, '/report-problem');
                      },
                    ),

                    const SizedBox(height: 12),

                    // Privacy Policy
                    _buildMenuItem(
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF0A3D91),
                      title: 'Privacy Policy',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/privacy-policy',
                          arguments: {'isFromOnboarding': false},
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Log Out Button
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          // Clear session
                          await SessionService.instance.clearSession();
                          // Clear backend user state
                          context.read<UserProvider>().clear();
                          // Sign out from Firebase
                          await AuthService.instance.signOut();
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 20,
                        ),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Stack(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A3D91),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton(Icons.home, false, () {
                  Navigator.pushReplacementNamed(context, '/home');
                }),
                _buildNavButton(Icons.chat_bubble_outline_sharp, false, () {
                  Navigator.pushNamed(context, '/messages');
                }),
                _buildNavButton(Icons.file_upload_outlined, false, () {
                  Navigator.pushNamed(context, '/create-post');
                }),
                _buildNavButton(Icons.person, true, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationChip(String status) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (status) {
      case 'approved':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        icon = Icons.verified;
        label = 'Verified';
        break;
      case 'pending':
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade800;
        icon = Icons.hourglass_top;
        label = 'Pending';
        break;
      case 'rejected':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        icon = Icons.cancel_outlined;
        label = 'Rejected';
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade600;
        icon = Icons.shield_outlined;
        label = 'Unverified';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0A3D91) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey[600],
          size: 38,
        ),
      ),
    );
  }
}
