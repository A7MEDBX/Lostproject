const multer = require('multer');
const path = require('path');
const fs = require('fs');
const cloudinary = require('../config/cloudinary.config');

// 1. Configure Multer (Temporary Local Storage)
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadPath = path.join(__dirname, '../uploads/');
        // Ensure directory exists
        if (!fs.existsSync(uploadPath)){
            fs.mkdirSync(uploadPath, { recursive: true });
        }
        cb(null, uploadPath);
    },
    filename: (req, file, cb) => {
        // Create unique filename: fieldname-timestamp.ext
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

// File filter (Only images)
const fileFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('Only image files are allowed!'), false);
    }
};

const upload = multer({ 
    storage: storage,
    fileFilter: fileFilter,
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

// 2. Middleware to Upload to Cloudinary
const uploadToCloudinary = async (req, res, next) => {
    try {
        // If no file uploaded, skip (or error if strictly required)
        if (!req.file) {
            return next(); 
        }

        console.log(`Uploading file to Cloudinary: ${req.file.path}`);

        // Upload to Cloudinary
        const result = await cloudinary.uploader.upload(req.file.path, {
            folder: 'finder_app_posts', // Folder in Cloudinary
            use_filename: true
        });

        // Add the returned URL to req.body.image_url
        // This makes it compatible with your existing Controller & AI Service!
        req.body.image_url = result.secure_url;

        console.log(`Cloudinary Upload Success: ${result.secure_url}`);

        // 3. Cleanup: Delete local temp file
        fs.unlink(req.file.path, (err) => {
            if (err) console.error("Failed to delete local file:", err);
        });

        next();

    } catch (error) {
        console.error("Cloudinary Upload Failed:", error);
        
        // Attempt to clean up local file even on error
        if (req.file) {
            fs.unlink(req.file.path, () => {}); 
        }
        
        return res.status(500).json({ 
            error: "Image upload failed", 
            details: error.message 
        });
    }
};

// Export both: The Multer handler AND the Cloudinary uploader
module.exports = {
    uploadMiddleware: upload.single('image'), // Expects form-data key: "image"
    uploadToCloudinary
};