import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'storage_service.dart';
import '../../models/app_user.dart';
import '../../models/category.dart';
import '../../models/chat_message.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../models/promo_banner.dart';
import '../../models/store.dart';
import '../../models/user_role.dart';
import '../../models/cargo_ad.dart';
import '../../models/property_listing.dart';
import '../../models/property_booking.dart';
import '../../models/second_hand_item.dart';
import '../../models/second_hand_booking.dart';

/// Central Supabase data layer for Mogadishu Market.
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static bool _ready = false;
  static bool get isReady => _ready;

  static Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    _ready = true;
  }

  // ── Profiles ───────────────────────────────────────────────────────────────

  static Future<List<AppUser>> fetchProfiles() async {
    final rows = await client.from('profiles').select();
    return (rows as List).map((r) => AppUser.fromJson(r)).toList();
  }

  static Future<AppUser?> fetchProfileById(String id) async {
    final rows = await client.from('profiles').select().eq('id', id).maybeSingle();
    if (rows == null) return null;
    return AppUser.fromJson(rows);
  }

  static Future<AppUser?> loginProfile(String emailOrPhone, String password) async {
    final rows = await client.from('profiles').select();
    for (final row in rows as List) {
      final u = AppUser.fromJson(row);
      final matchEmail = u.email == emailOrPhone && u.email.isNotEmpty;
      final matchPhone = u.phone == emailOrPhone && (u.phone?.isNotEmpty ?? false);
      if ((matchEmail || matchPhone) && u.password == password) return u;
    }
    return null;
  }

  static Future<bool> emailExists(String email) async {
    final row = await client.from('profiles').select('id').eq('email', email).maybeSingle();
    return row != null;
  }

  static Future<void> upsertProfile(AppUser user) async {
    await client.from('profiles').upsert(user.toJson());
  }

  static Future<void> updateProfileStore(String userId, String storeId) async {
    await client.from('profiles').update({'store_id': storeId}).eq('id', userId);
  }

  // ── Categories ─────────────────────────────────────────────────────────────

  static Future<List<Category>> fetchCategories() async {
    final rows = await client.from('categories').select().order('name');
    return (rows as List).map((r) => Category.fromJson(r)).toList();
  }

  static Future<void> upsertCategory(Category category) async {
    await client.from('categories').upsert(category.toJson());
  }

  static Future<void> upsertCategories(List<Category> list) async {
    if (list.isEmpty) return;
    await client.from('categories').upsert(list.map((c) => c.toJson()).toList());
  }

  static Future<void> deleteCategory(String id) async {
    await client.from('categories').delete().eq('id', id);
  }

  // ── Stores ─────────────────────────────────────────────────────────────────

  static Future<List<Store>> fetchStores() async {
    final rows = await client.from('stores').select();
    return (rows as List).map((r) => Store.fromJson(r)).toList();
  }

  static Future<void> upsertStore(Store store) async {
    await client.from('stores').upsert(store.toJson());
  }

  // ── Products ───────────────────────────────────────────────────────────────

  static Future<List<Product>> fetchProducts() async {
    final rows = await client.from('products').select();
    return (rows as List).map((r) => Product.fromJson(r)).toList();
  }

  static Future<void> upsertProduct(Product product) async {
    await client.from('products').upsert(product.toJson());
  }

  // ── Orders ─────────────────────────────────────────────────────────────────

  static Future<List<Order>> fetchOrders() async {
    final rows = await client.from('orders').select().order('date', ascending: false);
    return (rows as List).map((r) => Order.fromJson(r)).toList();
  }

  static Future<void> upsertOrder(Order order) async {
    final fullJson = order.toJson();
    try {
      await client.from('orders').upsert(fullJson);
    } catch (e) {
      debugPrint('upsertOrder full error ($e), attempting fallback payload...');
      try {
        final fallbackJson = Map<String, dynamic>.from(fullJson);
        fallbackJson.remove('canceled_by_driver_id');
        fallbackJson.remove('canceled_by_driver_name');
        await client.from('orders').upsert(fallbackJson);
      } catch (e2) {
        debugPrint('upsertOrder fallback error ($e2), attempting minimal core payload...');
        try {
          final minimalJson = {
            'id': order.id,
            'user_id': order.userId,
            'items': order.items.map((i) => i.toJson()).toList(),
            'total_amount': order.totalAmount,
            'date': order.date.toUtc().toIso8601String(),
            'status': order.status.name,
            'store_id': order.storeId,
            'payment_method': order.paymentMethod.name,
            'is_paid': order.isPaid,
            'delivery_type': order.deliveryType,
            'customer_name': order.customerName,
            'customer_phone': order.customerPhone,
            'customer_address': order.customerAddress,
          };
          await client.from('orders').upsert(minimalJson);
        } catch (e3) {
          debugPrint('upsertOrder minimal error ($e3). Order will be maintained in memory.');
        }
      }
    }
  }

  // ── Promos ─────────────────────────────────────────────────────────────────

  static Future<List<PromoBanner>> fetchPromos() async {
    final rows = await client.from('promo_banners').select();
    return (rows as List).map((r) => PromoBanner.fromJson(r)).toList();
  }

  static Future<void> upsertPromo(PromoBanner promo) async {
    await client.from('promo_banners').upsert(promo.toJson());
  }

  static Future<void> deletePromo(String id) async {
    await client.from('promo_banners').delete().eq('id', id);
  }

  // ── Settings ───────────────────────────────────────────────────────────────

  static Future<Map<String, String>> fetchSettings() async {
    try {
      final rows = await client.from('app_settings').select();
      final map = <String, String>{};
      for (final row in rows as List) {
        map[row['key'] as String] = row['value'] as String;
      }
      return map;
    } catch (e) {
      debugPrint('fetchSettings: $e');
      return {};
    }
  }

  static Future<void> setSetting(String key, String value) async {
    await client.from('app_settings').upsert({'key': key, 'value': value});
  }

  // ── Cargo Ads ──────────────────────────────────────────────────────────────

  static Future<List<CargoAd>> fetchCargoAds() async {
    try {
      final res = await client
          .from('cargo_ads')
          .select()
          .order('created_at', ascending: false);
      return (res as List).map((r) => CargoAd.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> upsertCargoAd(CargoAd ad) async {
    await client.from('cargo_ads').upsert(ad.toJson());
  }

  static Future<void> deleteCargoAd(String id) async {
    await client.from('cargo_ads').delete().eq('id', id);
  }

  // ── Property Listings ──────────────────────────────────────────────────────

  static Future<List<PropertyListing>> fetchPropertyListings() async {
    try {
      final res = await client
          .from('property_listings')
          .select()
          .order('created_at', ascending: false);
      return (res as List).map((r) => PropertyListing.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> upsertPropertyListing(PropertyListing listing) async {
    try {
      await client.from('property_listings').upsert(listing.toJson());
    } catch (e) {
      debugPrint('upsertPropertyListing fallback without is_reserved: $e');
      final map = listing.toJson();
      map.remove('is_reserved');
      await client.from('property_listings').upsert(map);
    }
  }

  static Future<void> deletePropertyListing(String id) async {
    await client.from('property_listings').delete().eq('id', id);
  }

  // ── Property Bookings ──────────────────────────────────────────────────────

  static Future<List<PropertyBooking>> fetchPropertyBookings() async {
    try {
      final res = await client
          .from('property_bookings')
          .select()
          .order('created_at', ascending: false);
      return (res as List).map((r) => PropertyBooking.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> upsertPropertyBooking(PropertyBooking booking) async {
    try {
      await client.from('property_bookings').upsert(booking.toJson());
    } catch (e) {
      debugPrint('upsertPropertyBooking fallback without is_fully_paid: $e');
      final map = booking.toJson();
      map.remove('is_fully_paid');
      await client.from('property_bookings').upsert(map);
    }
  }

  static Future<void> deletePropertyBooking(String id) async {
    await client.from('property_bookings').delete().eq('id', id);
  }

  // ── Second Hand Items ────────────────────────────────────────────────────────

  static Future<List<SecondHandItem>> fetchSecondHandItems() async {
    try {
      final res = await client
          .from('second_hand_items')
          .select()
          .order('created_at', ascending: false);
      return (res as List).map((r) => SecondHandItem.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> upsertSecondHandItem(SecondHandItem item) async {
    await client.from('second_hand_items').upsert(item.toJson());
  }

  static Future<void> deleteSecondHandItem(String id) async {
    await client.from('second_hand_items').delete().eq('id', id);
  }

  // ── Second Hand Bookings ───────────────────────────────────────────────────

  static Future<List<SecondHandBooking>> fetchSecondHandBookings() async {
    try {
      final res = await client
          .from('second_hand_bookings')
          .select()
          .order('created_at', ascending: false);
      return (res as List).map((r) => SecondHandBooking.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> upsertSecondHandBooking(SecondHandBooking booking) async {
    await client.from('second_hand_bookings').upsert(booking.toJson());
  }

  static Future<void> deleteSecondHandBooking(String id) async {
    await client.from('second_hand_bookings').delete().eq('id', id);
  }

  // ── Technicians ────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchTechnicians() async {
    try {
      final res = await client.from('technicians').select().order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res as List);
    } catch (_) { return []; }
  }

  static Future<void> upsertTechnician(Map<String, dynamic> tech) async {
    await client.from('technicians').upsert(tech);
  }

  static Future<void> deleteTechnician(String id) async {
    await client.from('technicians').delete().eq('id', id);
  }

  // ── Technician Bookings ────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchTechBookings() async {
    try {
      final res = await client.from('tech_bookings').select().order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res as List);
    } catch (_) { return []; }
  }

  static Future<void> insertTechBooking(Map<String, dynamic> booking) async {
    try {
      await client.from('tech_bookings').insert(booking);
    } catch (e) {
      final fallback = Map<String, dynamic>.from(booking);
      fallback.remove('is_paid');
      fallback.remove('phone');
      fallback.remove('transaction_id');
      await client.from('tech_bookings').insert(fallback);
    }
  }

  static Future<void> updateTechBookingStatus(String id, String status) async {
    await client.from('tech_bookings').update({'status': status}).eq('id', id);
  }

  // ── Technician Pricing ─────────────────────────────────────────────────────

  static Future<Map<String, Map<String, double>>> fetchTechPricing() async {
    try {
      final res = await client.from('tech_pricing').select();
      final result = <String, Map<String, double>>{};
      for (final row in res as List) {
        final cat = row['category'] as String;
        result[cat] = {
          'Sare':         (row['price_sare'] as num).toDouble(),
          'Dhex Dhexaad': (row['price_dhex'] as num).toDouble(),
          'Hoose':        (row['price_hoose'] as num).toDouble(),
        };
      }
      return result;
    } catch (_) { return {}; }
  }

  static Future<void> upsertTechPricing(String category, double sare, double dhex, double hoose) async {
    await client.from('tech_pricing').upsert({
      'category': category,
      'price_sare': sare,
      'price_dhex': dhex,
      'price_hoose': hoose,
    });
  }

  // ── Chat ───────────────────────────────────────────────────────────────────

  static Future<List<ChatMessage>> fetchChatMessages() async {
    final rows = await client
        .from('chat_messages')
        .select()
        .order('timestamp', ascending: true);
    return (rows as List).map((r) => _chatFromRow(r)).toList();
  }

  static Future<void> insertChatMessage(ChatMessage msg) async {
    await client.from('chat_messages').upsert({
      'id': msg.id,
      'sender_id': msg.senderId,
      'receiver_id': msg.receiverId,
      'content': msg.content,
      'timestamp': msg.timestamp.toUtc().toIso8601String(),
      'is_read': msg.isRead,
    });
  }

  static ChatMessage _chatFromRow(Map<String, dynamic> r) => ChatMessage(
        id: r['id'] as String,
        senderId: r['sender_id'] as String,
        receiverId: r['receiver_id'] as String,
        content: r['content'] as String,
        timestamp: DateTime.parse(r['timestamp'] as String).toLocal(),
        isRead: r['is_read'] as bool? ?? false,
      );

  // ── Seed demo data when DB is empty ────────────────────────────────────────

  static Future<void> seedIfEmpty() async {
    if (StorageService.isSeedVerified()) return;

    try {
      final row =
          await client.from('categories').select('id').limit(1).maybeSingle();
      if (row != null) {
        await StorageService.setSeedVerified();
        return;
      }
    } catch (e) {
      debugPrint('seedIfEmpty check: $e');
      return;
    }

    await upsertCategories([
      Category(id: '1', name: 'Electronics', icon: 'bolt'),
      Category(id: '2', name: 'Fashion', icon: 'shirt'),
      Category(id: '3', name: 'Groceries', icon: 'basket-shopping'),
      Category(id: '4', name: 'Food', icon: 'utensils'),
      Category(id: '5', name: 'Beauty', icon: 'sparkles'),
      Category(id: '6', name: 'Home', icon: 'house'),
      Category(id: '7', name: 'Services', icon: 'hand-holding-heart'),
    ]);

    final store1 = Store(
      id: 'store1',
      name: 'Mogadishu Tech',
      logo: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=200',
      banner: 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=800',
      description:
          'Your go-to destination for the latest smartphones, laptops, and gadgets.',
      contact: '+252 61 0000001',
      rating: 4.8,
      followers: 1200,
      isApproved: true,
      ownerId: 'admin',
      evcNumber: '610000001',
      edahabNumber: '610000001',
    );
    final store2 = Store(
      id: 'store2',
      name: 'Xaafadda Fashion',
      logo: 'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=200',
      banner: 'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=800',
      description: 'Trendy Somali and international fashion for the whole family.',
      contact: '+252 61 0000002',
      rating: 4.6,
      followers: 850,
      isApproved: true,
      ownerId: 'seller1',
      evcNumber: '610000002',
      edahabNumber: '610000002',
    );
    final store3 = Store(
      id: 'store3',
      name: 'Fresh Market MGQ',
      logo: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200',
      banner: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
      description: 'Daily fresh produce, groceries and household essentials.',
      contact: '+252 61 0000003',
      rating: 4.5,
      followers: 620,
      isApproved: true,
      ownerId: 'seller2',
      evcNumber: '610000003',
      edahabNumber: '610000003',
    );
    for (final s in [store1, store2, store3]) {
      await upsertStore(s);
    }

    final productsList = [
      Product(
        id: 'p1',
        name: 'iPhone 15 Pro',
        description: 'Apple iPhone 15 Pro with A17 chip and titanium design.',
        price: 1099.0,
        image: 'https://images.unsplash.com/photo-1696446701796-da61225697cc?w=400',
        categoryId: '1',
        storeId: 'store1',
        storeName: 'Mogadishu Tech',
        stock: 10,
        rating: 4.9,
        isApproved: true,
      ),
      Product(
        id: 'p2',
        name: 'Samsung Galaxy S24',
        description: 'Latest Samsung flagship with AI features.',
        price: 899.0,
        image: 'https://images.unsplash.com/photo-1610945264803-c22b62d2a7b3?w=400',
        categoryId: '1',
        storeId: 'store1',
        storeName: 'Mogadishu Tech',
        stock: 8,
        rating: 4.7,
        isApproved: true,
      ),
      Product(
        id: 'p3',
        name: 'Sony WH-1000XM5',
        description: 'Industry-leading noise cancelling headphones.',
        price: 349.0,
        image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        categoryId: '1',
        storeId: 'store1',
        storeName: 'Mogadishu Tech',
        stock: 15,
        rating: 4.8,
        isApproved: true,
      ),
      Product(
        id: 'p4',
        name: 'MacBook Air M3',
        description: 'Ultra-thin laptop with Apple M3 chip.',
        price: 1299.0,
        image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
        categoryId: '1',
        storeId: 'store1',
        storeName: 'Mogadishu Tech',
        stock: 5,
        rating: 4.9,
        isApproved: true,
      ),
      Product(
        id: 'p5',
        name: 'Somali Dirac Set',
        description: 'Beautiful traditional Somali Dirac for women.',
        price: 79.0,
        image: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=400',
        categoryId: '2',
        storeId: 'store2',
        storeName: 'Xaafadda Fashion',
        stock: 20,
        rating: 4.7,
        isApproved: true,
      ),
      Product(
        id: 'p6',
        name: "Men's Casual Shirt",
        description: 'Modern slim-fit shirt for everyday wear.',
        price: 45.0,
        image: 'https://images.unsplash.com/photo-1620012253295-c15cc3e65df4?w=400',
        categoryId: '2',
        storeId: 'store2',
        storeName: 'Xaafadda Fashion',
        stock: 30,
        rating: 4.5,
        isApproved: true,
      ),
      Product(
        id: 'p7',
        name: 'Organic Camel Milk',
        description: 'Fresh organic camel milk from local farms.',
        price: 12.0,
        image: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400',
        categoryId: '3',
        storeId: 'store3',
        storeName: 'Fresh Market MGQ',
        stock: 50,
        rating: 4.6,
        isApproved: true,
      ),
      Product(
        id: 'p8',
        name: 'Somali Tea Blend',
        description: 'Traditional spiced Somali tea blend (Shaheed).',
        price: 18.0,
        image: 'https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?w=400',
        categoryId: '4',
        storeId: 'store3',
        storeName: 'Fresh Market MGQ',
        stock: 100,
        rating: 4.9,
        isApproved: true,
      ),
    ];
    for (final p in productsList) {
      await upsertProduct(p);
    }

    final promos = await fetchPromos();
    if (promos.isEmpty) {
      final initialPromos = [
        PromoBanner(
          id: '1',
          imageUrl:
              'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800',
          tag: 'SUPER SALE',
          title: '50% Off On All\nElectronics',
          btnText: 'Shop Now',
          colorHex: '0xFFFF6B00',
        ),
        PromoBanner(
          id: '2',
          imageUrl:
              'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=800',
          tag: 'NEW ARRIVAL',
          title: 'Latest Fashion\nTrends 2025',
          btnText: 'Explore',
          colorHex: '0xFF00D285',
        ),
        PromoBanner(
          id: '3',
          imageUrl:
              'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
          tag: 'FREE DELIVERY',
          title: 'Fresh Groceries\nDelivered Today',
          btnText: 'Order Now',
          colorHex: '0xFFFFB800',
        ),
      ];
      for (final promo in initialPromos) {
        await upsertPromo(promo);
      }
    }

    // Ensure default admin exists
    final admin = AppUser(
      id: 'admin',
      name: 'Super Admin',
      email: 'admin@market.com',
      password: 'admin123',
      role: UserRole.admin,
    );
    await upsertProfile(admin);
    await StorageService.setSeedVerified();
  }

  /// Throws if Supabase is unreachable; use [healthCheckMessage] for UI text.
  static Future<void> healthCheck() async {
    await client.from('profiles').select('id').limit(1);
  }

  static String healthCheckMessage(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('socket') ||
        msg.contains('network') ||
        msg.contains('failed host lookup') ||
        msg.contains('connection') ||
        msg.contains('internet')) {
      return 'Internet ma jiro ama server lama gaari karo. Hubi WiFi/data.';
    }
    if (msg.contains('42p01') ||
        msg.contains('does not exist') ||
        msg.contains('relation')) {
      return 'Supabase tables ma jiraan. Ku dheji SQL-ka supabase/migrations/001_initial_schema.sql';
    }
    if (msg.contains('pgrst204') || msg.contains('column') && msg.contains('not found')) {
      return 'Server khalaad: Database-ka waxaa ka maqan column (is_banned). Fadlan ku dheji SQL-ka ku jira supabase/migrations/002_features.sql SQL Editor-ka.';
    }
    return 'Khalad Supabase: $error';
  }
}
