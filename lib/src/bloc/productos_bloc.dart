import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:formvalidation/src/model/producto_model.dart';
import 'package:formvalidation/src/providers/productos_provider.dart';
import 'package:rxdart/rxdart.dart';

class ProductosBloc{

  final _productosController = BehaviorSubject<List<ProductoModel>>();
  final _cargandoController = BehaviorSubject<bool>();

  final _productosProvider = ProductosProvider();

  Stream<List<ProductoModel>> get productosStream => _productosController.stream;
  Stream<bool> get cargando => _cargandoController.stream;
  
  void cargarProductos(BuildContext context) async{
    final productos = await _productosProvider.cargarProductos(context);
    _productosController.sink.add(productos);
  }

  void agregarProductos(ProductoModel producto) async {
    _cargandoController.sink.add(true);
    await _productosProvider.crearProducto(producto);
    _cargandoController.sink.add(false);
  }

  Future<String> subirFoto(File foto) async{
    _cargandoController.sink.add(true);
   final fotoUri = await _productosProvider.subirImagen(foto);
    _cargandoController.sink.add(false);
    return fotoUri;
  }

  void editarProductos(ProductoModel producto) async {
    _cargandoController.sink.add(true);
    await _productosProvider.editarProducto(producto);
    _cargandoController.sink.add(false);
  }

  void borrarProductos(String id) async {
    await _productosProvider.borrarProducto(id);
  }

  dispose(){
    _productosController.close();
    _cargandoController.close();
  }

}
