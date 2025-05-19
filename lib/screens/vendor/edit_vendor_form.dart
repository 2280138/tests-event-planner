import 'dart:io';
import 'package:event_app/screens/vendor/vendor_items_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/vendor/vendor_bloc.dart';
import '../../blocs/vendor/vendor_event.dart';
import '../../blocs/vendor/vendor_state.dart';
import '../../models/vendor_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorEditFormScreen extends StatefulWidget {
  final VendorModel vendor;

  const VendorEditFormScreen({Key? key, required this.vendor}) : super(key: key);

  @override
  State<VendorEditFormScreen> createState() => _VendorEditFormScreenState();
}

class _VendorEditFormScreenState extends State<VendorEditFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String? _selectedCategory;
  late Map<String, dynamic> _formData;
  List<File> _images = [];

  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.vendor.category;
    _formData = {
      'business_name': widget.vendor.businessName,
      'contact_phone': widget.vendor.contactPhone,
      'category': widget.vendor.category,
      'price': widget.vendor.price.toString(),
      'quantity': widget.vendor.quantity.toString(),
      'description': widget.vendor.description,
      'city': widget.vendor.city,
      'address': widget.vendor.address,
      'email': widget.vendor.email ?? '',
      'contact_name': widget.vendor.contactName ?? '',
      'venue_name': widget.vendor.venueName ?? '',
      'food_type': widget.vendor.foodType ?? '',
      'decor_type': widget.vendor.decorType ?? '',
      'venue_type': widget.vendor.venueType ?? '',
      'image_url': widget.vendor.imageUrl,
    };
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    _formKey.currentState!.save();

    final updatedVendor = widget.vendor.copyWith(
      businessName: _formData['business_name'],
      contactPhone: _formData['contact_phone'],
      category: _selectedCategory!,
      price: double.tryParse(_formData['price'] ?? '') ?? 0.0,
      quantity: int.tryParse(_formData['quantity'] ?? '') ?? 0,
      description: _formData['description'],
      city: _formData['city'],
      address: _formData['address'],
      email: _formData['email'],
      contactName: _formData['contact_name'],
      venueName: _formData['venue_name'],
      foodType: _formData['food_type'],
      decorType: _formData['decor_type'],
      venueType: _formData['venue_type'],
      imageUrl: _formData['image_url'],
    );

    context.read<VendorBloc>().add(
      UpdateVendorPostEvent(
        vendorId: widget.vendor.id,
        updatedData: updatedVendor.toMap(),
      ),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Changes saved successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Just close the dialog, no navigation
            },
            child: const Text('OK'),
          ),

        ],
      ),
    );
  }

  Widget _textField(String field,
      {TextInputType keyboardType = TextInputType.text, bool isRequired = true}) {
    final isDescription = field == 'description';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: _formData[field] ?? '',
        decoration: InputDecoration(
          labelText: field.replaceAll('_', ' ').toUpperCase(),
          border: const OutlineInputBorder(),
          alignLabelWithHint: isDescription,
        ),
        keyboardType: isDescription ? TextInputType.multiline : keyboardType,
        minLines: isDescription ? 3 : 1,
        maxLines: isDescription ? null : 1,
        onSaved: (value) => _formData[field] = value?.trim() ?? '',
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDynamicFields() {
    switch (_selectedCategory) {
      case 'Venue':
        return Column(children: [
          _textField('venue_name'),
          _textField('venue_type'),
          _textField('description'),
          _textField('address'),
          _textField('city'),
          _textField('price', keyboardType: TextInputType.number),
          _textField('quantity', keyboardType: TextInputType.number),
          _textField('contact_name'),
          _textField('contact_phone', keyboardType: TextInputType.phone),
          _textField('email'),
          _textField('image_url', isRequired: false),
        ]);
      case 'Decor':
        return Column(children: [
          _textField('business_name'),
          _textField('decor_type'),
          _textField('description'),
          _textField('city'),
          _textField('price', keyboardType: TextInputType.number),
          _textField('quantity', keyboardType: TextInputType.number),
          _textField('contact_name'),
          _textField('contact_phone', keyboardType: TextInputType.phone),
          _textField('address'),
          _textField('email'),
          _textField('image_url', isRequired: false),
        ]);
      case 'Food':
        return Column(children: [
          _textField('business_name'),
          _textField('food_type'),
          _textField('description'),
          _textField('city'),
          _textField('price', keyboardType: TextInputType.number),
          _textField('quantity', keyboardType: TextInputType.number),
          _textField('contact_name'),
          _textField('contact_phone', keyboardType: TextInputType.phone),
          _textField('email'),
          _textField('address'),
          _textField('image_url', isRequired: false),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Your Service')),
      body: BlocListener<VendorBloc, VendorState>(
        listener: (context, state) {
          if (state is VendorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Select Category'),
                  items: const [
                    DropdownMenuItem(value: 'Venue', child: Text('Venue')),
                    DropdownMenuItem(value: 'Decor', child: Text('Decor')),
                    DropdownMenuItem(value: 'Food', child: Text('Food')),
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
                const SizedBox(height: 10),
                _buildDynamicFields(),
                // const SizedBox(height: 20),
                // ElevatedButton.icon(
                //   onPressed: _pickImages,
                //   icon: const Icon(Icons.image),
                //   label: const Text('Select Images'),
                // ),
                const SizedBox(height: 10),
                if (_images.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _images
                          .map((file) => Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.file(file, width: 100, fit: BoxFit.cover),
                      ))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
