import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../widgets/export_widget.dart';
import 'memo_item_page.dart';
import 'memo_provider.dart';

class MemoListPage extends StatefulWidget {
  const MemoListPage({super.key});

  @override
  State<MemoListPage> createState() => _MemoListPageState();
}

class _MemoListPageState extends State<MemoListPage> {
  void showSettingsPage(BuildContext context, MemoProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text("Settings")),
            body: ExportWidget(
              name: 'memo_list',
              toJson: provider.toJson,
              fromJson: provider.fromJson,
              clearJson: provider.clear,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memoProvider = context.watch<MemoProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memo List"),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text("Settings")),
            ],
            elevation: 1,
            onSelected: (value) {
              switch (value) {
                case 1:
                  showSettingsPage(context, memoProvider);
                  break;
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: memoProvider.items.length,
        itemBuilder: (context, index) {
          final reverseIndex = memoProvider.items.length - 1 - index;
          return Card(
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MemoItemPage(item: memoProvider.items[reverseIndex]),
                  ),
                );
              },
              title: FormattedText(
                title: memoProvider.items[reverseIndex].title,
                content: memoProvider.items[reverseIndex].content,
              ),
              trailing: IconButton(
                icon: Icon(Icons.copy), // The icon on the right
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: memoProvider.items[reverseIndex].content,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied to Clipboard')),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MemoItemPage()),
          );
        },
        tooltip: 'Add Location',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormattedText extends StatelessWidget {
  final String title;
  final String content;

  const FormattedText({Key? key, required this.title, required this.content})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title - smaller and grey
            Text(
              title,
              style: TextStyle(
                fontSize: 16, // Smaller font size for title
                color: Colors.grey, // Grey color for title
              ),
            ),
            SizedBox(height: 2), // Spacing between title and content
            // Content - normal text
            Text(
              content,
              style: TextStyle(
                fontSize: 16, // Regular font size for content
                //color: Colors.black, // Default color for content
              ),
            ),
          ],
        ),
      ),
    );
  }
}
