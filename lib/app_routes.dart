import 'package:flutterface/ui/home_page/home_page.dart';
import 'package:flutterface/ui/realtime_face_page/realtime_face_page.dart';
import 'package:get/get.dart';

abstract class AppRoutes {
  static const home = '/home';
  static const realtime = '/realtime';
}

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(name: AppRoutes.home, page: () => const HomePage(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.realtime, page: () => const RealtimeFacePage(), transition: Transition.rightToLeft),
  ];
}
