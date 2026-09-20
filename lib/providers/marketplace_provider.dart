import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/services/features_service.dart';
import '../core/services/supabase_service.dart';
import '../models/coupon.dart';
import '../models/app_user.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/promo_banner.dart';
import '../models/store.dart';
import '../models/user_role.dart';
import '../models/cargo_ad.dart';
import '../models/property_listing.dart';
import '../models/property_booking.dart';
import '../models/second_hand_item.dart';
import '../models/second_hand_booking.dart';

class MarketplaceProvider extends ChangeNotifier {
  List<Store> _stores = [];
  List<Product> _products = [];
  List<Category> _categories = [];
  List<Order> _orders = [];
  List<PromoBanner> _promos = [];
  List<AppUser> _users = [];
  List<CargoAd> _cargoAds = [];
  List<PropertyListing> _propertyListings = [];
  List<PropertyBooking> _propertyBookings = [];
  List<SecondHandItem> _secondHandItems = [];
  List<SecondHandBooking> _secondHandBookings = [];

  Map<String, List<OrderItem>> _cart = {};
  String _adminEvc = '614227744';
  String _adminEdahab = '624227744';
  String _waafiMerchantUid = 'M0914437';
  String _waafiApiUserId = '1009283';
  String _waafiApiKey = 'API-I25284gnwZ7uKRBVLjsBq5JBJ';
  bool _waafiAutoEnabled = true;
  bool _isLoading = true;
  String? _loadError;
  final Set<String> _wishlistIds = {};
  Coupon? _activeCoupon;

  bool storeHasDiscount(String storeId) {
    return _products.any((p) => p.storeId == storeId && p.hasDiscount && p.isApproved && p.stock > 0);
  }

  int getStoreMaxDiscount(String storeId) {
    final list = _products.where((p) => p.storeId == storeId && p.hasDiscount && p.isApproved && p.stock > 0);
    if (list.isEmpty) return 0;
    return list.map((p) => p.discountPercent).reduce((a, b) => a > b ? a : b);
  }

  List<Store> get stores {
    final list = _stores.where((s) => !s.isRestaurant && !s.isBanned).toList();
    list.sort((a, b) {
      final aHasDisc = storeHasDiscount(a.id);
      final bHasDisc = storeHasDiscount(b.id);
      if (aHasDisc && !bHasDisc) return -1;
      if (!aHasDisc && bHasDisc) return 1;
      return b.rating.compareTo(a.rating);
    });
    return list;
  }

  List<Store> get restaurants {
    final list = _stores.where((s) => s.isRestaurant && !s.isBanned).toList();
    list.sort((a, b) {
      final aHasDisc = storeHasDiscount(a.id);
      final bHasDisc = storeHasDiscount(b.id);
      if (aHasDisc && !bHasDisc) return -1;
      if (!aHasDisc && bHasDisc) return 1;
      return b.rating.compareTo(a.rating);
    });
    return list;
  }

  List<Product> get products => _products
      .where((p) => p.isApproved && p.stock > 0 && !_isStoreBanned(p.storeId))
      .toList();
  List<Store> get allStores => _stores;
  List<Product> get allProducts => _products;
  List<Category> get categories => _categories;
  List<Order> get orders => _orders;
  List<PromoBanner> get promos => _promos;
  List<AppUser> get users => _users;
  List<CargoAd> get cargoAds => _cargoAds;
  List<PropertyListing> get propertyListings =>
      _propertyListings.where((p) => p.isApproved && p.isAvailable).toList();
  List<PropertyListing> get allPropertyListings => _propertyListings;
  List<PropertyListing> get rentalListings => propertyListings
      .where((p) => p.listingType == PropertyListingType.rent)
      .toList();
  List<PropertyListing> get saleListings => propertyListings
      .where((p) => p.listingType == PropertyListingType.sale)
      .toList();
  List<PropertyBooking> get propertyBookings => _propertyBookings;
  List<SecondHandItem> get secondHandItems =>
      _secondHandItems.where((i) => i.status == SecondHandStatus.approved || i.status == SecondHandStatus.reserved).toList();
  List<SecondHandItem> get allSecondHandItems => _secondHandItems;
  List<SecondHandBooking> get secondHandBookings => _secondHandBookings;
  Map<String, List<OrderItem>> get cart => _cart;
  String get adminEvc => _adminEvc;
  String get adminEdahab => _adminEdahab;
  String get waafiMerchantUid => _waafiMerchantUid;
  String get waafiApiUserId => _waafiApiUserId;
  String get waafiApiKey => _waafiApiKey;
  bool get waafiAutoEnabled => _waafiAutoEnabled;
  bool get isLoading => _isLoading;
  String? get loadError => _loadError;
  Coupon? get activeCoupon => _activeCoupon;
  Set<String> get wishlistIds => _wishlistIds;

  bool _isStoreBanned(String storeId) {
    try {
      return _stores.firstWhere((s) => s.id == storeId).isBanned;
    } catch (_) {
      return false;
    }
  }

  MarketplaceProvider() {
    _loadData();
  }

  static const _networkTimeout = Duration(seconds: 20);

  /// Fast path: home/catalog first; orders/users + seed in background.
  Future<void> _loadData({bool waitForAll = false}) async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        SupabaseService.fetchCategories(),
        SupabaseService.fetchStores(),
        SupabaseService.fetchProducts(),
        SupabaseService.fetchPromos(),
        SupabaseService.fetchSettings(),
        SupabaseService.fetchCargoAds(),
        SupabaseService.fetchPropertyListings(),
        SupabaseService.fetchPropertyBookings(),
        SupabaseService.fetchSecondHandItems(),
        SupabaseService.fetchSecondHandBookings(),
      ]).timeout(_networkTimeout);

      _categories = results[0] as List<Category>;
      _stores = results[1] as List<Store>;
      _products = results[2] as List<Product>;
      _promos = results[3] as List<PromoBanner>;
      final settings = results[4] as Map<String, String>;
      _cargoAds = results[5] as List<CargoAd>;
      _propertyListings = results[6] as List<PropertyListing>;
      _propertyBookings = results[7] as List<PropertyBooking>;
      _secondHandItems  = results[8] as List<SecondHandItem>;
      _secondHandBookings = results[9] as List<SecondHandBooking>;
      _adminEvc = settings['admin_evc'] ?? _adminEvc;
      _adminEdahab = settings['admin_edahab'] ?? _adminEdahab;
      _waafiMerchantUid = settings['waafi_merchant_uid'] ?? _waafiMerchantUid;
      _waafiApiUserId = settings['waafi_api_user_id'] ?? _waafiApiUserId;
      _waafiApiKey = settings['waafi_api_key'] ?? _waafiApiKey;
      _waafiAutoEnabled = (settings['waafi_auto_enabled'] ?? 'true') == 'true';

      _isLoading = false;
      notifyListeners();

      final secondary = _loadSecondary();
      final seed = SupabaseService.seedIfEmpty();
      if (waitForAll) {
        await Future.wait([secondary, seed]);
      } else {
        unawaited(secondary);
        unawaited(seed);
      }
    } catch (e) {
      _loadError = SupabaseService.healthCheckMessage(e);
      debugPrint('MarketplaceProvider load: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSecondary() async {
    try {
      final results = await Future.wait([
        SupabaseService.fetchOrders(),
        SupabaseService.fetchProfiles(),
      ]).timeout(_networkTimeout);
      _orders = results[0] as List<Order>;
      _users = results[1] as List<AppUser>;
      notifyListeners();
    } catch (e) {
      debugPrint('MarketplaceProvider secondary load: $e');
    }
  }

  Future<void> refresh() => _loadData(waitForAll: true);

  Future<void> updateAdminPayments({
    required String evc,
    required String edahab,
    String? waafiMerchantUid,
    String? waafiApiUserId,
    String? waafiApiKey,
    bool? waafiAutoEnabled,
  }) async {
    await SupabaseService.setSetting('admin_evc', evc);
    await SupabaseService.setSetting('admin_edahab', edahab);
    if (waafiMerchantUid != null) await SupabaseService.setSetting('waafi_merchant_uid', waafiMerchantUid);
    if (waafiApiUserId != null) await SupabaseService.setSetting('waafi_api_user_id', waafiApiUserId);
    if (waafiApiKey != null) await SupabaseService.setSetting('waafi_api_key', waafiApiKey);
    if (waafiAutoEnabled != null) await SupabaseService.setSetting('waafi_auto_enabled', waafiAutoEnabled.toString());

    _adminEvc = evc;
    _adminEdahab = edahab;
    if (waafiMerchantUid != null) _waafiMerchantUid = waafiMerchantUid;
    if (waafiApiUserId != null) _waafiApiUserId = waafiApiUserId;
    if (waafiApiKey != null) _waafiApiKey = waafiApiKey;
    if (waafiAutoEnabled != null) _waafiAutoEnabled = waafiAutoEnabled;
    notifyListeners();
  }

  Future<void> addPromo(PromoBanner promo) async {
    await SupabaseService.upsertPromo(promo);
    _promos.add(promo);
    notifyListeners();

    await FeaturesService.createNotification(
      userId: 'all',
      title: 'Bannaanbax & Qiimo Dhimis! 🏷️',
      body: '${promo.tag}: ${promo.title.replaceAll('\n', ' ')}',
      type: 'promo',
      relatedId: promo.id,
    );
  }

  Future<void> removePromo(String id) async {
    await SupabaseService.deletePromo(id);
    _promos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> addCargoAd(CargoAd ad) async {
    await SupabaseService.upsertCargoAd(ad);
    _cargoAds.insert(0, ad);
    notifyListeners();
  }

  Future<void> removeCargoAd(String id) async {
    await SupabaseService.deleteCargoAd(id);
    _cargoAds.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // ── Categories ─────────────────────────────────────────────────────────────

  Future<void> addCategory(Category cat) async {
    await SupabaseService.upsertCategory(cat);
    _categories.add(cat);
    notifyListeners();
  }

  Future<void> updateCategory(Category cat) async {
    await SupabaseService.upsertCategory(cat);
    final idx = _categories.indexWhere((c) => c.id == cat.id);
    if (idx != -1) {
      _categories[idx] = cat;
    } else {
      _categories.add(cat);
    }
    notifyListeners();
  }

  Future<void> removeCategory(String id) async {
    await SupabaseService.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ── Property Listings ─────────────────────────────────────────────────────

  Future<void> addPropertyListing(PropertyListing listing) async {
    await SupabaseService.upsertPropertyListing(listing);
    _propertyListings.insert(0, listing);
    notifyListeners();
  }

  Future<void> removePropertyListing(String id) async {
    await SupabaseService.deletePropertyListing(id);
    _propertyListings.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> approvePropertyListing(String id) async {
    final idx = _propertyListings.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final updated = _propertyListings[idx].copyWith(isApproved: true);
    await SupabaseService.upsertPropertyListing(updated);
    _propertyListings[idx] = updated;
    notifyListeners();
  }

  /// Checks if a product belongs to a store that is marked as a restaurant.
  bool isRestaurantProduct(Product product) {
    final store = _stores.where((s) => s.id == product.storeId).firstOrNull;
    return store?.isRestaurant ?? false;
  }

  /// Returns approved products excluding restaurant food items (for main marketplace & New Arrivals).
  List<Product> get nonRestaurantProducts {
    final restaurantStoreIds = _stores.where((s) => s.isRestaurant).map((s) => s.id).toSet();
    return _products.where((p) => p.isApproved && !restaurantStoreIds.contains(p.storeId)).toList();
  }

  /// Total purchase count per product from active & past orders
  Map<String, int> get productPurchaseCounts {
    final counts = <String, int>{};
    for (var order in _orders) {
      for (var item in order.items) {
        counts[item.productId] = (counts[item.productId] ?? 0) + item.quantity;
      }
    }
    return counts;
  }

  /// Featured products: Products purchased 3+ times (or with highest purchase counts) automatically move to the VERY TOP!
  List<Product> get featuredProducts {
    final base = nonRestaurantProducts;
    final counts = productPurchaseCounts;

    final sorted = List<Product>.from(base);
    sorted.sort((a, b) {
      final countA = counts[a.id] ?? 0;
      final countB = counts[b.id] ?? 0;

      final isTopA = countA >= 3;
      final isTopB = countB >= 3;

      if (isTopA != isTopB) {
        return isTopA ? -1 : 1; // 3+ purchases come to the top
      }
      if (countA != countB) {
        return countB.compareTo(countA); // Higher sales next
      }
      return b.rating.compareTo(a.rating);
    });

    return sorted;
  }

  /// Returns food items from restaurant stores only.
  List<Product> get restaurantFoodProducts {
    final restaurantStoreIds = _stores.where((s) => s.isRestaurant).map((s) => s.id).toSet();
    return _products.where((p) => p.isApproved && restaurantStoreIds.contains(p.storeId)).toList();
  }

  List<PropertyListing> getPendingPropertyListings() =>
      _propertyListings.where((p) => !p.isApproved).toList();

  // ── Property Bookings ──────────────────────────────────────────────────────

  Future<void> addPropertyBooking(PropertyBooking booking) async {
    await SupabaseService.upsertPropertyBooking(booking);
    _propertyBookings.insert(0, booking);
    notifyListeners();
  }

  Future<void> approvePropertyBooking(String id) async {
    final idx = _propertyBookings.indexWhere((b) => b.id == id);
    if (idx == -1) return;
    final updated = _propertyBookings[idx].copyWith(status: BookingStatus.approved);
    await SupabaseService.upsertPropertyBooking(updated);
    _propertyBookings[idx] = updated;
    notifyListeners();
  }

  Future<void> completePropertyBookingPayment(String id) async {
    final idx = _propertyBookings.indexWhere((b) => b.id == id);
    if (idx == -1) return;
    final updated = _propertyBookings[idx].copyWith(
      status: BookingStatus.approved,
      isFullyPaid: true,
    );
    await SupabaseService.upsertPropertyBooking(updated);
    _propertyBookings[idx] = updated;
    notifyListeners();
  }

  Future<void> cancelPropertyBooking(String id) async {
    final idx = _propertyBookings.indexWhere((b) => b.id == id);
    if (idx == -1) return;
    final updated = _propertyBookings[idx].copyWith(status: BookingStatus.cancelled);
    await SupabaseService.upsertPropertyBooking(updated);
    _propertyBookings[idx] = updated;
    notifyListeners();
  }

  // ── Second Hand Items ──────────────────────────────────────────────────────

  Future<void> addSecondHandItem(SecondHandItem item) async {
    await SupabaseService.upsertSecondHandItem(item);
    _secondHandItems.insert(0, item);
    notifyListeners();
  }

  Future<void> approveSecondHandItem(String id) async {
    final idx = _secondHandItems.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final updated = _secondHandItems[idx].copyWith(status: SecondHandStatus.approved);
    await SupabaseService.upsertSecondHandItem(updated);
    _secondHandItems[idx] = updated;
    notifyListeners();
  }

  Future<void> rejectSecondHandItem(String id) async {
    final idx = _secondHandItems.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final updated = _secondHandItems[idx].copyWith(status: SecondHandStatus.rejected);
    await SupabaseService.upsertSecondHandItem(updated);
    _secondHandItems[idx] = updated;
    notifyListeners();
  }

  Future<void> markSecondHandSold(String id) async {
    final idx = _secondHandItems.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final updated = _secondHandItems[idx].copyWith(status: SecondHandStatus.sold);
    await SupabaseService.upsertSecondHandItem(updated);
    _secondHandItems[idx] = updated;
    notifyListeners();
  }

  Future<void> deleteSecondHandItem(String id) async {
    await SupabaseService.deleteSecondHandItem(id);
    _secondHandItems.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void addToCart(Product product, int quantity) {
    if (product.stock <= 0) return;
    if (!_cart.containsKey(product.storeId)) {
      _cart[product.storeId] = [];
    }
    final existingIndex =
        _cart[product.storeId]!.indexWhere((item) => item.productId == product.id);
    if (existingIndex != -1) {
      final existing = _cart[product.storeId]![existingIndex];
      int newQty = existing.quantity + quantity;
      if (newQty > product.stock) newQty = product.stock;
      _cart[product.storeId]![existingIndex] = OrderItem(
        productId: product.id,
        productName: product.name,
        price: product.priceWithFee,
        quantity: newQty,
        storeId: product.storeId,
        storeName: product.storeName,
        image: product.image,
      );
    } else {
      int newQty = quantity > product.stock ? product.stock : quantity;
      _cart[product.storeId]!.add(OrderItem(
        productId: product.id,
        productName: product.name,
        price: product.priceWithFee,
        quantity: newQty,
        storeId: product.storeId,
        storeName: product.storeName,
        image: product.image,
      ));
    }
    notifyListeners();
  }

  void updateCartQty(String storeId, String productId, int qty) {
    final idx = _cart[storeId]?.indexWhere((i) => i.productId == productId) ?? -1;
    if (idx == -1) return;
    if (qty <= 0) {
      removeFromCart(storeId, productId);
      return;
    }
    final item = _cart[storeId]![idx];
    
    // Check stock
    final pIdx = _products.indexWhere((p) => p.id == productId);
    if (pIdx != -1) {
      final product = _products[pIdx];
      if (qty > product.stock) qty = product.stock;
    }

    _cart[storeId]![idx] = OrderItem(
      productId: item.productId,
      productName: item.productName,
      price: item.price,
      quantity: qty,
      storeId: item.storeId,
      storeName: item.storeName,
      image: item.image,
    );
    notifyListeners();
  }

  double get cartTotal {
    double total = 0;
    _cart.forEach((_, items) {
      for (var item in items) {
        total += item.price * item.quantity;
      }
    });
    return total;
  }

  String _fulfillmentType = 'delivery'; // 'delivery' or 'pickup'
  String get fulfillmentType => _fulfillmentType;
  bool get isPickupFulfillment => _fulfillmentType == 'pickup';

  void setFulfillmentType(String type) {
    _fulfillmentType = type;
    notifyListeners();
  }

  /// Delivery fee rule: Free delivery if subtotal > $20.00, otherwise $1.30
  /// If Pickup is selected, delivery fee is always $0.00.
  double calculateDeliveryFee(double subtotal) {
    if (subtotal == 0) return 0.0;
    if (_fulfillmentType == 'pickup') return 0.0;
    return subtotal > 20.0 ? 0.0 : 1.30;
  }

  double get deliveryFee => calculateDeliveryFee(cartTotal);

  double get cartTotalWithDelivery => cartTotal + deliveryFee;

  void removeFromCart(String storeId, String productId) {
    if (_cart.containsKey(storeId)) {
      _cart[storeId]!.removeWhere((item) => item.productId == productId);
      if (_cart[storeId]!.isEmpty) _cart.remove(storeId);
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  /// Returns how many separate store orders were created.
  Future<int> placeOrder({
    required String userId,
    required PaymentMethod paymentMethod,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? deliveryType,
    bool isPaid = false,
  }) async {
    final finalDeliveryType = deliveryType ?? _fulfillmentType;
    var created = 0;
    for (var entry in _cart.entries) {
      final storeId = entry.key;
      final items = entry.value;
      double storeTotal = 0;
      for (var item in items) {
        storeTotal += item.price * item.quantity;
        
        // Jar stock-ga alaabta
        final pIdx = _products.indexWhere((p) => p.id == item.productId);
        if (pIdx != -1) {
          final p = _products[pIdx];
          int cusub = p.stock - item.quantity;
          if (cusub < 0) cusub = 0;
          final updatedProduct = p.copyWith(stock: cusub);
          SupabaseService.upsertProduct(updatedProduct);
          _products[pIdx] = updatedProduct;
        }
      }

      final isPickupOrder = finalDeliveryType == 'pickup';
      String formattedAddress = customerAddress ?? '';
      if (isPickupOrder && !formattedAddress.toUpperCase().contains('[PICKUP]')) {
        formattedAddress = '[PICKUP] $formattedAddress'.trim();
      }

      final order = Order(
        id: const Uuid().v4(),
        userId: userId,
        items: items,
        totalAmount: storeTotal,
        date: DateTime.now(),
        status: isPaid ? OrderStatus.paymentConfirmed : OrderStatus.pending,
        storeId: storeId,
        paymentMethod: paymentMethod,
        isPaid: isPaid,
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: formattedAddress,
        deliveryType: finalDeliveryType,
      );

      await SupabaseService.upsertOrder(order);
      _orders.insert(0, order);
      created++;
      try {
        await FeaturesService.createNotification(
          userId: userId,
          title: 'Dalab la gudbiyay',
          body: 'Dalab cusub dukaanka ${getStoreById(storeId)?.name ?? storeId}',
          type: 'order',
          relatedId: order.id,
        );
        final store = getStoreById(storeId);
        if (store != null) {
          await FeaturesService.createNotification(
            userId: store.ownerId,
            title: 'Dalab cusub!',
            body: 'Macmiil cusub ayaa dalbaday alaabtaada.',
            type: 'order',
            relatedId: order.id,
          );
        }
      } catch (e) {
        debugPrint('placeOrder notification creation error: $e');
      }
    }

    clearCart();
    _activeCoupon = null;
    notifyListeners();
    return created;
  }

  /// Allows a store/restaurant owner to manually create an order on behalf of a customer.
  Future<Order?> createDirectStoreOrder({
    required String storeId,
    required List<OrderItem> items,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required PaymentMethod paymentMethod,
    bool isPaid = true,
  }) async {
    try {
      double total = 0;
      for (var item in items) {
        total += item.price * item.quantity;
        final pIdx = _products.indexWhere((p) => p.id == item.productId);
        if (pIdx != -1) {
          final p = _products[pIdx];
          int cusub = p.stock - item.quantity;
          if (cusub < 0) cusub = 0;
          final updatedProduct = p.copyWith(stock: cusub);
          SupabaseService.upsertProduct(updatedProduct);
          _products[pIdx] = updatedProduct;
        }
      }

      final order = Order(
        id: const Uuid().v4(),
        userId: 'manual_customer',
        items: items,
        totalAmount: total,
        date: DateTime.now(),
        status: isPaid ? OrderStatus.approved : OrderStatus.pending,
        storeId: storeId,
        paymentMethod: paymentMethod,
        isPaid: isPaid,
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
      );

      await SupabaseService.upsertOrder(order);
      _orders.insert(0, order);
      notifyListeners();
      return order;
    } catch (e) {
      debugPrint('createDirectStoreOrder error: $e');
      return null;
    }
  }

  Future<void> confirmPayment(String orderId) async {
    await _updateOrder(orderId, status: OrderStatus.paymentConfirmed, isPaid: true);
  }

  Future<void> approveOrder(String orderId, {String? deliveryPersonId}) async {
    await _updateOrder(
      orderId,
      status: OrderStatus.approved,
      deliveryPersonId: deliveryPersonId,
    );
  }

  /// Returns error message if pickup failed or order already claimed by another driver.
  Future<String?> markPickedUp(String orderId, {String? deliveryPersonId}) async {
    try {
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        final existing = _orders[idx];
        if (existing.isPickup && existing.deliveryPersonId != deliveryPersonId) {
          return 'Dalabkan waa PICKUP. Waxaa qaadi kara oo kaliya wadaha uu Admin-ku toos u xilsaaray.';
        }
        if (existing.status == OrderStatus.pending) {
          return 'Dalabkan weli Admin-ka ama nidaamku ma ansixin (Pending).';
        }
        if (existing.deliveryPersonId != null &&
            existing.deliveryPersonId != deliveryPersonId) {
          return 'Dalabkan waxaa hore u qaaday wadaha kale!';
        }
      }

      await _updateOrder(
        orderId,
        status: OrderStatus.outForDelivery,
        pickedUpAt: DateTime.now(),
        deliveryPersonId: deliveryPersonId,
      );
      return null;
    } catch (e) {
      debugPrint('markPickedUp: $e');
      return 'Qaadista waa fashilantay: $e';
    }
  }

  Future<String?> unassignDeliveryDriver(String orderId) async {
    try {
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx == -1) return 'Dalabka lama helin';

      final old = _orders[idx];
      final driver = old.deliveryPersonId != null
          ? _users.where((u) => u.id == old.deliveryPersonId).firstOrNull
          : null;
      final driverName = driver?.name ?? 'Delivery Driver';

      final updated = Order(
        id: old.id,
        userId: old.userId,
        items: old.items,
        totalAmount: old.totalAmount,
        date: old.date,
        status: OrderStatus.approved,
        storeId: old.storeId,
        paymentMethod: old.paymentMethod,
        isPaid: old.isPaid,
        customerName: old.customerName,
        customerPhone: old.customerPhone,
        customerAddress: old.customerAddress,
        deliveryType: old.deliveryType,
        deliveryPersonId: null,
        pickedUpAt: null,
        deliveredAt: null,
        canceledByDriverId: old.deliveryPersonId,
        canceledByDriverName: driverName,
      );
      await SupabaseService.upsertOrder(updated);
      _orders[idx] = updated;
      notifyListeners();

      // Notify Admin
      await FeaturesService.createNotification(
        userId: 'admin',
        title: 'Driver ayaa kansalay gaarsiinta ⚠️',
        body: 'Wadaha $driverName wuxuu fasaxay dalabka #${old.id.substring(0, 8)}',
        type: 'delivery',
        relatedId: old.id,
      );

      // Notify Customer
      await FeaturesService.createNotification(
        userId: old.userId,
        title: 'Gaarsiinta waa la fasaxay 🚚',
        body: 'Wadaha delivery-ga wuxuu fasaxay dalabkaaga. Wadayaal kale ayaa loo xilsaari doonaa.',
        type: 'order',
        relatedId: old.id,
      );
      return null;
    } catch (e) {
      debugPrint('unassignDeliveryDriver error: $e');
      return 'Kansalaada waa fashilantay: $e';
    }
  }

  /// Returns error message if delivery confirm failed.
  Future<String?> markDelivered(String orderId) async {
    try {
      await _updateOrder(
        orderId,
        status: OrderStatus.delivered,
        deliveredAt: DateTime.now(),
      );
      return null;
    } catch (e) {
      debugPrint('markDelivered: $e');
      return 'Xaqiijinta waa fashilantay: $e';
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await _updateOrder(orderId, status: OrderStatus.cancelled);
  }

  Future<void> _updateOrder(
    String orderId, {
    OrderStatus? status,
    bool? isPaid,
    String? deliveryPersonId,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
  }) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) {
      throw Exception('Dalabka lama helin ($orderId)');
    }

    final old = _orders[idx];
    final updated = old.copyWith(
      status: status,
      isPaid: isPaid,
      deliveryPersonId: deliveryPersonId,
      pickedUpAt: pickedUpAt,
      deliveredAt: deliveredAt,
    );
    await SupabaseService.upsertOrder(updated);
    _orders[idx] = updated;
    notifyListeners();

    if (status != null) {
      try {
        await _notifyOrderStatusChange(updated, status);
      } catch (e) {
        debugPrint('_notifyOrderStatusChange: $e');
      }
    }
  }

  Future<void> _notifyOrderStatusChange(Order order, OrderStatus status) async {
    String? driverInfo;
    if (order.deliveryPersonId != null && order.deliveryPersonId!.isNotEmpty) {
      final driver = _users.where((u) => u.id == order.deliveryPersonId).firstOrNull;
      if (driver != null) {
        final phone = (driver.phone != null && driver.phone!.isNotEmpty) ? driver.phone : 'N/A';
        driverInfo = 'Wadaha: ${driver.name} (Tel: $phone)';
      }
    }

    final labels = {
      OrderStatus.paymentConfirmed: (
        'Lacag la xaqiijiyay ✅',
        'Dalabkaaga waa la xaqiijiyay. Dukaanka ayaa baaraya.'
      ),
      OrderStatus.approved: (
        'Dalabkaaga waa la aqbalay! ✅',
        driverInfo != null
          ? 'Dukaanku wuxuu aqbalay dalabkaaga. $driverInfo wuxuu idiin sidaa alaabta.'
          : 'Dukaanku wuxuu aqbalay dalabkaaga. Hadda waxaa loo diyaarinayaa gaarsiin.'
      ),
      OrderStatus.outForDelivery: (
        'Waa la soo qaaday! 🚚',
        driverInfo != null
          ? 'Alaabtaada waa la soo qaaday. $driverInfo waa uu ku soo socdaa.'
          : 'Alaabtaada waa la soo qaaday, wadayaasha ayaa ku soo socda.'
      ),
      OrderStatus.delivered: (
        'La gaarsiiyay 📦',
        'Dalabkaaga waa la gaarsiiyay! Waad ku mahadsan tahay EMARA.'
      ),
      OrderStatus.cancelled: (
        'La joojiyay ❌',
        'Dalabkaaga waa la joojiyay. Waxaad kala xariiri kartaa support-ka.'
      ),
    };

    final msg = labels[status];
    if (msg != null) {
      await FeaturesService.createNotification(
        userId: order.userId,
        title: msg.$1,
        body: msg.$2,
        type: 'order',
        relatedId: order.id,
      );
    }

    if (status == OrderStatus.approved && order.deliveryPersonId != null) {
      await FeaturesService.createNotification(
        userId: order.deliveryPersonId!,
        title: 'Dalab cusub oo loo xilsaaray 🚚',
        body: 'Waxaa loo xilsaaray dalab #${order.id.substring(0, 8)}. Fadlan aad dukaanka si aad u soo qaaddo.',
        type: 'delivery',
        relatedId: order.id,
      );
    }
  }

  Future<void> registerStore(Store store) async {
    await SupabaseService.upsertStore(store);
    _stores = await SupabaseService.fetchStores();
    notifyListeners();
  }

  Future<void> updateStorePaymentNumbers(
    String storeId, {
    String? evc,
    String? edahab,
  }) async {
    final store = getStoreById(storeId);
    if (store == null) return;
    final updated = Store(
      id: store.id,
      name: store.name,
      logo: store.logo,
      banner: store.banner,
      description: store.description,
      contact: store.contact,
      ownerId: store.ownerId,
      isApproved: store.isApproved,
      rating: store.rating,
      followers: store.followers,
      evcNumber: evc ?? store.evcNumber,
      edahabNumber: edahab ?? store.edahabNumber,
    );
    await SupabaseService.upsertStore(updated);
    _stores = await SupabaseService.fetchStores();
    notifyListeners();
  }

  Future<void> approveStore(String storeId) async {
    final store = getStoreById(storeId);
    if (store == null) return;
    final approved = Store(
      id: store.id,
      name: store.name,
      logo: store.logo,
      banner: store.banner,
      description: store.description,
      contact: store.contact,
      ownerId: store.ownerId,
      isApproved: true,
      rating: store.rating,
      followers: store.followers,
      evcNumber: store.evcNumber,
      edahabNumber: store.edahabNumber,
    );
    await SupabaseService.upsertStore(approved);
    _stores = await SupabaseService.fetchStores();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await SupabaseService.upsertProduct(product);
    _products = await SupabaseService.fetchProducts();
    notifyListeners();

    if (product.hasDiscount || (product.originalPrice != null && product.originalPrice! > product.price)) {
      final pct = product.discountPercent > 0 ? '${product.discountPercent}%' : 'dhimis';
      await FeaturesService.createNotification(
        userId: 'all',
        title: 'Qiimo Dhimis Cusub! 🎉🏷️',
        body: 'Dukaanka "${product.storeName}" wuxuu sameeyay qiimo dhimis $pct ah oo ku saabsan alaabta "${product.name}"!',
        type: 'promo',
        relatedId: product.id,
      );
    }
  }

  Future<void> updateProduct(Product product) async {
    await SupabaseService.upsertProduct(product);
    _products = await SupabaseService.fetchProducts();
    notifyListeners();

    if (product.hasDiscount || (product.originalPrice != null && product.originalPrice! > product.price)) {
      final pct = product.discountPercent > 0 ? '${product.discountPercent}%' : 'dhimis';
      await FeaturesService.createNotification(
        userId: 'all',
        title: 'Qiimo Dhimis Cusub! 🎉🏷️',
        body: 'Dukaanka "${product.storeName}" wuxuu sameeyay qiimo dhimis $pct ah oo ku saabsan alaabta "${product.name}"!',
        type: 'promo',
        relatedId: product.id,
      );
    }
  }

  Future<void> approveProduct(String productId) async {
    Product? p;
    for (final x in _products) {
      if (x.id == productId) {
        p = x;
        break;
      }
    }
    if (p == null) return;
    final updated = Product(
      id: p.id,
      name: p.name,
      description: p.description,
      price: p.price,
      image: p.image,
      categoryId: p.categoryId,
      storeId: p.storeId,
      storeName: p.storeName,
      rating: p.rating,
      stock: p.stock,
      isApproved: true,
      gallery: p.gallery,
      videoUrl: p.videoUrl,
      sizes: p.sizes,
      colors: p.colors,
      originalPrice: p.originalPrice,
    );
    await SupabaseService.upsertProduct(updated);
    _products = await SupabaseService.fetchProducts();
    notifyListeners();

    if (p.hasDiscount || (p.originalPrice != null && p.originalPrice! > p.price)) {
      final pct = p.discountPercent > 0 ? '${p.discountPercent}%' : 'dhimis';
      await FeaturesService.createNotification(
        userId: 'all',
        title: 'Qiimo Dhimis Cusub! 🎉🏷️',
        body: 'Dukaanka "${p.storeName}" wuxuu sameeyay qiimo dhimis $pct ah oo ku saabsan alaabta "${p.name}"!',
        type: 'promo',
        relatedId: p.id,
      );
    }
  }

  Future<void> refreshUsers() async {
    _users = await SupabaseService.fetchProfiles();
    notifyListeners();
  }

  Future<void> registerUser(AppUser user) async {
    await SupabaseService.upsertProfile(user);
    _users = await SupabaseService.fetchProfiles();
    notifyListeners();
  }

  List<Product> getProductsByStore(String storeId) =>
      _products.where((p) => p.storeId == storeId).toList();

  List<Product> getApprovedProductsByStore(String storeId) =>
      _products.where((p) => p.storeId == storeId && p.isApproved && p.stock > 0).toList();

  List<Product> getPendingProducts() =>
      _products.where((p) => !p.isApproved).toList();

  List<Order> getOrdersByStore(String storeId) =>
      _orders.where((o) => o.storeId == storeId).toList();

  List<Order> getOrdersByUser(String userId) =>
      _orders.where((o) => o.userId == userId).toList();

  List<Order> getOrdersByDelivery(String deliveryPersonId) =>
      _orders.where((o) => o.deliveryPersonId == deliveryPersonId).toList();

  Future<void> assignDeliveryDriver(String orderId, String driverId) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final old = _orders[idx];
    final updated = old.copyWith(
      deliveryPersonId: driverId,
      status: old.status == OrderStatus.pending || old.status == OrderStatus.paymentConfirmed
          ? OrderStatus.approved
          : old.status,
    );
    await SupabaseService.upsertOrder(updated);
    _orders[idx] = updated;
    notifyListeners();

    final driver = getUserById(driverId);
    final driverName = driver?.name ?? 'Delivery Driver';
    final driverPhone = (driver?.phone != null && driver!.phone!.isNotEmpty) ? driver.phone : 'N/A';

    // Notify Driver
    await FeaturesService.createNotification(
      userId: driverId,
      title: 'Dalab cusub oo loo xilsaaray 🚚',
      body: 'Admin-ka ayaa kuusoo aadiyay dalabka #${old.id.substring(0, 8)}. Fadlan taabo "Qaado alaabta".',
      type: 'delivery',
      relatedId: old.id,
    );

    // Notify Customer with Driver Name & Phone Number
    await FeaturesService.createNotification(
      userId: old.userId,
      title: 'Wadaa Delivery ayaa loo xilsaaray 🛵',
      body: 'Wadaha $driverName (Tel: $driverPhone) ayaa loo xilsaaray gaarsiinta dalabkaaga #${old.id.substring(0, 8)}.',
      type: 'order',
      relatedId: old.id,
    );
  }

  /// Assigned directly to this driver by Admin (whether delivery or pickup explicitly assigned by Admin).
  List<Order> getAssignedDeliveries(String deliveryPersonId) => _orders
      .where((o) =>
          o.deliveryPersonId == deliveryPersonId &&
          (o.status == OrderStatus.approved || o.status == OrderStatus.paymentConfirmed))
      .toList();

  /// Open pool for drivers: active delivery orders (not pickup, no driver assigned yet, MUST be approved or payment confirmed).
  List<Order> getUnassignedApprovedOrders() => _orders
      .where((o) =>
          !o.isPickup &&
          o.deliveryPersonId == null &&
          (o.status == OrderStatus.approved || o.status == OrderStatus.paymentConfirmed))
      .toList();

  List<Order> getPendingOrders() =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();

  List<Order> getApprovedOrders() =>
      _orders.where((o) => o.status == OrderStatus.approved).toList();

  List<AppUser> getDeliveryPersons() =>
      _users.where((u) => u.role == UserRole.delivery).toList();

  List<AppUser> getSellers() =>
      _users.where((u) => u.role == UserRole.seller).toList();

  /// Net revenue for seller (original base price excluding 7% admin fee)
  double revenueForStore(String storeId) => _orders
      .where((o) => o.storeId == storeId && o.isPaid)
      .fold(0.0, (sum, o) => sum + (o.totalAmount / 1.07));

  /// Gross total collected from customers for store items (including 7% fee)
  double grossRevenueForStore(String storeId) => _orders
      .where((o) => o.storeId == storeId && o.isPaid)
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  /// Total 7% admin fee earned from this store
  double adminCommissionForStore(String storeId) => _orders
      .where((o) => o.storeId == storeId && o.isPaid)
      .fold(0.0, (sum, o) => sum + (o.totalAmount - (o.totalAmount / 1.07)));

  Store? getStoreById(String storeId) {
    try {
      return _stores.firstWhere((s) => s.id == storeId);
    } catch (_) {
      return null;
    }
  }

  AppUser? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  List<Product> searchProducts(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.storeName.toLowerCase().contains(q))
        .toList();
  }

  List<Store> searchStores(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return stores.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  // ── Wishlist ───────────────────────────────────────────────────────────────

  Future<void> loadWishlist(String userId) async {
    _wishlistIds
      ..clear()
      ..addAll(await FeaturesService.fetchWishlistProductIds(userId));
    notifyListeners();
  }

  bool isInWishlist(String productId) => _wishlistIds.contains(productId);

  List<Product> get wishlistProducts =>
      _products.where((p) => _wishlistIds.contains(p.id)).toList();

  Future<void> toggleWishlist(String userId, String productId) async {
    if (_wishlistIds.contains(productId)) {
      await FeaturesService.removeFromWishlist(userId, productId);
      _wishlistIds.remove(productId);
    } else {
      await FeaturesService.addToWishlist(userId, productId);
      _wishlistIds.add(productId);
    }
    notifyListeners();
  }

  // ── Coupons ────────────────────────────────────────────────────────────────

  Future<String?> applyCouponCode(String code, double cartTotal) async {
    final c = await FeaturesService.findCoupon(code);
    if (c == null) return 'Koodhka ma saxna';
    _activeCoupon = c;
    notifyListeners();
    return null;
  }

  void clearCoupon() {
    _activeCoupon = null;
    notifyListeners();
  }

  double discountedTotal(double total) =>
      _activeCoupon?.applyDiscount(total) ?? total;

  // ── Reviews ────────────────────────────────────────────────────────────────

  Future<void> submitReview({
    required String productId,
    required String userId,
    required int rating,
    String comment = '',
  }) async {
    await FeaturesService.addReview(
      productId: productId,
      userId: userId,
      rating: rating,
      comment: comment,
    );
    _products = await SupabaseService.fetchProducts();
    notifyListeners();
  }

  // ── Admin: ban / coupons / export ──────────────────────────────────────────

  Future<void> setUserBanned(String userId, bool banned) async {
    await FeaturesService.setProfileBanned(userId, banned);
    _users = await SupabaseService.fetchProfiles();
    notifyListeners();
  }

  Future<void> setStoreBannedFlag(String storeId, bool banned) async {
    await FeaturesService.setStoreBanned(storeId, banned);
    _stores = await SupabaseService.fetchStores();
    notifyListeners();
  }

  Future<List<Coupon>> fetchCoupons() => FeaturesService.fetchCoupons();

  Future<void> saveCoupon(Coupon coupon) async {
    await FeaturesService.upsertCoupon(coupon);
    notifyListeners();
  }

  Future<void> deleteCoupon(String id) async {
    await FeaturesService.deleteCoupon(id);
    notifyListeners();
  }

  String exportOrdersCsv() {
    final buf = StringBuffer('id,user_id,store_id,total,status,date\n');
    for (final o in _orders) {
      buf.writeln(
          '${o.id},${o.userId},${o.storeId},${o.totalAmount},${o.status.name},${o.date.toIso8601String()}');
    }
    return buf.toString();
  }

  /// Revenue per day last 7 days for a store (seller stats).
  Map<String, double> storeRevenueLast7Days(String storeId) {
    final map = <String, double>{};
    final now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final key = '${d.day}/${d.month}';
      map[key] = 0;
    }
    for (final o in _orders.where((o) => o.storeId == storeId && o.isPaid)) {
      final d = DateTime(o.date.year, o.date.month, o.date.day);
      final key = '${d.day}/${d.month}';
      if (map.containsKey(key)) map[key] = (map[key] ?? 0) + (o.totalAmount / 1.07);
    }
    return map;
  }

  List<Product> lowStockProducts(String storeId, {int threshold = 5}) =>
      _products
          .where((p) => p.storeId == storeId && p.stock <= threshold)
          .toList();
}
