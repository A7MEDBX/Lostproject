const postRepo = require('../Repository/post.repo');
const AIService = require('../config/ai.config');
const pineconeIndex = require('../config/pinecone.config');

class MatchingService {

    /**
     * Calculate distance between two coordinates using Haversine formula
     * @returns {number} Distance in kilometers
     */
    calculateDistance(lat1, lon1, lat2, lon2) {
        const R = 6371; // Earth radius in km
        const dLat = this.toRad(lat2 - lat1);
        const dLon = this.toRad(lon2 - lon1);
        
        const a = 
            Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);
        
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    toRad(degrees) {
        return degrees * (Math.PI / 180);
    }

    async checkMatch(imageUrl, type, category, country, state, city, latitude, longitude) {
        try {
            // ==========================================
            // VALIDATION
            // ==========================================
            if (!imageUrl || !type) {
                return {
                    success: false,
                    message: 'Image URL and Post Type are required for matching'
                };
            }

            if (!country) {
                return {
                    success: false,
                    message: 'Country is required for location-based matching'
                };
            }

            if (!city) {
                return {
                    success: false,
                    message: 'City is required for location-based matching'
                };
            }

            const oppositeType = type === 'lost' ? 'found' : 'lost';

            // ==========================================
            // STEP 1: Fetch Candidate Posts (Single Query - No Wasted Count)
            // ==========================================
            console.log('Step 1: Fetching candidate posts in location...');
            
            const MAX_DISTANCE_KM = 40;
            
            const candidatePosts = await postRepo.getFilteredPosts({
                type: oppositeType,
                status: 'active',
                country: country,
                state: state,
                city: city,
                category: category,
                limit: 500,
                offset: 0
            });

            let nearbyPosts = candidatePosts.rows;

            // Early exit if no candidates found
            if (candidatePosts.count === 0) {
                console.log(`No ${oppositeType} posts in ${city || state || country}. Skipping embedding.`);
                return {
                    success: true,
                    message: `No ${oppositeType} items found in ${city || state || country}`,
                    data: [],
                    count: 0
                };
            }

            console.log(`Found ${candidatePosts.count} ${oppositeType} posts in location`);

            // Apply distance filter if coordinates provided
            if (latitude && longitude) {
                nearbyPosts = candidatePosts.rows.filter(post => {
                    if (!post.latitude || !post.longitude) return false;
                    
                    const distance = this.calculateDistance(
                        latitude,
                        longitude,
                        post.latitude,
                        post.longitude
                    );
                    
                    post.dataValues.distance_km = Math.round(distance * 10) / 10;
                    return distance <= MAX_DISTANCE_KM;
                });

                console.log(`${nearbyPosts.length} posts within ${MAX_DISTANCE_KM}km`);

                if (nearbyPosts.length === 0) {
                    return {
                        success: true,
                        message: `No items found within ${MAX_DISTANCE_KM}km radius`,
                        data: [],
                        count: 0
                    };
                }
            }

            // ==========================================
            // STEP 2: Generate Embedding (Only if candidates exist!)
            // ==========================================
            console.log('Step 2: Generating image embedding...');
            const imagevector = await AIService.generateEmbedding(imageUrl);

            // ==========================================
            // STEP 3: Vector Similarity Search (Focused on nearby posts)
            // ==========================================
            const candidateIds = nearbyPosts.map(p => p.id);
            
            console.log(`Step 3: Searching ${candidateIds.length} vectors in Pinecone...`);

            // Build Pinecone filter
            const pineconeFilter = {
                post_type: oppositeType,
                status: 'active',
                country: country
            };

            if (state) pineconeFilter.state = state;
            if (city) pineconeFilter.city = city;
            if (category) pineconeFilter.category = category;

            console.log('Pinecone filter:', pineconeFilter);

            const matchResults = await pineconeIndex.query({
                vector: imagevector,
                topK: Math.min(nearbyPosts.length, 20),
                includeMetadata: true,
                filter: pineconeFilter
            });

            if (!matchResults.matches || matchResults.matches.length === 0) {
                return {
                    success: true,
                    message: 'No visually similar items found',
                    data: [],
                    count: 0
                };
            }

            // ==========================================
            // STEP 4: Merge Results (SQL + Vector + Distance)
            // ==========================================
            const enrichedResults = matchResults.matches
                .map(match => {
                    const post = nearbyPosts.find(p => p.id === match.id);
                    if (!post) return null;

                    return {
                        ...post.toJSON(),
                        similarity_score: Math.round(match.score * 100) / 100,
                        distance_km: post.dataValues.distance_km || null
                    };
                })
                .filter(Boolean);

            // Sort: High similarity first, then close distance
            enrichedResults.sort((a, b) => {
                const scoreDiff = b.similarity_score - a.similarity_score;
                if (Math.abs(scoreDiff) > 0.05) return scoreDiff;
                return (a.distance_km || 999) - (b.distance_km || 999);
            });

            return {
                success: true,
                message: `Found ${enrichedResults.length} potential matches`,
                data: enrichedResults,
                count: enrichedResults.length,
                metadata: {
                    searched_area: city || state || country,
                    total_candidates: candidatePosts.count,
                    within_radius: nearbyPosts.length,
                    visual_matches: enrichedResults.length
                }
            };

        } catch (err) {
            console.error('Matching error:', err);
            return {
                success: false,
                message: 'Failed to process match request'
            };
        }
    }
}

module.exports = new MatchingService();
