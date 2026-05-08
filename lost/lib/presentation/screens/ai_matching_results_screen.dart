import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/constants/finder_colors.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/ai_matching_remote_data_source.dart';
import 'package:lost/core/services/auth_service.dart';

enum MatchingState { loading, results, empty }

class MatchResult {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final String distance;
  final String timeAgo;
  final int matchPercentage;
  final String finderName;
  final bool isVerified;
  final String status; // 'Lost' or 'Found'

  MatchResult({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.distance,
    required this.timeAgo,
    required this.matchPercentage,
    required this.finderName,
    this.isVerified = false,
    required this.status,
  });
}

class AIMatchingResultsScreen extends StatefulWidget {
  final Map<String, dynamic>? postData;

  const AIMatchingResultsScreen({super.key, this.postData});

  @override
  State<AIMatchingResultsScreen> createState() =>
      _AIMatchingResultsScreenState();
}

class _AIMatchingResultsScreenState extends State<AIMatchingResultsScreen>
    with SingleTickerProviderStateMixin {
  MatchingState _currentState = MatchingState.loading;
  List<MatchResult> _results = [];
  late AnimationController _pulseController;

  // Mock results for demonstration
  final List<MatchResult> _mockResults = [
    MatchResult(
      id: '1',
      userId: 'mock-user-1',
      title: 'Black Leather Wallet',
      description:
          'Found near the park bench. Has a small scratch on the front corner.',
      imageUrl:
          'https://images.unsplash.com/photo-1627123424574-724758594e93?w=400',
      location: 'Central Park, NY',
      distance: '200m away',
      timeAgo: '2 hours ago',
      matchPercentage: 98,
      finderName: 'Jane D.',
      isVerified: true,
      status: 'Found',
    ),
    MatchResult(
      id: '2',
      userId: 'mock-user-2',
      title: 'Leather Card Holder',
      description: 'Small black card holder found on subway.',
      imageUrl:
          'https://images.unsplash.com/photo-1606503825008-909a67e63c3d?w=400',
      location: 'Brooklyn, NY',
      distance: '2km away',
      timeAgo: '5 hours ago',
      matchPercentage: 84,
      finderName: 'Mike R.',
      isVerified: false,
      status: 'Found',
    ),
    MatchResult(
      id: '3',
      userId: 'mock-user-3',
      title: 'Black Pouch',
      description: 'Found keys in a black pouch.',
      imageUrl:
          'https://images.unsplash.com/photo-1594223274512-ad4803739b7c?w=400',
      location: 'Queens, NY',
      distance: '5km away',
      timeAgo: '1 day ago',
      matchPercentage: 65,
      finderName: 'Sarah K.',
      isVerified: false,
      status: 'Found',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Process real backend data or simulate
    _processResults();
  }

  bool _isCreatingPost = false;

  Future<void> _createPost() async {
    if (widget.postData == null || widget.postData!['uploadedImageUrl'] == null) return;

    setState(() => _isCreatingPost = true);

    try {
      final apiClient = ApiClient(tokenProvider: AuthService.instance.getIdToken);
      final dataSource = AIMatchingRemoteDataSource(
        client: apiClient.client,
        tokenProvider: AuthService.instance.getIdToken,
      );

      final result = await dataSource.createPostWithUrl(
        imageUrl: widget.postData!['uploadedImageUrl'],
        title: widget.postData!['title'],
        description: widget.postData!['description'],
        category: widget.postData!['category'],
        country: widget.postData!['country'],
        state: widget.postData!['state'],
        city: widget.postData!['city'],
        postType: widget.postData!['postType'],
      );

      if (mounted) {
        setState(() => _isCreatingPost = false);
        // Replace current screen with post detail
        final postData = result['data'] as Map<String, dynamic>?;
        Navigator.pushReplacementNamed(
          context,
          '/post-detail',
          arguments: {
            'postId': postData?['id'],
            'title': widget.postData!['title'],
            'description': widget.postData!['description'],
            'category': widget.postData!['category'],
            'country': widget.postData!['country'],
            'city': widget.postData!['city'],
            'postType': widget.postData!['postType'],
            'imageUrl': widget.postData!['uploadedImageUrl'],
            'status': 'active',
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreatingPost = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $e')),
        );
      }
    }
  }

  void _processResults() {
    // Simulate AI processing for 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          // Check if we have real backend data
          if (widget.postData != null && widget.postData!['matches'] != null) {
            // Use real backend matches
            final matchesData = widget.postData!['matches'] as List;
            _results = matchesData.map((match) {
              return MatchResult(
                id: match['id'] ?? '',
                userId: match['user_id'] ?? '',
                title: match['title'] ?? 'Unknown Item',
                description: match['description'] ?? '',
                imageUrl: match['image_url'] ?? '',
                location: match['location'] ?? '',
                distance: match['distance'] ?? '0km away',
                timeAgo: match['time_ago'] ?? 'Just now',
                matchPercentage: (match['match_percentage'] ?? 0).round(),
                finderName: match['finder_name'] ?? 'User',
                isVerified: match['is_verified'] ?? false,
                status: match['post_type'] ?? 'found',
              );
            }).toList();
          } else {
            // Fallback to mock data for testing
            _results = _mockResults;
          }

          _currentState = _results.isNotEmpty
              ? MatchingState.results
              : MatchingState.empty;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinderColors.background,
      body: SafeArea(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    switch (_currentState) {
      case MatchingState.loading:
        return _buildLoadingState();
      case MatchingState.results:
        return _buildResultsState();
      case MatchingState.empty:
        return _buildEmptyState();
    }
  }

  // ==================== LOADING STATE ====================
  Widget _buildLoadingState() {
    return Column(
      children: [
        // Blue Curved Top Bar
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF0A3D91),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 30,
            left: 16,
            right: 16,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Processing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
        ),

        // Loading Content
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Robot Image in Cyan Circle with animation
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.1),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BCD4),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00BCD4).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: _pulseController.value * 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(10),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/robot_ai.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Searching for matches...',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Our AI is currently analyzing colors, shapes, and unique features to find potential matches in our database.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Cancel Button
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A3D91),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== RESULTS STATE ====================
  Widget _buildResultsState() {
    return Column(
      children: [
        // Blue Curved Top Bar
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF0A3D91),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 30,
            left: 16,
            right: 16,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Processing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        // Results Content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // Robot Image
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00BCD4).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/robot_ai.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Matches Found Title
                Center(
                  child: Text(
                    '${_results.length} Matches Found',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Based on visual similarity and location.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Results List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    // High match (first card) gets expanded view
                    if (index == 0 && result.matchPercentage >= 90) {
                      return _buildHighMatchCard(result);
                    } else if (result.matchPercentage >= 70) {
                      return _buildMediumMatchCard(result);
                    } else {
                      return _buildLowMatchCard(result);
                    }
                  },
                ),
                const SizedBox(height: 30),
                
                // Create Post Action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Text(
                        'None of these look like your item?',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isCreatingPost ? null : _createPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A3D91),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isCreatingPost
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Create Post Anyway',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighMatchCard(MatchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0A3D91)),
      ),
      child: Column(
        children: [
          // Image with badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: FinderColors.lightBrown,
                  child: Image.network(
                    result.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image,
                      size: 60,
                      color: Color(0xFF9dabb9),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A3D91),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${result.matchPercentage}% Match',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        result.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: const TextStyle(
                    color: FinderColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.description,
                  style: const TextStyle(
                    color: FinderColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Info section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: FinderColors.lightBrown,
                        width: 0.5,
                      ),
                      bottom: BorderSide(
                        color: FinderColors.lightBrown,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.location_on,
                        '${result.location} (${result.distance})',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.schedule, 'Posted ${result.timeAgo}'),
                      if (result.isVerified) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 18,
                              color: FinderColors.primaryBrown,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Verified Finder (${result.finderName})',
                              style: const TextStyle(
                                color: FinderColors.primaryBrown,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _navigateToPostDetail(result),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: FinderColors.lightBrown),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            color: FinderColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/chat');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FinderColors.primaryBrown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Start Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediumMatchCard(MatchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0A3D91)),
      ),
      child: Column(
        children: [
          // Image with badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: FinderColors.lightBrown,
                  child: Image.network(
                    result.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image,
                      size: 60,
                      color: Color(0xFF9dabb9),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A3D91).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${result.matchPercentage}% Match',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        result.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: const TextStyle(
                    color: FinderColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.description,
                  style: const TextStyle(
                    color: FinderColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Quick info
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: FinderColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.location,
                      style: const TextStyle(
                        color: FinderColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: Color(0xFF9dabb9),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.timeAgo,
                      style: const TextStyle(
                        color: Color(0xFF9dabb9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _navigateToPostDetail(result),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0A3D91)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            color: FinderColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A3D91),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowMatchCard(MatchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0A3D91)),
      ),
      child: Row(
        children: [
          // Small image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 96,
              height: 96,
              color: FinderColors.lightBrown,
              child: Image.network(
                result.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, size: 40, color: Color(0xFF9dabb9)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        result.title,
                        style: const TextStyle(
                          color: FinderColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A3D91).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${result.matchPercentage}%',
                        style: const TextStyle(
                          color: FinderColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  result.description,
                  style: const TextStyle(
                    color: FinderColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: FinderColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.location,
                      style: const TextStyle(
                        color: FinderColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      ' • ',
                      style: TextStyle(color: FinderColors.textSecondary),
                    ),
                    Text(
                      result.timeAgo,
                      style: const TextStyle(
                        color: FinderColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToPostDetail(result),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A3D91),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: FinderColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: FinderColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Column(
      children: [
        // Blue Curved Top Bar
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF0A3D91),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 30,
            left: 16,
            right: 16,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Processing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
        ),

        // Empty Content
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Robot Image in Cyan Circle
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00BCD4).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/robot_ai.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  const Text(
                    'No matches found',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "We didn't find any items that match your image right now.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Checkbox with notification text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A3D91),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Ready to create your post?',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Since no matches were found, you can now publish your post. We will notify you immediately if a match is found later.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Create Post button
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isCreatingPost ? null : _createPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A3D91),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isCreatingPost
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Create Post',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToPostDetail(MatchResult result) {
    Navigator.pushNamed(
      context,
      '/post-detail',
      arguments: {
        'postId': result.id,
        'userId': result.userId,
        'title': result.title,
        'category': 'Unknown',
        'timeAgo': result.timeAgo,
        'posterName': result.finderName,
        'isVerified': result.isVerified,
        'description': result.description,
        'location': result.location,
        'distance': result.distance,
        'imageUrl': result.imageUrl,
        'status': result.status,
        'matchPercentage': result.matchPercentage,
      },
    );
  }

  // ==================== SHARED WIDGETS ====================
  Widget _buildHeader(String title, {bool showFilter = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: FinderColors.primaryBrown,
        border: const Border(
          bottom: BorderSide(color: FinderColors.darkBrown, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: FinderColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          showFilter
              ? IconButton(
                  icon: const Icon(
                    Icons.filter_list,
                    color: FinderColors.textSecondary,
                  ),
                  onPressed: () {
                    // Show filter options
                  },
                )
              : const SizedBox(width: 48),
        ],
      ),
    );
  }
}
