import 'package:go_router/go_router.dart';
import 'package:bockaire/pages/home_page.dart';
import 'package:bockaire/pages/new_shipment_page.dart';
import 'package:bockaire/pages/optimizer_page.dart';
import 'package:bockaire/pages/quotes_page.dart';
import 'package:bockaire/pages/settings_page.dart';
import 'package:bockaire/config/route_constants.dart';

final router = GoRouter(
  initialLocation: RouteConstants.home,
  routes: [
    GoRoute(
      path: RouteConstants.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: RouteConstants.newShipment,
      builder: (context, state) => const NewShipmentPage(),
    ),
    GoRoute(
      path: RouteConstants.optimizer,
      builder: (context, state) {
        final shipmentId = state.pathParameters['shipmentId']!;
        return OptimizerPage(shipmentId: shipmentId);
      },
    ),
    GoRoute(
      path: RouteConstants.quotes,
      builder: (context, state) {
        final shipmentId = state.pathParameters['shipmentId']!;
        return QuotesPage(shipmentId: shipmentId);
      },
    ),
    GoRoute(
      path: RouteConstants.settings,
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
