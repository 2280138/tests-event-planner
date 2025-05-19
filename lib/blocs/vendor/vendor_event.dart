import 'package:equatable/equatable.dart';
import '../../models/vendor_model.dart';



abstract class VendorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Existing events
class LoadVendorPosts extends VendorEvent {
  @override
  List<Object?> get props => [];
}

class DeleteVendorPost extends VendorEvent {
  final String postId;

  DeleteVendorPost(this.postId);

  @override
  List<Object?> get props => [postId];
}

class UpdateVendorPost extends VendorEvent {
  final String postId;
  final Map<String, dynamic> updatedData;

  UpdateVendorPost({required this.postId, required this.updatedData});

  @override
  List<Object?> get props => [postId, updatedData];
}

// New event: Load vendor items by user ID
class LoadVendorItemsByUserEvent extends VendorEvent {
  final String userId;

  LoadVendorItemsByUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Existing event: Load vendors by category (used in Organizer view)
class LoadVendorsByCategoryEvent extends VendorEvent {
  final String category;

  LoadVendorsByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}


// Add this new event at the bottom or appropriate place
class AddVendorPostEvent extends VendorEvent {
  final VendorModel vendor;

  AddVendorPostEvent(this.vendor);
}

class UpdateVendorPostEvent extends VendorEvent {
  final String vendorId;
  final Map<String, dynamic> updatedData;

  UpdateVendorPostEvent({required this.vendorId, required this.updatedData});
}

