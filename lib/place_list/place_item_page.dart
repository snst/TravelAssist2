import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

import '../utils/globals.dart';
import '../utils/map.dart';
import '../widgets/widget_date_chooser.dart';
import '../widgets/widget_icon_button.dart';
import '../widgets/widget_item_edit_actions.dart';
import '../widgets/widget_layout.dart';
import '../widgets/widget_multi_line_input.dart';
import '../widgets/widget_text_input.dart';
import '../widgets/widget_text_link.dart';
import 'place.dart';
import 'place_provider.dart';

class PlaceItemPage extends StatefulWidget {
  PlaceItemPage({
    super.key,
    required this.item,
    this.newItem = false,
    this.title = Txt.place,
    this.createReplacementPage,
  }) : modifiedItem = item.clone() {
    if (modifiedItem.isPlaceholder()) {
      modifiedItem.state = PlaceStateEnum.dynamic;
    }
  }

  final Place item;
  final Place modifiedItem;
  final bool newItem;
  final String title;
  final Function? createReplacementPage;

  @override
  State<PlaceItemPage> createState() => _PlaceItemPageState();
}

class _PlaceItemPageState extends State<PlaceItemPage> {
  PlaceProvider getProvider(BuildContext context) {
    return Provider.of<PlaceProvider>(context, listen: false);
  }

  bool save(BuildContext context) {
    widget.item.update(widget.modifiedItem);
    getProvider(context).add(widget.item);
    return true;
  }

  void updatePosition(Place place) async {
    final String position = await getPositionString();
    if (mounted) {
      setState(() {
        var link = "geo:$position";
        if (place.link1.isEmpty) {
          place.link1 = link;
        } else if (place.link2.isEmpty) {
          place.link2 = link;
        } else if (place.link3.isEmpty) {
          place.link3 = link;
        }
      });
    }
  }

  final items = [
    {'id': PlaceStateEnum.dynamic, 'icon': PlaceIcons.dynamic, 'text': 'Dynamic'},
    {'id': PlaceStateEnum.locked, 'icon': PlaceIcons.fixed, 'text': 'Locked'},
    {'id': PlaceStateEnum.booked, 'icon': PlaceIcons.booked, 'text': 'Booked'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        child: Padding(
          padding: pagePadding,
          child: Column(
            children: [
              //VSpace(),
              WidgetTextInput(
                text: widget.modifiedItem.title,
                hintText: 'Enter Place',
                onChanged: (value) => widget.modifiedItem.title = value,
                autofocus: widget.newItem, // new item
              ),
              VSpace(val: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.modifiedItem.getTimespan(), style: Theme.of(context).textTheme.bodyLarge),
              ),
              VSpace(val: 2),

              Row(
                children: [
                  WidgetDateChooser(
                    date: widget.modifiedItem.date,
                    onChanged: (val) => setState(() {
                      widget.modifiedItem.date = val;
                      if (widget.modifiedItem.isPlaceholder() || widget.modifiedItem.isDynamic()) {
                        widget.modifiedItem.state = PlaceStateEnum.locked;
                      }
                    }),
                  ),
                  HSpace(val: 2),
                  SpinBox(
                    value: widget.modifiedItem.nights.toDouble(),
                    decoration: const InputDecoration(
                      constraints: BoxConstraints.tightFor(width: 140),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                      labelText: 'Nights',
                    ),
                    onChanged: (value) => setState(() {
                      widget.modifiedItem.nights = value.toInt();
                    }),
                  ),
                  HSpace(val: 2),
                  DropdownButton<PlaceStateEnum>(
                    value: widget.modifiedItem.state,
                    hint: Text('Status'),
                    onChanged: (value) {
                      setState(() {
                        widget.modifiedItem.state = value!;
                      });
                    },
                    items: items.map((item) {
                      return DropdownMenuItem<PlaceStateEnum>(
                        value: item['id'] as PlaceStateEnum,
                        child: Row(
                          children: [Icon(item['icon'] as IconData), SizedBox(width: 8), Text(item['text'] as String)],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              VSpace(),
              WidgetTextLink(
                hintText: Txt.hintLink,
                text: widget.modifiedItem.link1,
                onChanged: (value) => widget.modifiedItem.link1 = value,
              ),
              VSpace(),
              WidgetTextLink(
                hintText: Txt.hintLink,
                text: widget.modifiedItem.link2,
                onChanged: (value) => widget.modifiedItem.link2 = value,
              ),
              VSpace(),
              WidgetTextLink(
                hintText: Txt.hintLink,
                text: widget.modifiedItem.link3,
                onChanged: (value) => widget.modifiedItem.link3 = value,
              ),
              VSpace(val: 2),
              WidgetMultiLineInput(
                hintText: Txt.hintComment,
                initalText: widget.modifiedItem.comment,
                onChanged: (value) => widget.modifiedItem.comment = value,
                lines: 5,
              ),
              VSpace(val: 2),

              WidgetItemEditActions(
                createReplacementPage: widget.createReplacementPage,
                onSave: () {
                  return save(context);
                },
                onDelete: (widget.newItem)
                    ? null
                    : () {
                        getProvider(context).delete(widget.item);
                      },
                leftWidget: [
                  WidgetIconButton(
                    icon: MyIcons.gps,
                    onPressed: () {
                      updatePosition(widget.modifiedItem);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
