import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../blocs/vendor/vendor_bloc.dart';
import '../../blocs/vendor/vendor_event.dart';
import '../../blocs/vendor/vendor_state.dart';
import '../../models/vendor_model.dart';

class VendorFormScreen extends StatefulWidget {
  final String userId;

  const VendorFormScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<VendorFormScreen> createState() => _VendorFormScreenState();
}

class _VendorFormScreenState extends State<VendorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final Map<String, dynamic> _formData = {};
  List<File> _images = [];



  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  void _submitForm() async {
    debugPrint('Submit button pressed');

    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    _formKey.currentState!.save();

    String? imageUrl;

    // If an image URL is provided manually, use it
    final manualImageUrl = _formData['image_url'];
    if (manualImageUrl != null && manualImageUrl.isNotEmpty) {
      imageUrl = manualImageUrl;
    }

    final vendorData = VendorModel(
      id: '',
      userId: widget.userId,
      businessName: _formData['business_name'] ?? '',
      contactPhone: _formData['contact_phone'] ?? '',
      category: _selectedCategory!,
      price: double.tryParse(_formData['price'] ?? '') ?? 0.0,
      quantity: int.tryParse(_formData['quantity'] ?? '') ?? 0,
      description: _formData['description'] ?? '',
      city: _formData['city'] ?? '',
      address: _formData['address'] ?? '',
      email: _formData['email'],
      contactName: _formData['contact_name'],
      venueName: _formData['venue_name'],
      foodType: _formData['food_type'],
      decorType: _formData['decor_type'],
      venueType: _formData['venue_type'],
      imageUrl: imageUrl ?? '', // Store the image URL (manual or empty string)
      timestamp: DateTime.now(),
    );

    try {

      context.read<VendorBloc>().add(AddVendorPostEvent(vendorData));


    //  debugPrint('Vendor added successfully: ${docRef.id}');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading vendor: $error')),
      );
      debugPrint('Error uploading vendor: $error');
    }
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
          _textField('image_url', isRequired: false),  // Optional image URL field
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
          _textField('image_url', isRequired: false),  // Optional image URL field
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
          _textField('image_url', isRequired: false),  // Optional image URL field
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _textField(String field,
      {TextInputType keyboardType = TextInputType.text, bool isRequired = true}) {
    final isDescription = field == 'description';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: field.replaceAll('_', ' ').toUpperCase(),
          border: OutlineInputBorder(),
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


  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _images.clear();
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Upload Your Service')),
      body: BlocListener<VendorBloc, VendorState>(
        listener: (context, state) {
          if (state is VendorSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            _resetForm();
          } else if (state is VendorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
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
                      validator: (value) =>
                      value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 10),
                    _buildDynamicFields(),
                    const SizedBox(height: 20),
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
                      icon: const Icon(Icons.upload),
                      label: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
