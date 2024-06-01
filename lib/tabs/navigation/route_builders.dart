import 'package:flutter/material.dart';

class NoAnimationRoute<T> extends PageRouteBuilder<T> {
  NoAnimationRoute(
    Widget Function(BuildContext) builder,
  ) : super(
          /// Wrap the child with a ModalBarrier since the default PageRoute includes one, but
          /// the barrier is set to non-dismissable, which causes a beep whenever you click any
          /// dead area. So use a barrier with a no-op onDismiss instead.
          ///
          /// https://github.com/flutter/flutter/issues/117342.
          ///
          /// Is just using a Material() better?
          pageBuilder: (context, animation1, animation2) => Stack(
            fit: StackFit.expand,
            children: [
              ModalBarrier(onDismiss: () {}),
              builder(context),
            ],
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          opaque: true,
        );
}

/// This route slides from one side to the other. By default, will slide up from the bottom on
/// entry, and slide down on exit. Specify [begin] to change the starting position.
///
/// See https://docs.flutter.dev/cookbook/animation/page-route-animation
class SlideRoute<T> extends PageRouteBuilder<T> {
  SlideRoute({
    required Widget Function(BuildContext) builder,
    Offset? begin,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            begin ??= const Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: Material(child: child),
            );
          },
          reverseTransitionDuration: const Duration(milliseconds: 150),
          opaque: true,
        );
}
