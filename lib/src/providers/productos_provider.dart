import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:formvalidation/src/model/producto_model.dart';
import 'package:formvalidation/src/preferencias/preferencias_usuario.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductosProvider{

  final String _url = "https://flutter-varios-a2a44.firebaseio.com";
  final _prefs = PreferenciasUsuario();

  Future<bool> crearProducto(ProductoModel producto) async{
      final url = '$_url/productos.json?auth=${_prefs.token}';

      final resp = await http.post(url, body: productoModelToJson(producto));

      final decodeData = json.decode(resp.body);

      print('======================');
      print(decodeData);

      return true;

  }

  Future<bool> editarProducto(ProductoModel producto) async{
    final url = '$_url/productos/${producto.id}.json?auth=${_prefs.token}';

    final resp = await http.put(url, body: productoModelToJson(producto));

    final decodeData = json.decode(resp.body);

    print('======================');
    print(decodeData);

    return true;

  }

  Future<List<ProductoModel>> cargarProductos(BuildContext context) async{

    final url = '$_url/productos.json?auth=${_prefs.token}';

    final resp = await http.get(url);

    final decodeData = json.decode(resp.body);

    print('======================');
    print(decodeData);
    if(decodeData.containsKey('error')){
      print('Error :(');

      Fluttertoast.showToast(
          msg: "Renovar Token",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
      );
      _prefs.token = '';
      Navigator.pushReplacementNamed(context, 'login');

    }else{
      print('Bien :)');

      final Map<String, dynamic> decodedData = decodeData;
      final List<ProductoModel> productos = List();

      if(decodedData == null) return [];

      decodedData.forEach((id, prod) {

        final prodTemp = ProductoModel.fromJson(prod);
        prodTemp.id = id;

        productos.add(prodTemp);

      });

      return productos;

    }

  }

  Future<int> borrarProducto(String id) async {
    final url = '$_url/productos/$id.json?auth=${_prefs.token}';

    final resp = await http.delete(url);

    final decodeData = json.decode(resp.body);

    print('======================');
    print(decodeData);

    return 1;
  }

  Future<String> subirImagen(File imagen) async {
    
    final url = Uri.parse('https://api.cloudinary.com/v1_1/outname/image/upload?upload_preset=ztbpt69b');

    final mimeType = mime(imagen.path).split('/');

    final imageUploadRequest = http.MultipartRequest(
      'POST',
      url
    );
    
    final file = await http.MultipartFile.fromPath(
        'file',
        imagen.path,
        contentType: MediaType(
          mimeType[0], mimeType[1])
        );

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();

    final resp = await http.Response.fromStream(streamResponse);

    if(resp.statusCode != 200 && resp.statusCode != 201){
      print('Algo salio mal');
      print(resp.body);
      return null;
    }

    final respData = json.decode(resp.body);
    print(respData);

    return respData['secure_url'];

  }

}
