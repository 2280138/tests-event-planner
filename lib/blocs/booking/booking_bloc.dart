import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_event.dart';
import 'booking_state.dart';
import '../../repositories/booking_repository.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repository;

  BookingBloc(this.repository) : super(BookingLoading()) {
    on<LoadBookings>((event, emit) async {
      try {
        emit(BookingLoading());
        await emit.forEach(
          repository.getBookingsForOrganizer(event.organizerId),
          onData: (bookings) => BookingLoaded(bookings),
          onError: (_, __) => BookingError("Failed to load bookings"),
        );
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });

    on<UpdateBookingStatus>((event, emit) async {
      try {
        await repository.updateBookingStatus(event.bookingId, event.newStatus);
      } catch (e) {
        emit(BookingError("Failed to update booking status"));
      }
    });
  }
}
