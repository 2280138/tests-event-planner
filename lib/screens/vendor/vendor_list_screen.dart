import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/vendor/vendor_bloc.dart';
import '../../blocs/vendor/vendor_event.dart';
import '../../blocs/vendor/vendor_state.dart';
import '../../repositories/vendor_repository.dart';

class VendorListScreen extends StatelessWidget {
  final String category;

  const VendorListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => VendorRepository(),
      child: BlocProvider(
        create: (context) => VendorBloc(
          vendorRepository: RepositoryProvider.of<VendorRepository>(context),
        )..add(LoadVendorsByCategoryEvent(category)),
        child: Scaffold(
          appBar: AppBar(
            title: Text('$category Vendors'),
          ),
          body: BlocBuilder<VendorBloc, VendorState>(
            builder: (context, state) {
              if (state is VendorLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is VendorLoaded) {
                final vendors = state.vendors;
                if (vendors.isEmpty) {
                  return const Center(child: Text('No vendors found in this category.'));
                }
                return ListView.builder(
                  itemCount: vendors.length,
                  itemBuilder: (context, index) {
                    final vendor = vendors[index];
                    return Card(
                      child: ListTile(
                        leading: vendor.imageUrl != null
                            ? Image.network(vendor.imageUrl!, width: 60, height: 60, fit: BoxFit.cover)
                            : const Icon(Icons.store),
                        title: Text(vendor.businessName),
                        subtitle: Text('Price: \$${vendor.price}'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          // TODO: Add detailed vendor screen
                        },
                      ),
                    );
                  },
                );
              } else if (state is VendorError) {
                return Center(child: Text('Error: ${state.message}'));
              } else {
                return const Center(child: Text('Unexpected state.'));
              }
            },
          ),
        ),
      ),
    );
  }
}
