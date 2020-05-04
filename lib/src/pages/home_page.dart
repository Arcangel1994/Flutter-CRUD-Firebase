import 'package:flutter/material.dart';
import 'package:formvalidation/src/bloc/provider.dart';
import 'package:formvalidation/src/model/producto_model.dart';
import 'package:formvalidation/src/providers/productos_provider.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final productosBloc = Provider.productosBloc(context);
    productosBloc.cargarProductos(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: _crearListado(productosBloc),
      floatingActionButton: _crearBoton(context),
    );
  }

  Widget _crearListado(ProductosBloc productosBloc){

    return StreamBuilder(
      stream: productosBloc.productosStream,
      builder: (BuildContext context, AsyncSnapshot<List<ProductoModel>> snapshot){
        if(snapshot.hasData){
          final productos = snapshot.data;
          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (contex, i) => _crearItem(contex, productosBloc, productos[i]),
          );
        }else{
          return Center(child: CircularProgressIndicator(),);
        }
      },
    );
  }

  Widget _crearItem(BuildContext context, ProductosBloc productosBloc ,ProductoModel productoModel){
    return Dismissible(
      key: UniqueKey(),
      background: Container(color: Colors.red,),
      onDismissed: (direccion) {
        //Borrar producto
        //productosProvider.borrarProducto(productoModel.id);
        productosBloc.borrarProductos(productoModel.id);
      },
      child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, 'producto', arguments: productoModel),
          child: _card(context, productosBloc ,productoModel)
      ),
    );
  }

  Widget _card(BuildContext context, ProductosBloc productosBloc ,ProductoModel productoModel){
    final card = Container(
      //clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[

          (productoModel.fotoUrl == null)
          ? Image(
              image: AssetImage('assets/image.png'),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 235.0,
            )
          : FadeInImage(
            placeholder: AssetImage('assets/loading.gif'),
            image: NetworkImage(productoModel.fotoUrl),
            height: 235.0,
            fit: BoxFit.cover,
            width: double.infinity,
           ),
          ListTile(
            title: Text('${productoModel.titulo}'),
            subtitle: Text('\$${productoModel.valor} Precio'),
          ),
        ],
      ),
    );

    return Dismissible(
      key: UniqueKey(),
      background: Container(color: Colors.red,),
      onDismissed: (direccion) {
        //Borrar producto
        productosBloc.borrarProductos(productoModel.id);
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: ClipRRect(
          borderRadius:  BorderRadius.circular(30.0),
          child: card,
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: <BoxShadow> [
              BoxShadow(
                  offset: Offset(2.0, 10.0),
                  spreadRadius: 2.0,
                  blurRadius: 10.0,
                  color: Colors.black26
              )
            ],
            borderRadius:  BorderRadius.circular(30.0)
        ),
      ),
    );
  }

  Widget _crearBoton(BuildContext context){
    return FloatingActionButton(
      child: Icon(Icons.add),
      backgroundColor: Colors.deepPurple,
      onPressed: ()=> Navigator.pushNamed(context, 'producto'),
    );
  }

}
