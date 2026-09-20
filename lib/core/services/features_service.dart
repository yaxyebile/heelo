import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/app_notification.dart';
import '../../models/coupon.dart';
import '../../models/product_review.dart';
import 'supabase_service.dart';

class FeaturesService {
  static SupabaseClient get _db => SupabaseService.client;

  // ── Wishlist ─────────────────────────────────────────────────────────────

  static Future<List<String>> fetchWishlistProductIds(String userId) async {
    try {
      final rows = await _db.from('wishlist').select('product_id').eq('user_id', userId);
      return (rows as List).map((r) => r['product_id'] as String).toList();
    } catch (e) {
      debugPrint('fetchWishlistProductIds missing table error: $e');
      return [];
    }
  }

  static Future<void> addToWishlist(String userId, String productId) async {
    try {
      await _db.from('wishlist').upsert({
        'user_id': userId,
        'product_id': productId,
      });
    } catch (e) {
      debugPrint('addToWishlist missing table error: $e');
    }
  }

  static Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      await _db.from('wishlist').delete().eq('user_id', userId).eq('product_id', productId);
    } catch (e) {
      debugPrint('removeFromWishlist missing table error: $e');
    }
  }

  // ── Reviews ────────────────────────────────────────────────────────────────

  static Future<List<ProductReview>> fetchReviews(String productId) async {
    try {
      final rows = await _db
          .from('product_reviews')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      return (rows as List).map((r) => ProductReview.fromJson(r)).toList();
    } catch (e) {
      debugPrint('fetchReviews missing table error: $e');
      return [];
    }
  }

  static Future<void> addReview({
    required String productId,
    required String userId,
    required int rating,
    String comment = '',
  }) async {
    try {
      await _db.from('product_reviews').upsert({
        'id': const Uuid().v4(),
        'product_id': productId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      });
      final reviews = await fetchReviews(productId);
      if (reviews.isEmpty) return;
      final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
      await _db.from('products').update({'rating': avg}).eq('id', productId);
    } catch (e) {
      debugPrint('addReview missing table error: $e');
    }
  }

  // ── Notifications ──────────────────────────────────────────────────────────

  static Future<List<AppNotification>> fetchNotifications(String userId, {String? role}) async {
    try {
      String filter = 'user_id.eq.$userId,user_id.eq.all';
      if (role != null && role.isNotEmpty) {
        filter += ',user_id.eq.$role';
      }
      final rows = await _db
          .from('app_notifications')
          .select()
          .or(filter)
          .order('created_at', ascending: false)
          .limit(50);
      return (rows as List).map((r) => AppNotification.fromJson(r)).toList();
    } catch (e) {
      debugPrint('fetchNotifications missing table error: $e');
      return [];
    }
  }

  static Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
    String? relatedId,
  }) async {
    try {
      await _db.from('app_notifications').insert({
        'id': const Uuid().v4(),
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'related_id': relatedId,
        'is_read': false,
      });
    } catch (e) {
      debugPrint('createNotification missing table error: $e');
    }
  }

  static Future<void> markNotificationRead(String id) async {
    try {
      await _db.from('app_notifications').update({'is_read': true}).eq('id', id);
    } catch (e) {
      debugPrint('markNotificationRead missing table error: $e');
    }
  }

  static Future<void> markAllNotificationsRead(String userId) async {
    try {
      await _db
          .from('app_notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('markAllNotificationsRead missing table error: $e');
    }
  }

  // ── Coupons ────────────────────────────────────────────────────────────────

  static Future<Coupon?> findCoupon(String code) async {
    try {
      final row = await _db
          .from('coupons')
          .select()
          .eq('code', code.toUpperCase().trim())
          .eq('is_active', true)
          .maybeSingle();
      if (row == null) return null;
      final c = Coupon.fromJson(row);
      if (c.validUntil != null && c.validUntil!.isBefore(DateTime.now())) return null;
      return c;
    } catch(e) {
      debugPrint('findCoupon missing table error: $e');
      return null;
    }
  }

  static Future<List<Coupon>> fetchCoupons() async {
    try {
      final rows = await _db.from('coupons').select().order('code');
      return (rows as List).map((r) => Coupon.fromJson(r)).toList();
    } catch(e) {
      debugPrint('fetchCoupons missing table error: $e');
      return [];
    }
  }

  static Future<void> upsertCoupon(Coupon coupon) async {
    try {
      await _db.from('coupons').upsert(coupon.toJson());
    } catch(e) {
      debugPrint('upsertCoupon missing table error: $e');
    }
  }

  static Future<void> deleteCoupon(String id) async {
    try {
      await _db.from('coupons').delete().eq('id', id);
    } catch(e) {
      debugPrint('deleteCoupon missing table error: $e');
    }
  }

  // ── Ban ────────────────────────────────────────────────────────────────────

  static Future<void> setProfileBanned(String userId, bool banned) async {
    await _db.from('profiles').update({'is_banned': banned}).eq('id', userId);
  }

  static Future<void> setStoreBanned(String storeId, bool banned) async {
    await _db.from('stores').update({'is_banned': banned}).eq('id', storeId);
  }

  // ── Image upload ───────────────────────────────────────────────────────────

  static Future<String?> uploadProductImage(File file, String productId) async {
    try {
      final path = '$productId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _db.storage.from('product-images').upload(path, file);
      return _db.storage.from('product-images').getPublicUrl(path);
    } catch (e) {
      debugPrint('uploadProductImage: $e');
      return null;
    }
  }
}
