import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/modules/main/controllers/main_controller.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';
import 'package:atlas/modules/home/controllers/banner_controller.dart';
import 'package:atlas/modules/category/controllers/category_controller.dart';
import 'package:atlas/modules/product/controllers/product_controller.dart';
import 'package:atlas/modules/orders/controllers/order_controller.dart';
import 'package:atlas/modules/product_detail/controllers/product_detail_controller.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    GetStorage.init();

    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<BannerController>(() => BannerController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<ProductDetailController>(() => ProductDetailController());
    Get.lazyPut<OrderController>(() => OrderController());

    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<FavoritesController>(() => FavoritesController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
