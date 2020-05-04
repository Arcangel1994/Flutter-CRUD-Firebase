import 'dart:io';

import 'package:flutter/material.dart';
import 'package:formvalidation/src/bloc/provider.dart';
import 'package:formvalidation/src/model/producto_model.dart';
import 'package:formvalidation/src/utils/utils.dart' as utils;
import 'package:image_picker/image_picker.dart';

class ProductoPage extends StatefulWidget {

  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {

  final formKey = GlobalKey<FormState>();
  final scaffolKey = GlobalKey<ScaffoldState>();

  ProductosBloc productosBloc;

  ProductoModel producto = ProductoModel();

  bool _guardando = false;

  File foto;

  @override
  Widget build(BuildContext context) {

    productosBloc = Provider.productosBloc(context);

    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;

    if(prodData != null){
      producto = prodData;
    }

    return Scaffold(
      key: scaffolKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: _seleccionarFoto,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _tomarFoto,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                _crearBoton(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearNombre(){
    return TextFormField(
      initialValue: producto.titulo,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Producto'
      ),
      onSaved: (valor) => producto.titulo = valor,
      validator: (valor){
        if(valor.length < 3){
          return 'Ingrese el nombre del producto';
        }else{
          return null;
        }
      },
    );
  }

  Widget _crearPrecio(){
    return TextFormField(
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.numberWithOptions(),
      decoration: InputDecoration(
          labelText: 'Precio'
      ),
      onSaved: (valor) => producto.valor = double.parse(valor),
      validator: (valor){
        if(utils.isNumeric(valor)){
          return null;
        }else{
          return 'Solo Numeros';
        }
      },
    );
  }

  Widget _crearDisponible(){
    return SwitchListTile(
      value: producto.disponible,
      title: Text('Disponible'),
      activeColor: Colors.deepPurple,
      onChanged: (value){
        setState(() {
          producto.disponible = value;
        });
      },
    );
  }

  Widget _crearBoton(BuildContext context){
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)
      ),
      color: Colors.deepPurple,
      textColor: Colors.white,
      icon: Icon(Icons.save),
      label: Text('Guardar'),
      onPressed: (_guardando) ? null : () => _submit(context),
    );
  }

  void _submit(BuildContext context) async{

    //No valido
    if(!formKey.currentState.validate()) return;

    formKey.currentState.save();

    setState(() {
      _guardando = true;
    });

    if(foto != null){
      producto.fotoUrl = await productosBloc.subirFoto(foto);
    }

    if(producto.id == null) {
      productosBloc.agregarProductos(producto);
      mostrarSnackBar('Registro guardado');
    }else{
      productosBloc.editarProductos(producto);
      mostrarSnackBar('Registro editado');
    }

    /*setState(() {
      _guardando = false;
    });*/

    Navigator.pop(context);

  }

  void mostrarSnackBar(String mensaje){

    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );

    scaffolKey.currentState.showSnackBar(snackbar);

  }


  Widget _mostrarFoto() {

    if (producto.fotoUrl != null) {

      return Container(
        child: FadeInImage(
          placeholder: AssetImage('assets/loading.gif'),
          image: NetworkImage(producto.fotoUrl),
          height: 300.0,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );

    } else {

      if( foto != null ){
        return Image.file(
          foto,
          fit: BoxFit.cover,
          height: 300.0,
        );
      }
      return Image.asset('assets/image.png');
    }
  }

  _seleccionarFoto() async{
    _procesarImage(ImageSource.gallery);
  }

  _tomarFoto() async{
    _procesarImage(ImageSource.camera);
  }

  _procesarImage(ImageSource origen) async{
    foto = await ImagePicker.pickImage(
        source: origen
    );

    if(foto != null){
      producto.fotoUrl = null;
    }

    setState(() {});
  }

}

