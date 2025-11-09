import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelassist2/widgets/widget_layout.dart';

import '../utils/globals.dart';
import '../utils/travel_assist_utils.dart';
import 'place.dart';
import 'place_item_page.dart';
import 'place_provider.dart';

class PlaceListPage extends StatefulWidget {
  const PlaceListPage({super.key});

  @override
  State<PlaceListPage> createState() => _PlaceListPageState();
}

class _PlaceListPageState extends State<PlaceListPage> {
  bool _listEditable = false;

  void toggleEdit() {
    _listEditable = !_listEditable;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaceProvider>();
    return FutureBuilder(
      future: provider.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final items = provider.getPlaces(snapshot.data ?? []);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(provider.getTitle(items)),
            actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () => toggleEdit())],
          ),
          body: Column(
            children: [
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('No items found.'))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            color: item.getCardColor(),
                            child: ListTile(
                              contentPadding: EdgeInsets.only(left: 4.0, right: 4.0),
                              //minTileHeight: 60,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PlaceItemPage(item: item)),
                                );
                              },
                              leading: WidgetPlaceDate(place: item),
                              title: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                                  ),
                                  if (_listEditable) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.arrow_upward),
                                            onPressed: index > 0 || item.isLocked()
                                                ? () {
                                                    if (item.isLocked()) {
                                                      item.addDate(-1);
                                                    } else if (index > 0) {
                                                      item.moveUp(items[index - 1]);
                                                    }
                                                    provider.saveDirty(items);
                                                  }
                                                : null,
                                          ),

                                          IconButton(
                                            icon: const Icon(Icons.arrow_downward),
                                            onPressed: index < items.length - 1 || item.isLocked()
                                                ? () {
                                                    if (item.isLocked()) {
                                                      item.addDate(1);
                                                    } else if (index < items.length - 1) {
                                                      item.moveDown(items[index + 1]);
                                                    }
                                                    provider.saveDirty(items);
                                                  }
                                                : null,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline),
                                            onPressed: item.nights < 99 && !item.isBooked()
                                                ? () {
                                                    item.addNights(1);
                                                    provider.saveDirty(items);
                                                  }
                                                : null,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline),
                                            onPressed: item.nights > 0 && !item.isBooked()
                                                ? () {
                                                    item.addNights(-1);
                                                    provider.saveDirty(items);
                                                  }
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 56.0),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaceItemPage(item: Place(), newItem: true, title: Txt.note),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}

class WidgetPlaceDate extends StatelessWidget {
  final Place place;

  const WidgetPlaceDate({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    // Wrap with a SizedBox to constrain the width of the leading widget.
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  formatDateDayMonth(place.getStartDate()),
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.right,
                ),
              ),
              HSpace(val: 1.5),
              Icon(place.getStateIcon(), size: 16),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  formatDateDayMonth(place.getEndDate()),
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.right,
                ),
              ),
              HSpace(val: 1.5),
              if (place.nights > 0) ...[Text("(${place.nights})", style: Theme.of(context).textTheme.labelLarge)],
            ],
          ),
        ],
      ),
    );
  }
}
