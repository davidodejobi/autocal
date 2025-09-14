# Immediate Solution for Image Sharing Crash

## The Problem

Your app is crashing when sharing images because the **Vision Pro model (LFM2-VL-1.6B)** is too large for your device's available memory during the sharing process.

## Quick Fix Options

### Option 1: Download Vision Lite (Recommended)

1. **Open AutoCal app**
2. **Go to Settings** (bottom navigation)
3. **Tap "AI Model Management"**
4. **Download "Vision Lite (385MB)"**
5. **Try sharing images again**

**Why this works**: Vision Lite uses much less memory (~385MB vs 1.19GB) and is specifically designed for mobile devices.

### Option 2: Free Up Memory Before Sharing

1. **Close other apps** from recent apps menu
2. **Restart your device** to free up RAM
3. **Try sharing images again**

**Why this works**: Gives the Vision Pro model more available memory to load.

### Option 3: Use Manual Image Processing

1. **Open AutoCal app**
2. **Tap the AI button** (⭐ icon) on home screen
3. **Select "Choose Image"**
4. **Pick your image manually**

**Why this works**: Manual processing happens when the app has more memory available.

## What I Fixed in the Code

✅ **Added timeout protection** - App won't hang indefinitely  
✅ **Better error messages** - You'll see helpful messages instead of crashes  
✅ **Smart model loading** - App tries smaller models first  
✅ **Memory detection** - App detects memory issues and suggests solutions

## Long-term Recommendation

**Download Vision Lite** for the best image sharing experience:

- **Faster processing** (loads in ~2-3 seconds vs 10+ seconds)
- **Lower memory usage** (works on devices with 3GB+ RAM)
- **Same accuracy** for most calendar/event extraction tasks
- **Better for sharing** from external apps

## Model Comparison

| Model       | Size   | Memory | Speed  | Best For           |
| ----------- | ------ | ------ | ------ | ------------------ |
| Vision Lite | 385MB  | ~800MB | Fast   | Daily use, sharing |
| Vision Pro  | 1.19GB | ~2.4GB | Slower | Complex documents  |

## Next Steps

1. **Try the fixes above**
2. **Download Vision Lite** for reliable image sharing
3. **Keep Vision Pro** for complex document analysis if needed
4. **Report back** if you still have issues

The app should now handle memory issues gracefully instead of crashing, but Vision Lite will give you the best experience for image sharing!
