import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:med_just/features/azkar/data/data_source/azkar_data_source.dart';
import 'package:med_just/features/azkar/data/model/azkar_model.dart';

class AzkarPage extends StatefulWidget {
  const AzkarPage({super.key});

  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> {
  List<AzkarItem> _items = [];
  bool _loading = true;

  final List<String> _weekDays = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _load();
    if (_items.isEmpty) {
      await _seedDefaults();
      await _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _items = await AzkarStorage.loadAll();
    setState(() => _loading = false);
  }

  Future<void> _seedDefaults() async {
    // Default azkar matching the image / provided list
    final defaults = [
      {'title': 'صلاة الجماعة', 'content': ''},
      {'title': 'السنن الرواتب', 'content': ''},
      {'title': 'الضحى', 'content': ''},
      {'title': 'الوتر', 'content': ''},
      {'title': 'قيام الليل', 'content': ''},
      {'title': 'ورد القرآن', 'content': ''},
      {'title': 'أذكار الصباح والمساء', 'content': ''},
      {'title': 'سورة الملك وأذكار النوم', 'content': ''},
    ];

    for (var i = 0; i < defaults.length; i++) {
      final item = AzkarItem(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
        title: defaults[i]['title'] ?? '',
        content: defaults[i]['content'] ?? '',
        completed: false,
        createdAt: DateTime.now(),
        weekChecks: List<bool>.filled(7, false),
      );
      await AzkarStorage.add(item);
      // small delay to ensure unique timestamps if needed
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  Future<void> _showEditDialog({AzkarItem? item}) async {
    final titleCtl = TextEditingController(text: item?.title ?? '');
    final contentCtl = TextEditingController(text: item?.content ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: Text(item == null ? 'Add Azkar' : 'Edit Azkar'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentCtl,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 4,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (saved == true) {
      if (item == null) {
        final newItem = AzkarItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: titleCtl.text.trim(),
          content: contentCtl.text.trim(),
          completed: false,
          createdAt: DateTime.now(),
          weekChecks: List<bool>.filled(7, false),
        );
        await AzkarStorage.add(newItem);
      } else {
        final updated = item.copyWith(
          title: titleCtl.text.trim(),
          content: contentCtl.text.trim(),
        );
        await AzkarStorage.update(updated);
      }
      await _load();
    }
  }

  Widget _buildHeader() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'الأذكار',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 7,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _weekDays
                        .map(
                          (d) => SizedBox(
                            width: 56,
                            child: Center(
                              child: Text(
                                d,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildRow(AzkarItem it) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    it.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration:
                          it.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (it.content.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      it.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 7,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (dayIdx) {
                    final checked =
                        it.weekChecks.length > dayIdx
                            ? it.weekChecks[dayIdx]
                            : false;
                    return SizedBox(
                      width: 52,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // Toggle the day's checked state locally and persist via update
                              final newChecks = List<bool>.from(it.weekChecks);
                              if (newChecks.length < 7) {
                                newChecks.addAll(
                                  List<bool>.filled(
                                    7 - newChecks.length,
                                    false,
                                  ),
                                );
                              }
                              newChecks[dayIdx] = !newChecks[dayIdx];
                              final updated = it.copyWith(
                                weekChecks: newChecks,
                              );
                              await AzkarStorage.update(updated);
                              await _load();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color:
                                    checked
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child:
                                  checked
                                      ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                      : const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _shortDayLabel(dayIdx),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog(item: it),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (c) => AlertDialog(
                            title: const Text('Delete'),
                            content: const Text('Delete this Azkar?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                    );
                    if (confirmed == true) {
                      await AzkarStorage.delete(it.id);
                      await _load();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _shortDayLabel(int idx) {
    switch (idx) {
      case 0:
        return 'أحد';
      case 1:
        return 'اث';
      case 2:
        return 'ثل';
      case 3:
        return 'أر';
      case 4:
        return 'خم';
      case 5:
        return 'جم';
      case 6:
        return 'سب';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أذكار و الأعمال اليومية'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child:
                        _items.isEmpty
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'لا توجد أذكار بعد — أضف أذكارك اليومية.',
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () => _showEditDialog(),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Azkar'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _items.length,
                              itemBuilder: (context, i) => _buildRow(_items[i]),
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Add Azkar',
      ),
    );
  }
}
