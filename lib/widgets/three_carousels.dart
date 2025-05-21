import 'dart:async';
import 'package:flutter/material.dart';

class ThreeCarousels extends StatefulWidget {
  @override
  _ThreeCarouselsState createState() => _ThreeCarouselsState();
}

class _ThreeCarouselsState extends State<ThreeCarousels> {
  final double imageWidth = 120;
  final double imageSpacing = 12; // padding horizontal 6 + 6
  final double itemWidth = 120 + 12;

  late final ScrollController controller1;
  late final ScrollController controller2;
  late final ScrollController controller3;

  Timer? timer1;
  Timer? timer2;
  Timer? timer3;

  final List<String> images1 = List.generate(
    6,
    (index) => 'https://picsum.photos/seed/carousel1_$index/200/200',
  );
  final List<String> images2 = List.generate(
    5,
    (index) => 'https://picsum.photos/seed/carousel2_$index/200/200',
  );
  final List<String> images3 = List.generate(
    7,
    (index) => 'https://picsum.photos/seed/carousel3_$index/200/200',
  );

  @override
  void initState() {
    super.initState();
    controller1 = ScrollController(initialScrollOffset: 5000);
    controller2 = ScrollController(initialScrollOffset: 5000);
    controller3 = ScrollController(initialScrollOffset: 5000);

    timer1 = autoScroll(controller1, direction: 1);
    timer2 = autoScroll(controller2, direction: -1);
    timer3 = autoScroll(controller3, direction: 1);
  }

  Timer autoScroll(ScrollController controller, {int direction = 1}) {
    return Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (controller.hasClients) {
        controller.jumpTo(
          controller.offset + direction * 0.8,
        );
      }
    });
  }

  Widget buildInfiniteCarousel(
      List<String> images, ScrollController controller, bool offsetHalfImage) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final realIndex = index % images.length;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                images[realIndex],
                width: imageWidth,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    timer1?.cancel();
    timer2?.cancel();
    timer3?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildInfiniteCarousel(images1, controller1, false),
        const SizedBox(height: 16),
        buildInfiniteCarousel(images2, controller2, true),
        const SizedBox(height: 16),
        buildInfiniteCarousel(images3, controller3, false),
      ],
    );
  }
}
