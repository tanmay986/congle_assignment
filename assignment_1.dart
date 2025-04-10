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
      home: Padding(
        padding: EdgeInsets.all(32.0),
        child: SquareAnimation(),
      ),
    );
  }
}

class SquareAnimation extends StatefulWidget {
  const SquareAnimation({super.key});

  @override
  State<SquareAnimation> createState() => SquareAnimationState();
}

class SquareAnimationState extends State<SquareAnimation> with SingleTickerProviderStateMixin {
  // This store the size of box
  static const _squareSize = 50.0;

  // Here xpos store the position of box on display and leftLimit and rightLimit is display dimension
  double xpos = 0;
  late double leftlimit;
  late double rightlimit;
  bool isMoving = false;

  // To
  late AnimationController controller;

  // box movement from one postion to another
  late Animation<double> animation;

  // For hover states or on which button we hover
  bool isHoveringLeft = false;
  bool isHoveringRight = false;

  @override
  void initState() {
    super.initState();
    // set the time interval in movement
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    // start the movement
    animation = Tween<double>(begin: 0, end: 0).animate(controller);
  }
  
// find the size of display to adjustable to it 
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width;
    leftlimit = ((screenWidth / 2) - _squareSize / 2);
    rightlimit = -((screenWidth / 2) - _squareSize / 2);
  }

// Move the box to right side with animation
  void moveRight() async {
    setState(() {
      isMoving = true;
      animation = Tween<double>(begin: xpos, end: rightlimit)
          .animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));
    });
    // start
    controller.forward(from: 0);
    // wait for movement to complete
    await Future.delayed(const Duration(seconds: 1));
    // final postion update and reset movement;
    setState(() {
      xpos = rightlimit;
      isMoving = false;
    });
  }
// move the box to left ise and uses same logic as above
  void _moveLeft() async {
    setState(() {
      isMoving = true;
      animation = Tween<double>(begin: xpos, end: leftlimit)
          .animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));
    });
    controller.forward(from: 0);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      xpos = leftlimit;
      isMoving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // showing the bouncing square
        SizedBox(
          height: 200,
          child: Center(
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(animation.value, 0),
                  child: child,
                );
              },
              // 
              child: Container(
                width: _squareSize,
                height: _squareSize,
                decoration: BoxDecoration(
                  color: Colors.red,
                  border: Border.all(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // This is Left Button and used to direct the box to left side of screen
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MouseRegion(
              onEnter: (_) => setState(() => isHoveringLeft = true),
              onExit: (_) => setState(() => isHoveringLeft = false),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHoveringLeft ? Colors.blueAccent : null,
                  elevation: isHoveringLeft ? 8 : 2,
                ),
                onPressed: (!isMoving && xpos != rightlimit) ? moveRight : null,
                child: const Text('Left'),
              ),
            ),
            const SizedBox(width: 8),
            // This is right button and direct the box to right side of screen 
            MouseRegion(
              onEnter: (_) => setState(() => isHoveringRight = true),
              onExit: (_) => setState(() => isHoveringRight = false),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHoveringRight ? Colors.green : null,
                  elevation: isHoveringRight ? 8 : 2,
                ),
                onPressed: (!isMoving && xpos != leftlimit) ? _moveLeft : null,
                child: const Text('Right'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
