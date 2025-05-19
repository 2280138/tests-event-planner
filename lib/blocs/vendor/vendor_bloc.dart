import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/vendor_model.dart';
import '../../repositories/vendor_repository.dart';
import 'vendor_event.dart';
import 'vendor_state.dart';

class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final VendorRepository vendorRepository;

  VendorBloc({required this.vendorRepository}) : super(VendorLoading()) {
    on<LoadVendorsByCategoryEvent>(_onLoadVendorsByCategory);
    on<LoadVendorItemsByUserEvent>(_onLoadVendorItemsByUser);
    on<AddVendorPostEvent>(_onAddVendorPost);
    on<UpdateVendorPostEvent>(_onUpdateVendorPost); // ✅ Added Update event
  }

  // ✅ Load vendors by category
  Future<void> _onLoadVendorsByCategory(
      LoadVendorsByCategoryEvent event, Emitter<VendorState> emit) async {
    try {
      emit(VendorLoading());
      final data = await vendorRepository.getVendorsByCategory(event.category);
      final vendors = data.map((e) => VendorModel.fromMap(e, e['id'])).toList();
      emit(VendorLoaded(vendors));
    } catch (e) {
      emit(VendorError('Failed to load vendors: ${e.toString()}'));
    }
  }

  // ✅ Load vendor items by user ID
  Future<void> _onLoadVendorItemsByUser(
      LoadVendorItemsByUserEvent event, Emitter<VendorState> emit) async {
    try {
      emit(VendorLoading());
      final data = await vendorRepository.getVendorItemsByUser(event.userId);
      emit(VendorLoaded(data));
    } catch (e) {
      emit(VendorError('Failed to load vendor items: ${e.toString()}'));
    }
  }

  // ✅ Add vendor post
  Future<void> _onAddVendorPost(
      AddVendorPostEvent event, Emitter<VendorState> emit) async {
    try {
      emit(VendorLoading());
      await vendorRepository.addVendorPost(event.vendor.toMap());
      emit(VendorSuccess('Vendor post added successfully.'));
    } catch (e) {
      emit(VendorError('Failed to add vendor post: ${e.toString()}'));
    }
  }

  // ✅ Update vendor post
  Future<void> _onUpdateVendorPost(
      UpdateVendorPostEvent event, Emitter<VendorState> emit) async {
    try {
      emit(VendorLoading());
      await vendorRepository.updateVendorPost(event.vendorId, event.updatedData);
      emit(VendorSuccess('Vendor post updated successfully.'));
    } catch (e) {
      emit(VendorError('Failed to update vendor post: ${e.toString()}'));
    }
  }
}
