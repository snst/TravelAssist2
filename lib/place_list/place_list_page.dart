import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelassist2/widgets/widget_icon_button.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Places"),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => toggleEdit()
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Place>>(
              future: provider.getAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final items = provider.getPlaces(snapshot.data ?? []);
                if (items.isEmpty) {
                  return const Center(child: Text('No items found.'));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: items[index].getCardColor(),
                      child: ListTile(
                        minTileHeight: 80,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlaceItemPage(item: items[index]),
                            ),
                          );
                        },
                        leading: WidgetPlaceDate(place: items[index]),
                        title: WidgetPlace(place: items[index]),
                        trailing: (items[index].isPlaceholder() || !_listEditable) ? null : SizedBox(
                          width: 240,
                          child: Row(
                            children: [
                              WidgetIconButton(
                                icon: Icons.arrow_upward,
                                enabled: index > 0 && !items[index].isBooked(),
                                onPressed: () => {
                                  items[index].moveUp(items[index-1]),
                                  provider.saveDirty(items),
                                }
                              ),
                              WidgetIconButton(
                                  icon: Icons.arrow_downward,
                                  enabled: index < items.length - 1 && !items[index].isBooked(),
                                  onPressed: () => {
                                    items[index].moveDown(items[index+1]),
                                    provider.saveDirty(items),
                                  }
                              ),
                              WidgetIconButton(
                                  icon: Icons.add_circle_outline,
                                  enabled: items[index].nights < 99 && !items[index].isBooked(),
                                  onPressed: () => {
                                    items[index].setNights(items[index].nights+1),
                                    provider.saveDirty(items),
                                  }
                              ),
                              WidgetIconButton(
                                  icon: Icons.remove_circle_outline,
                                  enabled: items[index].nights > 0&& !items[index].isBooked(),
                                  onPressed: () => {
                                    items[index].setNights(items[index].nights-1),
                                    provider.saveDirty(items),
                                  }
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
                builder: (context) => PlaceItemPage(
                  item: Place(),
                  newItem: true,
                  title: Txt.note,
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class WidgetPlace extends StatelessWidget {
  final Place place;

  const WidgetPlace({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Row(children: []),
          Text(place.title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
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
                width: 80,
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
                width: 80,
                child: Text(
                  formatDateDayMonth(place.getEndDate()),
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.right,
                ),
              ),
              HSpace(val: 1.5),
              if (place.nights > 0) ...[
                Text(
                  "( ${place.nights} )",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

