#!/usr/bin/env python3
"""
Prepare app icons for Nextcloud - Dark and Light mode versions
Created: 2025-10-20
"""

from PIL import Image, ImageOps, ImageDraw
import sys
import os

def create_app_icons(input_path, output_dir):
    """
    Create both dark and light mode versions of the app icon
    
    - app.png: Dark icon on transparent background (for light mode)
    - app-dark.png: Light icon on transparent background (for dark mode)
    """
    
    print("🎨 Processing app icon for Nextcloud...")
    print(f"   Input: {input_path}")
    print(f"   Output: {output_dir}")
    print()
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Load the original image
    try:
        img = Image.open(input_path).convert("RGBA")
        print(f"✅ Loaded image: {img.size[0]}x{img.size[1]} px")
    except Exception as e:
        print(f"❌ Error loading image: {e}")
        sys.exit(1)
    
    # Get image data
    width, height = img.size
    pixels = img.load()
    
    # The original icon is light gray (#E3E3E3)
    # We need to create two versions:
    
    # 1. APP-DARK.PNG - Keep the light icon (for dark mode)
    print("\n📱 Creating app-dark.png (light icon for dark mode)...")
    dark_mode_icon = img.copy()
    dark_mode_path = os.path.join(output_dir, "app-dark.png")
    dark_mode_icon.save(dark_mode_path, "PNG")
    print(f"   ✅ Saved: {dark_mode_path}")
    
    # 2. APP.PNG - Create a dark version (for light mode)
    print("\n📱 Creating app.png (dark icon for light mode)...")
    light_mode_icon = Image.new("RGBA", img.size, (0, 0, 0, 0))
    light_pixels = light_mode_icon.load()
    
    # Invert the luminosity while keeping the alpha channel
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            
            # If pixel has some transparency, make it darker
            if a > 0:
                # Invert: bright becomes dark
                # Original ~227 (#E3) becomes ~48 (#30)
                new_r = 255 - r
                new_g = 255 - g  
                new_b = 255 - b
                light_pixels[x, y] = (new_r, new_g, new_b, a)
            else:
                light_pixels[x, y] = (r, g, b, a)
    
    light_mode_path = os.path.join(output_dir, "app.png")
    light_mode_icon.save(light_mode_path, "PNG")
    print(f"   ✅ Saved: {light_mode_path}")
    
    print("\n✨ Icon processing complete!")
    print("\n📋 Summary:")
    print(f"   app.png       - Dark icon for light mode")
    print(f"   app-dark.png  - Light icon for dark mode")
    print(f"\n📤 Upload these files to: apps/musicxmlviewer/img/")

if __name__ == "__main__":
    # Paths
    input_icon = "/Users/Michele/musicxmlplayer/library_music_24dp_E3E3E3_FILL0_wght400_GRAD0_opsz24.png"
    output_directory = "/Users/Michele/Sites/musicxmlviewer/img"
    
    # Check if input exists
    if not os.path.exists(input_icon):
        print(f"❌ Input icon not found: {input_icon}")
        print(f"   Looking for icon at: {os.path.dirname(input_icon)}")
        sys.exit(1)
    
    # Process icons
    create_app_icons(input_icon, output_directory)
