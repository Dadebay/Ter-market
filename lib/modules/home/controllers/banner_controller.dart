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
      banners.value = await _api.getBanners();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
