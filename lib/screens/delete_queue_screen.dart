import 'package:flutter/material.dart';

import '../models/models.dart';
import '../widgets/net_image.dart';
import 'photo_preview_screen.dart';

class DeleteQueueScreen extends StatefulWidget {
  final List<Photo> photos;
  final VoidCallback onBack;
  final ValueChanged<List<int>> onRestore;
  final ValueChanged<List<int>> onDelete;

  const DeleteQueueScreen({
    super.key,
    required this.photos,
    required this.onBack,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  State<DeleteQueueScreen> createState() => _DeleteQueueScreenState();
}

class _DeleteQueueScreenState extends State<DeleteQueueScreen> {
  final Set<int> _selected = {};
  bool _selectionMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? "${_selected.length} Selected"
              : "Delete Queue (${widget.photos.length})",
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectionMode) {
              setState(() {
                _selectionMode = false;
                _selected.clear();
              });
              return;
            }

            widget.onBack();
          },
        ),
        actions: [
          if (_selectionMode)
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selected.length == widget.photos.length) {
                    _selected.clear();
                  } else {
                    _selected
                      ..clear()
                      ..addAll(
                        List.generate(
                          widget.photos.length,
                          (i) => i,
                        ),
                      );
                  }
                });
              },
              child: Text(
                _selected.length == widget.photos.length
                    ? "Clear"
                    : "Select All",
              ),
            ),
        ],
      ),
      body: widget.photos.isEmpty
          ? const Center(
              child: Text(
                "No photos in delete queue",
                style: TextStyle(fontSize: 16),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                        onPressed: _selected.isEmpty
                            ? null
                            : () {
                                widget.onRestore(_selected.toList());
                            },
                          icon: const Icon(Icons.restore),
                          label: Text(
                            "Restore (${_selected.length})",
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _selected.isEmpty
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Delete Photos"),
                                      content: Text(
                                        "Delete ${_selected.length} selected photos?\n\nPermanent delete will be implemented later.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            widget.onDelete(_selected.toList());
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.delete_forever),
                          label: Text(
                            "Delete (${_selected.length})",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: widget.photos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final photo = widget.photos[index];
                      final selected = _selected.contains(index);

                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _selectionMode = true;
                          _selected.add(index);
                        });
                      },
                      onTap: () {
                        if (_selectionMode) {
                          setState(() {
                            if (_selected.contains(index)) {
                              _selected.remove(index);

                              if (_selected.isEmpty) {
                                _selectionMode = false;
                              }
                            } else {
                              _selected.add(index);
                            }
                          });

                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhotoPreviewScreen(
                              photos: widget.photos,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: photo.id,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: NetImage(
                                url: photo.url,
                                asset: photo.asset,
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? Colors.red
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                color: selected
                                    ? Colors.red.withOpacity(0.18)
                                    : Colors.transparent,
                              ),
                            ),
                            if (_selectionMode)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: selected
                                      ? Colors.red
                                      : Colors.white,
                                  child: Icon(
                                    selected
                                        ? Icons.check
                                        : Icons.circle_outlined,
                                    size: 15,
                                    color: selected
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
         );
  }
}