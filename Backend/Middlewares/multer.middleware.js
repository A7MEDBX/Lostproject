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

// File filter (Images and common mobile fallback)
const fileFilter = (req, file, cb) => {
    const isImageMime = file.mimetype.startsWith('image/');
    const isOctetStream = file.mimetype === 'application/octet-stream';
    const ext = path.extname(file.originalname).toLowerCase();
    const isImageExt = ['.jpg', '.jpeg', '.png', '.webp', '.heic'].includes(ext);

    if (isImageMime || (isOctetStream && isImageExt)) {
        cb(null, true);
    } else {
        cb(new Error(`Only image files are allowed! Received mimetype: ${file.mimetype}, ext: ${ext}`), false);
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

// Middleware to Upload KYC to Cloudinary
const uploadVerificationToCloudinary = async (req, res, next) => {
    try {
        if (!req.files || !req.files.id_image) {
            return next(); 
        }

        const idFile = req.files.id_image[0];
        console.log(`Uploading ID file to Cloudinary: ${idFile.path}`);

        // Upload to Cloudinary
        const result = await cloudinary.uploader.upload(idFile.path, {
            folder: 'finder_app_kyc',
            use_filename: true
        });

        // The validator expects id_image_url and phone_number
        req.body.id_image_url = result.secure_url;
        
        // Map frontend "phone" to backend "phone_number"
        if (req.body.phone && !req.body.phone_number) {
            req.body.phone_number = req.body.phone;
        }

        console.log(`Cloudinary Upload Success: ${result.secure_url}`);

        // Cleanup: Delete local temp files
        fs.unlink(idFile.path, () => {});
        if (req.files.selfie_image) {
            fs.unlink(req.files.selfie_image[0].path, () => {});
        }

        next();

    } catch (error) {
        console.error("Cloudinary KYC Upload Failed:", error);
        return res.status(500).json({ 
            error: "Image upload failed", 
            details: error.message 
        });
    }
};

// Export both: The Multer handler AND the Cloudinary uploader
module.exports = {
    uploadMiddleware: upload.single('image'), // Expects form-data key: "image"
    uploadKycMiddleware: upload.fields([{ name: 'id_image', maxCount: 1 }, { name: 'selfie_image', maxCount: 1 }]),
    uploadToCloudinary,
    uploadVerificationToCloudinary
};