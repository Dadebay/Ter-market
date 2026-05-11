import 'package:get/get.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/banner_model.dart';

class BannerController extends GetxController {
  final _api = ApiService();

  var banners = <BannerModel>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      print('[BannerController] fetching banners...');
      final result = await _api.getBanners();
      print('[BannerController] got ${result.length} banners');
      for (final b in result) {
        print('[BannerController] banner => title:${b.title} image:${b.image}');
      }
      banners.value = result;
    } catch (e, st) {
      print('[BannerController] ERROR: $e');
      print('[BannerController] STACK: $st');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
