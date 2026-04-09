import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/auction_model.dart';

class CreateAuctionScreen extends StatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  State<CreateAuctionScreen> createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _selectedCategory = 'Electronics';
  String _selectedDuration = '24 hours';
  bool _isSaving = false;

  final List<String> _categories = ['Electronics', 'Jewelry', 'Watches', 'Furniture', 'Art', 'Sports', 'Cars'];
  final List<String> _durations = ['12 hours', '24 hours', '3 days', '7 days'];
  final Map<String, String> _emojis = {
    'Electronics': '💻', 'Jewelry': '💍', 'Watches': '⌚',
    'Furniture': '🪑', 'Art': '🎨', 'Sports': '⚽', 'Cars': '🚗'
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final auction = Auction(
      title: _titleCtrl.text.trim(),
      category: _selectedCategory,
      description: _descCtrl.text.trim(),
      startingPrice: double.parse(_priceCtrl.text),
      currentBid: double.parse(_priceCtrl.text),
      endTime: _selectedDuration,
      sellerName: 'Arsh',
      emoji: _emojis[_selectedCategory] ?? '📦',
    );

    await DatabaseHelper.instance.insertAuction(auction);
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isSaving = false);
      _titleCtrl.clear();
      _descCtrl.clear();
      _priceCtrl.clear();
      _locationCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auction posted successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Auction', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo upload placeholder
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      const Text('Tap to upload photo',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _label('Item Title'),
              TextFormField(
                controller: _titleCtrl,
                decoration: _decor('e.g. Vintage Rolex Watch'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),

              _label('Category'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _decor('Select category'),
                items: _categories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${_emojis[c]} $c'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 14),

              _label('Starting Price (\$)'),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: _decor('e.g. 100'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Price is required';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  if (double.parse(v) <= 0) return 'Price must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _label('Auction Duration'),
              DropdownButtonFormField<String>(
                value: _selectedDuration,
                decoration: _decor('Select duration'),
                items: _durations
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDuration = v!),
              ),
              const SizedBox(height: 14),

              _label('Location (City)'),
              TextFormField(
                controller: _locationCtrl,
                decoration: _decor('e.g. Kitchener, ON'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Location is required' : null,
              ),
              const SizedBox(height: 14),

              _label('Description'),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: _decor('Describe your item...'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Description is required';
                  if (v.trim().length < 20) return 'Description must be at least 20 characters';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.upload),
                  label: Text(_isSaving ? 'Posting...' : 'Post Auction',
                      style: const TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _decor(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
