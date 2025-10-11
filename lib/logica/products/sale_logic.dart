import 'package:flutter/foundation.dart';
import 'package:casa_joyas/modelo/database/crud_sale.dart';
import 'package:casa_joyas/modelo/products/sale.dart';

class SaleLogic extends ChangeNotifier {
  final SaleCRUDLogic _saleRepo;
  List<Sale> _sales = [];
  bool _isLoading = false;

  SaleLogic(this._saleRepo) {
    fetchSales();
  }

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchSales() async {
    _setLoading(true);
    try {
      _sales = await _saleRepo.readAll();
    } catch (e) {
      print('Error al cargar ventas: $e');
    } finally {
      _setLoading(false);
    }
  }
  Future<Sale?> addSale(Sale sale) async {
    try {
      final newSale = await _saleRepo.create(sale);
      if (newSale != null) {
        _sales.add(newSale);
        notifyListeners(); 
      }
      return newSale;
    } catch (e) {
      rethrow;
    }
  }
}