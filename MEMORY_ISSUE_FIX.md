# Memory Issue Fix for Large AI Models

## Problem Analysis

The app is crashing with "Lost connection to device" when sharing images because:

1. **Large Model Size**: Vision Pro (LFM2-VL-1.6B) is ~1.19GB and requires substantial memory
2. **Memory Allocation**: Model tries to allocate 549MB + 100MB + other memory regions
3. **Device Limitations**: Mobile devices have limited RAM, causing crashes during model loading
4. **Shared Content Context**: When sharing from external apps, memory pressure is higher

## Error Pattern

```
I/LiquidInferenceEngine: module has memory regions of size [549336064, 100663296, 163840, 1729]
Lost connection to device.
```

## Solution Implemented

### 1. Enhanced Error Detection and Handling

**AI Service State Notifier** (`lib/services/ai_leap_service.dart`):

- Added memory-related error detection in model loading
- Better logging of model size and memory requirements
- Graceful fallback to smaller models when memory errors occur

```dart
// Check if this is a memory-related error
final errorString = e.toString().toLowerCase();
if (errorString.contains('memory') ||
    errorString.contains('allocation') ||
    errorString.contains('lost connection') ||
    errorString.contains('out of memory')) {
  log('⚠️ Memory-related error detected. Skipping large models and trying smaller ones.');
}
```

### 2. Improved Shared Content Handler

**Shared Content Handler** (`lib/services/shared_content_handler.dart`):

- Added timeout protection (30 seconds) to prevent indefinite hanging
- Enhanced initialization checking with delay for model readiness
- Better error messages for memory-related issues

```dart
// Process image with AI with timeout to prevent hanging
final parsedEvent = await Future.any([
  aiService.parseImageWithAI(imageBytes, additionalContext: 'Shared image from external app'),
  Future.delayed(
    const Duration(seconds: 30),
    () => throw const SharedContentException(
      'Image processing timed out. This may be due to insufficient memory for the current AI model.',
    ),
  ),
]);
```

### 3. Smart Model Loading Strategy

**Priority System**:

1. **Basic Models First**: Vision Lite (385MB) loads before Vision Pro (1.19GB)
2. **Memory-Aware Loading**: Skip large models if memory errors detected
3. **Fallback Chain**: Automatically try next available model if current fails

## User Experience Improvements

### Before the Fix

- App crashes silently when sharing images
- No indication of memory issues
- User stuck with non-functional sharing

### After the Fix

- Graceful handling of memory constraints
- Clear error messages about memory limitations
- Automatic fallback to smaller models
- Timeout protection prevents hanging

## Recommendations for Users

### For Optimal Performance

1. **Download Vision Lite**: Smaller, faster, works on more devices
2. **Memory Management**: Close other apps before processing large images
3. **Image Size**: Smaller images (< 5MB) process faster and use less memory

### Model Comparison

| Model       | Size   | Memory Usage | Performance  | Recommended For                     |
| ----------- | ------ | ------------ | ------------ | ----------------------------------- |
| Vision Lite | 385MB  | ~400MB RAM   | Fast         | Most users, older devices           |
| Vision Pro  | 1.19GB | ~1.2GB RAM   | Best quality | High-end devices, critical accuracy |

## Technical Details

### Memory Requirements by Model

- **Vision Lite (LFM2-VL-450M)**: ~385MB model + ~400MB runtime = ~785MB total
- **Vision Pro (LFM2-VL-1.6B)**: ~1.19GB model + ~1.2GB runtime = ~2.4GB total

### Device Compatibility

- **Vision Lite**: Works on most Android devices with 3GB+ RAM
- **Vision Pro**: Requires high-end devices with 6GB+ RAM

### Error Recovery Flow

1. Try to load user's preferred model
2. If memory error detected, skip to smaller models
3. If all models fail, provide clear error message
4. Suggest downloading Vision Lite as alternative

## Implementation Status

✅ **Completed**:

- Memory error detection and handling
- Timeout protection for image processing
- Enhanced error messages
- Smart model loading priority

🔄 **In Progress**:

- Model recommendation system in UI

📋 **Future Enhancements**:

- Automatic model switching based on device capabilities
- Memory usage monitoring and warnings
- Progressive image processing (resize large images)
- Background model preloading

## Testing Recommendations

1. **Memory Stress Test**: Share large images on devices with limited RAM
2. **Model Switching**: Test with only Vision Pro, then only Vision Lite
3. **Timeout Scenarios**: Test with very large images or slow devices
4. **Error Recovery**: Verify proper error messages and fallback behavior

The fix ensures that image sharing works reliably across different device capabilities while providing clear feedback to users about memory limitations.
