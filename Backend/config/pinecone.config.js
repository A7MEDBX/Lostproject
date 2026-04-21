const { Pinecone } = require('@pinecone-database/pinecone');

// Initialize the client
const pc = new Pinecone({
    // Using the key from your .env file
    apiKey: process.env.PINECONE_API_KEY 
});

// Connect to your specific Index (name matches your screenshot)
const index = pc.index('finder-app');

module.exports = index;