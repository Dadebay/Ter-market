import 'package:get/get.dart';
import 'package:atlas/models/contact_model.dart';
import 'package:atlas/core/api/api_client.dart';

class HomeController extends GetxController {
  final contactInfo = Rx<ContactModel?>(null);
  final isLoadingContact = false.obs;
  final contactList = RxList<ContactModel>([]);

  @override
  void onInit() {
    super.onInit();
    fetchContactInfo();
  }

  Future<void> fetchContactInfo() async {
    try {
      isLoadingContact.value = true;
      final dio = ApiClient.instance;
      final response = await dio.get('Contacts');
      if (response.statusCode == 200 && response.data is List) {
        contactList.value = (response.data as List).map((item) => ContactModel.fromJson(item)).toList();
      }
    } catch (e) {
    } finally {
      isLoadingContact.value = false;
    }
  }
}
