import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/features_service.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/product.dart';
import '../../models/store.dart';

class AddProductView extends StatefulWidget {
  final Store store;
  const AddProductView({super.key, required this.store});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _stockController = TextEditingController();
  final _sizesController = TextEditingController();
  final _colorsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategoryId;
  final List<File> _pickedImages = [];

  Future<void> _pickImage() async {
    if (_pickedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ugu badnaan 4 sawir ayaad dooran kartaa')),
      );
      return;
    }
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) {
      setState(() => _pickedImages.add(File(x.path)));
    }
  }

  bool get _isClothing {
    if (_selectedCategoryId == null) return false;
    final market = Provider.of<MarketplaceProvider>(context, listen: false);
    final cat = market.categories.where((c) => c.id == _selectedCategoryId).firstOrNull;
    if (cat == null) return false;
    final n = cat.name.toLowerCase();
    return n.contains('dhar') || n.contains('clothing') || n.contains('kab') || n.contains('shoe');
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final market = Provider.of<MarketplaceProvider>(context, listen: false);
      final productId = const Uuid().v4();
      final List<String> imageUrls = [];

      var manualUrl = _imageController.text.trim();
      if (manualUrl.isNotEmpty) {
        imageUrls.add(manualUrl);
      }

      if (_pickedImages.isNotEmpty) {
        for (var imageFile in _pickedImages) {
          final uploaded = await FeaturesService.uploadProductImage(imageFile, productId);
          if (uploaded != null) {
            imageUrls.add(uploaded);
          }
        }
      }

      if (imageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sawir URL ama gallery dooro')),
        );
        return;
      }

      final sizes = _sizesController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      final colors = _colorsController.text.split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();

      final product = Product(
        id: productId,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text),
        image: imageUrls.first,
        gallery: imageUrls,
        categoryId: _selectedCategoryId!,
        storeId: widget.store.id,
        storeName: widget.store.name,
        stock: int.parse(_stockController.text),
        rating: 0.0,
        isApproved: false,
        sizes: _isClothing ? sizes : [],
        colors: _isClothing ? colors : [],
      );

      await market.addProduct(product);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.hourglass_top_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text("Product submitted! Waiting for admin approval.",
                style: TextStyle(fontWeight: FontWeight.w700))),
            ]),
            backgroundColor: const Color(0xFFFFB800),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add New Product", style: TextStyle(fontWeight: FontWeight.w900)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: "Product Name",
                hint: "E.g. Wireless Headphones",
                prefixIcon: Icons.shopping_bag_outlined,
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: "Description",
                hint: "Details about the product...",
                prefixIcon: Icons.description_outlined,
                controller: _descController,
                validator: (v) => v == null || v.isEmpty ? "Description is required" : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: "Price (\$)",
                      hint: "99.00",
                      prefixIcon: Icons.attach_money_rounded,
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || double.tryParse(v) == null ? "Valid price required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: "Stock",
                      hint: "10",
                      prefixIcon: Icons.inventory_2_outlined,
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || int.tryParse(v) == null ? "Valid stock required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Sawirrada Alaabta (Ugu badnaan 4)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 10),
              if (_pickedImages.isNotEmpty)
                Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _pickedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              image: DecorationImage(
                                image: FileImage(_pickedImages[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 16,
                            child: GestureDetector(
                              onTap: () => setState(() => _pickedImages.removeAt(index)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              if (_pickedImages.length < 4)
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_rounded),
                  label: Text('Soo geli sawir (${_pickedImages.length}/4)'),
                ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Image URL (optional)",
                hint: "https://example.com/image.jpg",
                prefixIcon: Icons.image_outlined,
                controller: _imageController,
              ),
              const SizedBox(height: 20),
              const Text("Category", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF374151))),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoryId,
                    hint: const Text("Select Category"),
                    isExpanded: true,
                    items: market.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                  ),
                ),
              ),
              if (_isClothing) ...[
                const SizedBox(height: 20),
                CustomTextField(
                  label: "Sizes (comma separated)",
                  hint: "S, M, L, XL",
                  prefixIcon: Icons.straighten_rounded,
                  controller: _sizesController,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: "Colors (comma separated)",
                  hint: "Red, Blue, Black",
                  prefixIcon: Icons.color_lens_outlined,
                  controller: _colorsController,
                ),
              ],
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _handleSubmit,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFD84315)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: const Center(
                    child: Text("Publish Product", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
