"""
Script to download post images and add them to Android emulator gallery
"""
import requests
import os
import subprocess
from pathlib import Path
import shutil

# Find ADB in common locations
def find_adb():
    # Check common locations
    possible_paths = [
        'adb',  # In PATH
        r'C:\Users\pc\AppData\Local\Android\Sdk\platform-tools\adb.exe',
        r'C:\Android\sdk\platform-tools\adb.exe',
        os.path.expanduser(r'~\AppData\Local\Android\Sdk\platform-tools\adb.exe'),
    ]
    
    for path in possible_paths:
        if shutil.which(path) or (os.path.isfile(path) if '\\' in path else False):
            return path
    
    return None

ADB_PATH = find_adb()
if not ADB_PATH:
    print("❌ ADB not found. Please install Android SDK platform-tools")
    print("   Or add adb to your PATH")
    exit(1)

print(f"✅ Using ADB: {ADB_PATH}\n")

# Image URLs from posts
IMAGE_URLS = [
    'https://images.unsplash.com/photo-1627123424574-724758594e93?w=500',  # Pink wallet
    'https://images.unsplash.com/photo-1519897831810-a9a01aceccd1?w=500',  # Teddy bear
    'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=500',  # Leather bag
    'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500',    # Blue backpack
    'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=500',  # iPhone red
]

# Create temp directory for downloads
TEMP_DIR = Path('temp_gallery_images')
TEMP_DIR.mkdir(exist_ok=True)

print("📥 Downloading post images...")

# Download all images
image_files = []
for idx, url in enumerate(IMAGE_URLS, 1):
    try:
        print(f"  Downloading image {idx}/{len(IMAGE_URLS)}...")
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        # Save image
        filename = f'post_image_{idx}.jpg'
        filepath = TEMP_DIR / filename
        
        with open(filepath, 'wb') as f:
            f.write(response.content)
        
        image_files.append(filepath)
        print(f"  ✅ Saved: {filename}")
        
    except Exception as e:
        print(f"  ❌ Failed to download image {idx}: {e}")

print(f"\n✅ Downloaded {len(image_files)} images")

# Push images to emulator using ADB
print("\n📱 Pushing images to Android emulator gallery...")

EMULATOR_PATH = '/sdcard/Pictures/FinderApp/'

for filepath in image_files:
    try:
        # Create directory on emulator
        subprocess.run(
            [ADB_PATH, 'shell', 'mkdir', '-p', EMULATOR_PATH],
            check=False,
            capture_output=True
        )
        
        # Push image to emulator
        result = subprocess.run(
            [ADB_PATH, 'push', str(filepath), EMULATOR_PATH],
            check=True,
            capture_output=True,
            text=True
        )
        
        print(f"  ✅ Pushed: {filepath.name}")
        
    except subprocess.CalledProcessError as e:
        print(f"  ❌ Failed to push {filepath.name}: {e}")
        print(f"     Error: {e.stderr}")

# Refresh media scanner so images appear in gallery
print("\n🔄 Refreshing emulator gallery...")
try:
    subprocess.run(
        [ADB_PATH, 'shell', 'am', 'broadcast', '-a', 
         'android.intent.action.MEDIA_SCANNER_SCAN_FILE', '-d',
         f'file://{EMULATOR_PATH}'],
        check=False,
        capture_output=True
    )
    
    # Alternative: scan entire directory
    subprocess.run(
        [ADB_PATH, 'shell', 'am', 'broadcast', '-a',
         'android.intent.action.MEDIA_MOUNTED', '-d',
         f'file://{EMULATOR_PATH}'],
        check=False,
        capture_output=True
    )
    
    print("✅ Gallery refreshed")
    
except Exception as e:
    print(f"⚠️  Gallery refresh failed: {e}")
    print("   You may need to restart the emulator or manually refresh the gallery")

print("\n✅ Done! Images should now appear in the emulator's gallery/photos app")
print(f"   Location: {EMULATOR_PATH}")
print("\n💡 If images don't appear:")
print("   1. Open the Photos/Gallery app on the emulator")
print("   2. Pull down to refresh")
print("   3. Or restart the emulator")
