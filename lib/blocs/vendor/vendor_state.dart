import '../../models/vendor_model.dart';

abstract class VendorState {}

class VendorLoading extends VendorState {}

class VendorLoaded extends VendorState {
  final List<VendorModel> vendors;
  VendorLoaded(this.vendors);
}

class VendorError extends VendorState {
  final String message;
  VendorError(this.message);
}

class VendorSuccess extends VendorState {
  final String message;

  VendorSuccess(this.message);
}

