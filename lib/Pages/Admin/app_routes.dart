import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Admin/middlewares/admin_middleware.dart';
import 'package:tictactoe_gameapp/Pages/Admin/Pages/admin_setting_page.dart';
import 'package:tictactoe_gameapp/Pages/Admin/Pages/admin_home_page.dart';

class AdminRoutes {
  static List<GetPage> routes = [
    GetPage(
      name: '/admin',
      page: () => const AdminDashboardPage(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: '/admin/settings',
      page: () => const AdminSettingsPage(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: '/admin/home',
      page: () => const AdminDashboardPage(),
      middlewares: [AdminMiddleware()],
    ),
  ];

  static void setupAdminRoutes() {
    // Đăng ký các routes cho phần admin
    Get.addPages(routes);
  }
}