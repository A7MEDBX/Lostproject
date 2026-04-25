import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../widgets/post_card.dart';
import '../../domain/entities/post.dart';
import '../../core/constants/api_endpoints.dart';
import 'filter_screen.dart';

/// Home Screen - Suggested Posts
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Post> _posts = [];

  // Fallback mock data (shown when backend is unavailable)
  final List<Post> _mockPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http
          .get(Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getPosts}'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> postsJson = data['posts'] ?? [];

        if (postsJson.isEmpty) {
          // Backend is working but no posts - show mock data
          setState(() {
            _posts = _mockPosts;
            _isLoading = false;
          });
          return;
        }

        // Parse backend posts
        final List<Post> backendPosts = postsJson.map<Post>((json) {
          return Post(
            id: json['id'] ?? '',
            userId: json['user_id'] ?? 'unknown',
            title: json['title'] ?? '',
            description: json['description'] ?? '',
            category: json['category'] ?? 'Other',
            postType: json['post_type'] ?? 'lost',
            imageUrl: json['image_url'] ?? '',
            country: json['country'] ?? 'Unknown',
            state: json['state'],
            city: json['city'],
            latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
            longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
            location: json['location'],
            createdAt: json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : DateTime.now(),
            updatedAt: json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : null,
          );
        }).toList();

        setState(() {
          _posts = backendPosts;
          _isLoading = false;
        });
      } else {
        // Backend returned error - use mock data
        setState(() {
          _posts = _mockPosts;
          _isLoading = false;
        });
      }
    } on SocketException {
      // No internet/backend - use mock data
      setState(() {
        _posts = _mockPosts;
        _isLoading = false;
        _errorMessage = 'Using offline data (backend not available)';
      });
    } catch (e) {
      // Any other error - use mock data
      setState(() {
        _posts = _mockPosts;
        _isLoading = false;
        _errorMessage = 'Using offline data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const FilterScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                ),
              );
            },
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0A3D91), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.tune, color: Color(0xFF0A3D91), size: 24),
            ),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF0A3D91),
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Suggested ',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'posts !',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF0A3D91),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                'Found items matching your description',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),

            // Posts List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0A3D91),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchPosts,
                      color: const Color(0xFF0A3D91),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: PostCard(
                              post: post,
                              backgroundColor: _getCardBackgroundColor(index),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Stack(
          children: [
            // Color bar positioned in the middle
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A3D91),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
              ),
            ),
            // Icons positioned to overlap the bar
            Positioned(
              left: 0,
              right: 0,
              top: 10,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavButton(Icons.home, true, () {}),

                  _buildNavButton(Icons.chat_bubble_outline, false, () {
                    Navigator.pushNamed(context, '/messages');
                  }),
                  _buildNavButton(Icons.file_upload_outlined, false, () {
                    Navigator.pushNamed(context, '/create-post');
                  }),
                  _buildNavButton(Icons.person, false, () {
                    Navigator.pushNamed(context, '/profile');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF0A3D91)),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
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
          color: isActive ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF0A3D91) : Colors.white,
          size: 38,
        ),
      ),
    );
  }

  Color _getCardBackgroundColor(int index) {
    final colors = [
      const Color(0xFFFFD6D6), // Pink for first item
      const Color(0xFFE8E8E8), // Gray for second item
      const Color(0xFFF5E6D3), // Beige for third item
      const Color(0xFFE8E8E8), // Gray
      const Color(0xFFFFD6D6), // Pink
    ];
    return colors[index % colors.length];
  }
}
