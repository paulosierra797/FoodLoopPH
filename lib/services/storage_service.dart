import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Bucket names
  static const String foodImagesBucket = 'food-images';
  static const String profileImagesBucket = 'profile-images';

  /// Initialize storage buckets (call this once during app initialization)
  Future<void> initializeBuckets() async {
    try {
      // Test bucket access by trying to list files instead of creating buckets
      await _supabase.storage.from(foodImagesBucket).list();
      debugPrint('✅ $foodImagesBucket bucket is accessible');
      
      await _supabase.storage.from(profileImagesBucket).list();
      debugPrint('✅ $profileImagesBucket bucket is accessible');
      
      debugPrint('🎉 All storage buckets are ready for use!');
      
    } catch (e) {
      debugPrint('⚠️ Storage bucket access test failed: $e');
      debugPrint('📝 Please ensure buckets exist in Supabase Dashboard:');
      debugPrint('   - $foodImagesBucket (public, 5MB limit)');
      debugPrint('   - $profileImagesBucket (public, 2MB limit)');
      debugPrint('ℹ️ App will continue but image upload may fail');
    }
  }

  /// Upload a food image and return the public URL
  Future<String?> uploadFoodImage(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = 'food_${user.id}_${timestamp}${extension}';
      final filePath = 'public/$fileName';

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Upload to Supabase Storage
      await _supabase.storage
          .from(foodImagesBucket)
          .uploadBinary(filePath, bytes, 
            fileOptions: FileOptions(
              contentType: _getMimeType(extension),
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(foodImagesBucket)
          .getPublicUrl(filePath);

      debugPrint('✅ Uploaded food image: $publicUrl');
      return publicUrl;

    } catch (e) {
      debugPrint('❌ Error uploading food image: $e');
      return null;
    }
  }

  /// Upload multiple food images and return list of public URLs
  Future<List<String>> uploadFoodImages(List<File> imageFiles) async {
    final uploadedUrls = <String>[];
    
    for (final imageFile in imageFiles) {
      final url = await uploadFoodImage(imageFile);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }

  /// Upload a profile image and return the public URL
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename (overwrite previous profile image)
      final extension = path.extension(imageFile.path);
      final fileName = 'profile_${user.id}${extension}';
      final filePath = 'public/$fileName';

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Upload to Supabase Storage (upsert = true to replace existing)
      await _supabase.storage
          .from(profileImagesBucket)
          .uploadBinary(filePath, bytes,
            fileOptions: FileOptions(
              contentType: _getMimeType(extension),
              upsert: true, // Replace if exists
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(profileImagesBucket)
          .getPublicUrl(filePath);

      debugPrint('✅ Uploaded profile image: $publicUrl');
      return publicUrl;

    } catch (e) {
      debugPrint('❌ Error uploading profile image: $e');
      return null;
    }
  }

  /// Delete a food image
  Future<bool> deleteFoodImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final filePath = _extractFilePathFromUrl(imageUrl, foodImagesBucket);
      if (filePath == null) return false;

      await _supabase.storage
          .from(foodImagesBucket)
          .remove([filePath]);

      debugPrint('✅ Deleted food image: $filePath');
      return true;

    } catch (e) {
      debugPrint('❌ Error deleting food image: $e');
      return false;
    }
  }

  /// Delete multiple food images
  Future<void> deleteFoodImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      await deleteFoodImage(url);
    }
  }

  /// Get MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Extract file path from Supabase storage URL
  String? _extractFilePathFromUrl(String url, String bucketName) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      
      // Find bucket name in path
      final bucketIndex = segments.indexOf(bucketName);
      if (bucketIndex == -1) return null;
      
      // Get path after bucket name
      final pathSegments = segments.sublist(bucketIndex + 1);
      return pathSegments.join('/');
    } catch (e) {
      debugPrint('❌ Error extracting file path from URL: $e');
      return null;
    }
  }

  /// Check if URL is a valid Supabase storage URL
  bool isSupabaseStorageUrl(String url) {
    return url.contains('/storage/v1/object/public/');
  }

  /// Get optimized image URL with transform parameters
  String getOptimizedImageUrl(String originalUrl, {
    int? width,
    int? height,
    String quality = '80',
    String format = 'webp',
  }) {
    if (!isSupabaseStorageUrl(originalUrl)) return originalUrl;
    
    final uri = Uri.parse(originalUrl);
    final queryParams = Map<String, String>.from(uri.queryParameters);
    
    if (width != null) queryParams['width'] = width.toString();
    if (height != null) queryParams['height'] = height.toString();
    queryParams['quality'] = quality;
    queryParams['format'] = format;
    
    return uri.replace(queryParameters: queryParams).toString();
  }
}