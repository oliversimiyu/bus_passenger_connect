import 'package:flutter/material.dart';

class StopSearchDelegate extends SearchDelegate<String?> {
  final List<String> stops;
  final String? selectedStop;

  StopSearchDelegate({required this.stops, this.selectedStop});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final matchedStops = stops
        .where((stop) => stop.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildStopsList(context, matchedStops);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildStopsList(context, stops);
    }

    final matchedStops = stops
        .where((stop) => stop.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildStopsList(context, matchedStops);
  }

  Widget _buildStopsList(BuildContext context, List<String> stopsList) {
    if (stopsList.isEmpty) {
      return const Center(
        child: Text(
          'No stops found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: stopsList.length,
      itemBuilder: (context, index) {
        final stop = stopsList[index];
        final isSelected = stop == selectedStop;

        return ListTile(
          title: Text(
            stop,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          leading: Icon(
            Icons.location_on_outlined,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          onTap: () {
            close(context, stop);
          },
        );
      },
    );
  }
}
