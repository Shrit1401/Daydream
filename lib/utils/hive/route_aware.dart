import 'package:flutter/widgets.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

mixin RouteAwareMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Optionally override didPopNext, didPush, etc. in your widget
}
