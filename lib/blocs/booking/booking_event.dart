abstract class BookingEvent {}

class LoadBookings extends BookingEvent {
  final String organizerId;
  LoadBookings(this.organizerId);
}

class UpdateBookingStatus extends BookingEvent {
  final String bookingId;
  final String newStatus;
  UpdateBookingStatus(this.bookingId, this.newStatus);
}
