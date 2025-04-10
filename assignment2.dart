import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DockScreen(),
    );
  }
}

class DockScreen extends StatefulWidget {
  const DockScreen({super.key});

  @override
  State<DockScreen> createState() => _DockScreenState();
}

class _DockScreenState extends State<DockScreen> {
  // List of icon to be shown in nav bar
  List<IconData> dockItems = [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
  ];

// track the index of currently dragged item
  int? draggingIndex;
  // keeps track of indices where the mouse is havering
  Set<int> hoveredIndices = {};

  @override
  Widget build(BuildContext context) {
    // dimension of dock or nav bar
    final screenHeight = MediaQuery.of(context).size.height;
    final dockHeight = 100.0;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: DragTarget<int>(
        onAcceptWithDetails: (details) {
          final globalOffset = details.offset.dy;
          final dockTopLimit = screenHeight - dockHeight - bottomPadding;

//        to remove is icon is ouside the nav bar
          if (globalOffset < dockTopLimit) {
            setState(() {
              dockItems.removeAt(details.data);
            });
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              const Center(
                child: Text(
                  'Tap and drag icons to rearrange or drag out to remove\nHover over icons to see effect',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: dockHeight,
                  margin: EdgeInsets.only(
                    bottom: bottomPadding + 16,
                    left: 16,
                    right: 16,
                  ),
                  // the icon design
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,//center the icon in nav bar or dock
                    children: List.generate(dockItems.length, (index) {
                      final icon = dockItems[index];
                      return MouseRegion(
                        // Track the mouse 
                        onEnter: (_) => setState(() => hoveredIndices.add(index)),
                        onExit: (_) => setState(() => hoveredIndices.remove(index)),
                        child: Draggable<int>(
                          data: index,
                          feedback: Opacity(
                            opacity: 0.7,
                            child: buildIcon(icon, hovered: true),
                          ),
                          childWhenDragging: const SizedBox(width: 56),
                          onDragStarted: () => setState(() => draggingIndex = index),
                          onDraggableCanceled: (_, __) => setState(() => draggingIndex = null),
                          onDragEnd: (_) => setState(() => draggingIndex = null),
                          child: DragTarget<int>(
                            onWillAccept: (fromIndex) => fromIndex != index,
                            onAccept: (fromIndex) {
                              setState(() {
                                final dragged = dockItems.removeAt(fromIndex);
                                dockItems.insert(index, dragged);
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              return buildIcon(icon, hovered: hoveredIndices.contains(index));
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildIcon(IconData icon, {bool hovered = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: hovered ? 56 : 48,
      height: hovered ? 56 : 48,
      decoration: BoxDecoration(
        color: hovered
            ? Colors.primaries[icon.codePoint % Colors.primaries.length].shade300
            : Colors.primaries[icon.codePoint % Colors.primaries.length],
        borderRadius: BorderRadius.circular(hovered ? 16 : 12),
        boxShadow: hovered
            ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
} 
