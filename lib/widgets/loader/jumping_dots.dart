//  TODO: create jumping_dots_loader
//
// import 'package:flutter/material.dart';
// import 'package:flutter/animation.dart';
//
// class _JumpingDot extends AnimatedWidget {
//   final Color color;
//   final double fontSize;
//   final Animation<double> animation;
//
//   _JumpingDot({
//     Key? key,
//     required this.animation,
//     required  this.color,
//     required  this.fontSize,
//   }) : super(key: key, listenable: animation);
//
//   Widget build(BuildContext context) {
//     return Container(
//       height: animation.value,
//       child: Text(
//         '.',
//         style: TextStyle(color: color, fontSize: fontSize),
//       ),
//     );
//   }
// }
//
// class JumpingDotsProgressIndicator extends StatefulWidget {
//   final int numberOfDots;
//   final double fontSize;
//   final double dotSpacing;
//   final Color color;
//   final int milliseconds;
//   final double beginTweenValue = 0.0;
//   final double endTweenValue = 8.0;
//
//   JumpingDotsProgressIndicator({
//     this.numberOfDots = 3,
//     this.fontSize = 10.0,
//     this.color = Colors.black,
//     this.dotSpacing = 0.0,
//     this.milliseconds = 250,
//   });
//
//   _JumpingDotsProgressIndicatorState createState() =>
//       _JumpingDotsProgressIndicatorState(
//         numberOfDots: this.numberOfDots,
//         fontSize: this.fontSize,
//         color: this.color,
//         dotSpacing: this.dotSpacing,
//         milliseconds: this.milliseconds,
//       );
// }
//
// class _JumpingDotsProgressIndicatorState
//     extends State<JumpingDotsProgressIndicator> with TickerProviderStateMixin {
//   int numberOfDots;
//   int milliseconds;
//   double fontSize;
//   double dotSpacing;
//   Color color;
//   List<AnimationController> controllers = [];
//   List<Animation<double>> animations = [];
//   List<Widget> _widgets = [];
//
//   _JumpingDotsProgressIndicatorState({
//     required  this.numberOfDots,
//     required  this.fontSize,
//     required  this.color,
//     required  this.dotSpacing,
//     required  this.milliseconds,
//   });
//
//   initState() {
//     super.initState();
//     for (int i = 0; i < numberOfDots; i++) {
//       _addAnimationControllers();
//       _buildAnimations(i);
//       _addListOfDots(i);
//     }
//
//     controllers[0].forward();
//   }
//
//   void _addAnimationControllers() {
//     controllers.add(AnimationController(
//         duration: Duration(milliseconds: milliseconds), vsync: this));
//   }
//
//   void _addListOfDots(int index) {
//     _widgets.add(Padding(
//       padding: EdgeInsets.only(right: dotSpacing),
//       child: _JumpingDot(
//         animation: animations[index],
//         fontSize: fontSize,
//         color: color,
//       ),
//     ));
//   }
//
//   void _buildAnimations(int index) {
//     animations.add(Tween(
//             begin: widget.beginTweenValue, end: widget.endTweenValue)
//         .animate(controllers[index])
//       ..addStatusListener((AnimationStatus status) {
//         if (status == AnimationStatus.completed) controllers[index].reverse();
//         if (index == numberOfDots - 1 && status == AnimationStatus.dismissed) {
//           controllers[0].forward();
//         }
//         if (animations[index].value > widget.endTweenValue / 2 &&
//             index < numberOfDots - 1) {
//           controllers[index + 1].forward();
//         }
//       }));
//   }
//
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 30.0,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: _widgets,
//       ),
//     );
//   }
//
//   dispose() {
//     for (int i = 0; i < numberOfDots; i++) controllers[i].dispose();
//     super.dispose();
//   }
// }
