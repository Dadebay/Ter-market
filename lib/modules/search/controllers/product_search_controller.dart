import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/product_model.dart';

class ProductSearchController extends GetxController {
  final _api = ApiService();
  final _storage = GetStorage();
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;

  var results = <ProductModel>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var query = ''.obs;
  var searchHistory = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSearchHistory();
  }

  Future<void> search(String q) async {
    query.value = q;
    if (q.trim().isEmpty) {
      results.clear();
      return;
    }
    isLoading.value = true;
    hasError.value = false;
    try {
      final data = await _api.getProducts(search: q.trim());
      results.value = data.results;
      // Save to search history
      addToSearchHistory(q.trim());
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    query.value = '';
    results.clear();
    hasError.value = false;
  }

  void loadSearchHistory() {
    try {
      final history = _storage.read<List>(_searchHistoryKey);
      if (history != null) {
        searchHistory.value = List<String>.from(history);
      }
    } catch (_) {
      searchHistory.clear();
    }
  }

  void addToSearchHistory(String query) {
    if (query.isEmpty) return;

    // Remove if already exists
    searchHistory.remove(query);
    // Add to beginning
    searchHistory.insert(0, query);
    // Keep only last N items
    if (searchHistory.length > _maxHistoryItems) {
      searchHistory.value = searchHistory.take(_maxHistoryItems).toList();
    }
    // Save to storage
    _storage.write(_searchHistoryKey, searchHistory.toList());
  }

  void removeFromSearchHistory(String query) {
    searchHistory.remove(query);
    _storage.write(_searchHistoryKey, searchHistory.toList());
  }

  void clearSearchHistory() {
    searchHistory.clear();
    _storage.remove(_searchHistoryKey);
  }
}
