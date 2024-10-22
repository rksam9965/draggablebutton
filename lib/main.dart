import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [MyApp] is the main application widget.
/// It initializes the [MaterialApp] and sets up the dock in the center.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, isDragging) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(icon),
                  constraints: const BoxConstraints(minWidth: 48),
                  height: 48,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDragging
                        ? Colors.grey[400]
                        : Colors
                            .primaries[icon.hashCode % Colors.primaries.length],
                  ),
                  child: Center(child: Icon(icon, color: Colors.white)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A custom Dock widget that contains draggable and sortable icons.
/// [T] is the type of the items being reordered in the dock (in this case, IconData).
class Dock extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  /// Initial list of IconData items to display in the dock.
  final List<IconData> items;

  /// A builder function that builds each IconData in the dock, taking the icon and
  /// a boolean [isDragging] that indicates whether the icon is currently being dragged.
  final Widget Function(IconData, bool isDragging) builder;

  @override
  State<Dock> createState() => _DockState();
}

/// The state for the [Dock] widget, managing the list of icons and their movement.
class _DockState extends State<Dock> {
  /// Internal list of IconData items being manipulated in the dock.
  late List<IconData> _items = widget.items.toList();

  /// Currently dragged icon.
  IconData? _draggingItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final int index = entry.key;
          final IconData item = entry.value;

          return LongPressDraggable<IconData>(
            data: item,
            axis: Axis.horizontal,
            onDragStarted: () {
              setState(() {
                _draggingItem = item;
              });
            },
            onDragEnd: (details) {
              setState(() {
                _draggingItem = null;
              });
            },
            feedback: Opacity(
              opacity: 0.75,
              child: widget.builder(item, true),
            ),
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: widget.builder(item, false),
            ),
            child: DragTarget<IconData>(
              onAccept: (receivedItem) {
                setState(() {
                  final draggedIndex = _items.indexOf(receivedItem);
                  _items.removeAt(draggedIndex);
                  _items.insert(index, receivedItem);
                });
              },
              onWillAccept: (receivedItem) => receivedItem != item,
              builder: (context, candidateData, rejectedData) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: widget.builder(item, _draggingItem == item),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
