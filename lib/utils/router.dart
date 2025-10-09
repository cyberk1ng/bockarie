import 'package:go_router/go_router.dart';
import 'package:bockaire/pages/home_page.dart';
import 'package:bockaire/pages/new_shipment_page.dart';
import 'package:bockaire/pages/optimizer_page.dart';
import 'package:bockaire/pages/quotes_page.dart';
import 'package:bockaire/pages/settings_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/new-shipment',
      builder: (context, state) => const NewShipmentPage(),
    ),
    GoRoute(
      path: '/optimizer/:shipmentId',
      builder: (context, state) {
        final shipmentId = state.pathParameters['shipmentId']!;
        return OptimizerPage(shipmentId: shipmentId);
      },
    ),
    GoRoute(
      path: '/quotes/:shipmentId',
      builder: (context, state) {
        final shipmentId = state.pathParameters['shipmentId']!;
        return QuotesPage(shipmentId: shipmentId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
