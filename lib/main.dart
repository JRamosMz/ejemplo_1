import 'dart:convert';
import 'dart:ui';
import 'package:ejemplo_1/models/producto.dart';
import 'package:ejemplo_1/models/weekday.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ejemplo_1/models/semana.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryIconTheme: IconThemeData(
            color: Color(0xFF737373),
          ),
        ),
        home: FutureBuilder(
            future: _fbApp,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Salio un error");
              } else if (snapshot.hasData) {
                return MyHomePage(title: 'Tú Lista');
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double progressValue = 0.0;
  int analysis = 0;
  // las variables
  var _indexbuilder;
  var _estadodelshowdialog;
  var now = new DateTime.now();
  var formatFecha = new DateFormat('dd MMM, ' 'yyyy');

  final _formKey = GlobalKey<FormState>();

  var nombreController = TextEditingController();

  var fechaController = TextEditingController();

  var precioController = TextEditingController();

  List<Producto> listageneral = <Producto>[
    Producto(
        id: DateTime.now().toString(),
        nombre: "Zapatilla",
        fecha: "15 Nov, 2021",
        precio: 202),
    Producto(
        id: DateTime.now().toString(),
        nombre: "Chanclas",
        fecha: "16 Nov, 2021",
        precio: 100),
    Producto(
        id: DateTime.now().toString(),
        nombre: "Pelota",
        fecha: "17 Nov, 2021",
        precio: 50),
    Producto(
        id: DateTime.now().toString(),
        nombre: "Zapatilla",
        fecha: "20 Nov, 2021",
        precio: 202),
  ];

  List<Producto> listadeproductos = <Producto>[];

  List<Semana> diaSemana = <Semana>[
    /*Semana(dia: "Lunes", fecha: "2 de Oct, 2021", selected: false, cantidad: 2),
    Semana(dia: "Martes", fecha: "2 de Oct, 2021", selected: false, cantidad: 3),
    Semana(dia: "Miércoles", fecha: "20 Oct, 2021", selected: false, cantidad: 4),
    Semana(dia: "Jueves", fecha: "02 de Oc, 2021", selected: false, cantidad: 5),
    Semana(dia: "Viernes", fecha: "05 Nov, 2021", selected: false, cantidad: 2),
    Semana(dia: "Sábado", fecha: "02 de Oct", selected: false, cantidad: 4),
    Semana(dia: "Domingo", fecha: "24 Oct, 2021", selected: false, cantidad: 2),*/
  ];

  @override
  void initState() {
    String localeName = "es_ES";
    initializeDateFormatting(localeName);
    //print(localeName);
    printFirebase();
    for (var item in ObtenerDias()) {
      //print("${item.dia.toString()} :fecha ${item.fecha.toString()}");
      diaSemana.add(Semana(
          dia: item.dia.toString(),
          fecha: item.fecha.toString(),
          selected: false,
          cantidad: 0,
          progress: 0));
    }

    //Se obtine la fecha actual
    String fechaActual = formatFecha.format(now);
    //Se da el valor incial de la fecha actual
    fechaController = TextEditingController(text: fechaActual);
    // lista de productos es igual a los productos que en la lista general tienen la misma fecha que la actual
    listadeproductos = listageneral
        .where((producto) => producto.fecha!.contains(fechaActual))
        .toList();

    /*diaSemana.forEach((e) {
      e.fecha = DateFormat('EEEE').format(now);
    });*/

    diaSemana.forEach((e) {
      if (listageneral
              .where((element) => element.fecha!.contains(e.fecha.toString()))
              .length >
          0) {
        e.cantidad = listageneral
            .where((element) => element.fecha!.contains(e.fecha.toString()))
            .length;
        e.progress = e.cantidad! / 5;
      } else {
        e.cantidad = 0;
        e.progress = 0;
      }

      if (e.fecha == fechaActual) {
        e.selected = true;
      } else {
        e.selected = false;
      }
    });
    /*Al progressIndicator le indico que sea menor-igual que uno y que el valor del progressValue sea igual a la lista de productos 
    entre 5 para que avance de 2 en 2 hasta llegar a 10*/
    /*if (progressValue <= 1) {
      progressValue = (listadeproductos.length) / 5;
    }*/
    // el analisys es el indicador de progreso, le indico que no puede ser mayor que 5, y que es igual a la cantidad de elementos que hay en la lista de productos
    if (analysis <= 5) {
      analysis = listadeproductos.length;
    }
  }

  List<Weekday> ObtenerDias() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    //print(firstDayOfWeek);
    //var startFrom = now.subtract(Duration(days: now.weekday-1));

    //return List.generate(7, (i) => '${startFrom.add(Duration(days: i)).day}').toList();

    return List.generate(7, (index) => index)
        .map((value) => Weekday(
            fecha:
                formatFecha.format(firstDayOfWeek.add(Duration(days: value))),
            dia: DateFormat(DateFormat.WEEKDAY, "es_ES")
                .format(firstDayOfWeek.add(Duration(days: value)))))
        .toList();
  }

  // esta es la función volcar, que atrapa a los productos que tengan la misma fecha y los coloca en la lista de productos
  volcar_listaproductos(String fecha) {
    setState(() {
      listadeproductos = listageneral
          .where((producto) => producto.fecha!.contains(fecha))
          .toList();
    });
  }

  // esto es similar, pero me ayuda a identificar a cada producto por su id que estaa compuesto por minutos,segundos, y más
  buscar_producto(String id) {
    return listageneral.firstWhere((producto) => producto.id!.contains(id));
  }

  /* le paso un index que me ayuda a ubicar el día que estoy seleccionando y lo imprime con la función print,
     a la misma vez que utilizo la función volcar para que volque los productos, y le establesco la fecha a la que tienen que ser igual que 
    es la que seleccione
  */
  void fecha(index) {
    print("${diaSemana[index].dia}");
    volcar_listaproductos(diaSemana[index].fecha.toString());
    setState(() {
      diaSemana.forEach((e) {
        e.selected = false;
      });
      diaSemana[index].selected = true;
    });
  }

  //esta función tiene varias condicionales en la que indico que el progressindicator tiene que ser menor que 1 o que el analysis sea menor que 5
  void _guardar() {
    setState(() {
      var fechaEdit = diaSemana
          .firstWhere((el) => el.fecha == fechaController.text.toString());
      if (fechaEdit.progress! < 1 || fechaEdit.cantidad! < 5) {
        //  _formKey que es el identificador de los campos de formulario que quiero validar, le indico que tiene que validar su estado actual
        if (_formKey.currentState!.validate()) {
          // 3 tipos de controladores, nombre, fecha y precio, los tres en texto no tienen que estar vacios y de esa manera se podrá guardar lo que escriba como un prodcuto más
          if (nombreController.text.isNotEmpty &&
              fechaController.text.isNotEmpty &&
              precioController.text.isNotEmpty) {
            /*listageneral.add(
              Producto(
                  id: DateTime.now().toString(),
                  fecha: fechaController.text,
                  precio: int.parse(precioController.text),
                  nombre: nombreController.text),
            );*/
            DatabaseReference _cammpo_fecha_Ref =
                FirebaseDatabase.instance.reference().child("productos");
            _cammpo_fecha_Ref.push().set({
              'id': DateTime.now().toString(),
              'nombre': nombreController.text,
              'fecha': fechaController.text,
              'precio': int.parse(precioController.text),
            });
            // le indico que volque los productos y que la fecha la saque del controlador para que los pueda identificar
            volcar_listaproductos(fechaController.text);
            // luego de seguir esas funciones, le indico que salga del ShowDialog  y que limpie los TextFormField
            Navigator.pop(context);
            nombreController.clear();
            precioController.clear();
          }
        }
        // el progressvalue avanza 0.2 cada que guardo un nuevo producto
        //progressValue = progressValue + 0.2;
        // el analysis avanza 1 cada que guardo
        //analysis += 1;
        diaSemana.forEach((e) {
          if (listageneral
                  .where(
                      (element) => element.fecha!.contains(e.fecha.toString()))
                  .length >
              0) {
            e.cantidad = listageneral
                .where((element) => element.fecha!.contains(e.fecha.toString()))
                .length;
            e.progress = e.cantidad! / 5;
          } else {
            e.cantidad = 0;
            e.progress = 0;
          }

          if (e.fecha == fechaController.text) {
            e.selected = true;
          } else {
            e.selected = false;
          }
        });
      }
    });
  }

  // este es el widget de la lista de la semana
  Widget ListHorizontal() {
    return ListView.separated(
      itemCount: diaSemana.length,
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      separatorBuilder: (BuildContext context, int index) {
        return VerticalDivider(
          width: 6,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return Container(
          width: 110,
          child: Card(
            child: Center(
              child: MaterialButton(
                color: diaSemana[index].selected! ? Colors.blue : Colors.white,
                onPressed: () => fecha(index),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 13.0,
                    ),
                    Container(
                      height: 45,
                      width: double.infinity,
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Text("${diaSemana[index].cantidad}/5"),
                          ),
                          Center(
                            child: Container(
                              width: 45,
                              height: 45,
                              child: CircularProgressIndicator(
                                value: diaSemana[index].progress,
                                strokeWidth: 2.8,
                                backgroundColor: Color(0xFFE6E7E5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                        "${diaSemana[index].dia}"), // le indico la posición de día
                    Text(
                      "${diaSemana[index].fecha}",
                      style: TextStyle(
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // es casi similar a la función gurdar
  void _actualizaredit(index) {
    setState(() {
      // valido el estado actual de los campos de texto
      if (_formKey.currentState!.validate()) {
        // tienen que estar llenos los campos
        if (nombreController.text.isNotEmpty &&
            fechaController.text.isNotEmpty &&
            precioController.text.isNotEmpty) {
          // la variable producto_id que es igual a la id que contiene el producto que seleccione y que estan dentro de la lista general
          var producto_id = listadeproductos[index].id.toString();
          // vamos a ubicar la posición del elemento donde la id tiene que ser la misma que la de los elementos de lista de productos
          var index_general =
              listageneral.indexWhere((producto) => producto.id == producto_id);
          // en esta parte se da a escribir los nuevos valores
          listageneral[index_general] = Producto(
              id: producto_id,
              fecha: fechaController.text,
              precio: int.parse(precioController.text),
              nombre: nombreController.text);
          //le indico que los productos los saque con la fecha para que los volque
          volcar_listaproductos(fechaController.text);
          // que limpie los campos de texto
          nombreController.clear();
          precioController.clear();
          // que salga del Showdialog
          Navigator.pop(context);
        }
      }
    });
  }

  // la función de incrementar
  void _incrementCounter() {
    var fechaSele = diaSemana.firstWhere((element) => element.selected == true);
    //limpia
    nombreController.clear();
    precioController.clear();
    // vemos los cambios en el campo de texto, en este caso la fecha se va actualizando de acuerdo al día que he seleccionado
    fechaController = TextEditingController(text: fechaSele.fecha);
    // al estar en true me va a mostrar el boton de guardar y cuando este en false este en false
    _estadodelshowdialog = true;
    // mostrar el ShowDialog
    _mostrar_solo_showDialog();
    setState(() {
      //listadeproductos.add(
      // Producto(nombre: "Sandalias", momento: "1 de Oct, 2021", precio: 5),
      //);
    });
  }

  // el widget show dialog
  void _mostrar_solo_showDialog() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 350,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Nombre del producto",
                              border: OutlineInputBorder(),
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: nombreController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Llene este Campo";
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Fecha de publicación"),
                            controller: fechaController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Llene este Campo";
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: TextFormField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Precio"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: precioController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Llene este Campo";
                              }
                              return null;
                            },
                          ),
                        ),
                        MaterialButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          color: Colors.orange,
                          elevation: 2.0,
                          onPressed: () {
                            if (_estadodelshowdialog == true) {
                              return _guardar();
                            } else {
                              return _actualizaredit(_indexbuilder);
                            }
                          },
                          child: Text(
                            _estadodelshowdialog ? "Guardar" : "Actualizar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // la función de editar
  void _editProduct(int index) {
    // me muestra el boton actualizar
    _estadodelshowdialog = false;
    // meto el index dentro de una variable
    _indexbuilder = index;
    // le indicamos que carguen los campos de texto estarán llenos con los datos que se establecieron al guardarlo
    fechaController =
        TextEditingController(text: "${listadeproductos[index].fecha}");
    nombreController =
        TextEditingController(text: "${listadeproductos[index].nombre}");
    precioController =
        TextEditingController(text: "${listadeproductos[index].precio}");
    // abrimos el showdialog con todo lleno listo para la edición
    _mostrar_solo_showDialog();
    setState(() {});
  }

  // función que es parte del mensaje de advertencia que sale cuando queremos eliminar algo
  void _advertenciadelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          title: Text("¿Estás seguro que deseas \n  eliminar este elemento?"),
          content: Text("\n   ${listadeproductos[index].nombre}"),
          actions: <Widget>[
            Divider(
              indent: 20.0,
              thickness: 1,
              endIndent: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                  child: Text(
                    "Aceptar",
                    style: TextStyle(fontSize: 15.0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () => _eliminar(index),
                ),
                Container(
                  height: 15,
                  child: VerticalDivider(color: Colors.black),
                ),
                MaterialButton(
                  child: Text(
                    "Cancelar",
                    style: TextStyle(fontSize: 15.0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  // la función de confirmar elimnar
  void _eliminar(int index) {
    setState(() {
      // establecemos dos variables que contienen la id y la fecha de la lista de productos
      var producto_id = listadeproductos[index].id.toString();
      var producto_fecha = listadeproductos[index].fecha.toString();
      // removemos el producto seleccionado de todos lados
      listageneral.removeWhere((producto) => producto.id == producto_id);
      //listadeproductos.removeAt(index);

      //volcamos los productos con la misma fecha solo que ahora sin los que estan eliminados
      volcar_listaproductos(producto_fecha);
      // salimos del showdialog
      Navigator.pop(context);
      // tanto el analysis como el progressValue dismunuyen en su valor
      //analysis -= 1;
      //progressValue = progressValue - 0.2;
      diaSemana.forEach((e) {
        if (listageneral
                .where((element) => element.fecha!.contains(e.fecha.toString()))
                .length >
            0) {
          e.cantidad = listageneral
              .where((element) => element.fecha!.contains(e.fecha.toString()))
              .length;
          e.progress = e.cantidad! / 5;
        } else {
          e.cantidad = 0;
          e.progress = 0;
        }

        if (e.fecha == fechaController.text) {
          e.selected = true;
        } else {
          e.selected = false;
        }
      });
    });
  }
  /* esta función es la contra del initState, este termina el ciclo, el init State inicializa, 
  y este se llama cuando el widget es eliminado y cancela la suscripción de secuencias, animaciones, ... */

  @override
  void dispose() {
    fechaController.dispose();
    precioController.dispose();
    nombreController.dispose();
    super.dispose();
  }

  void printFirebase() {
    FirebaseDatabase.instance.reference().child("productos").once().then((DataSnapshot snapshot) {
      //print('Data : ${snapshot.value}');
      
      print("==========================================================");
      print(snapshot.value);
      
      listageneral = [];
      snapshot.value.forEach((k,values){
        print(values);
        listageneral.add(
          Producto(
              id: values["id"],
              fecha: values["fecha"],
              precio: values["precio"],
              nombre: values["nombre"], 
          ),
        );
      });
      
      volcar_listaproductos(fechaController.text);
       /* Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          print(values["nombre"]);
          /*listageneral.add(
          Producto(
              id: values["id"],
              fecha: values["fecha"],
              precio: values["precio"],
              nombre: values["nombre"], 
          ),
        ); */
        });*/
    });
  }

  // este es el widget principal donde se coloca el diseño y se llaman a las funciones creadas
  @override
  Widget build(BuildContext context) {
    //printFirebase();
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
          ),
        ),
        title: Text(
          widget.title,
          style: TextStyle(color: Color(0xFF737373)),
        ),
        actions: <Widget>[
          Icon(Icons.calendar_today),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 112,
                  child: ListHorizontal(),
                ),
                Flexible(
                  child: ListView.builder(
                    itemCount: listadeproductos.length,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 3.0,
                        child: ListTile(
                          leading: Container(
                            child: Center(
                              child: Text(
                                "\$${listadeproductos[index].precio}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF57C0E3),
                            ),
                          ),
                          title: Text("${listadeproductos[index].nombre}"),
                          subtitle: Text("${listadeproductos[index].fecha}"),
                          trailing: Wrap(
                            children: <Widget>[
                              IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onPressed: () => _editProduct(index),
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                              ),
                              IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.orange,
                                ),
                                onPressed: () =>
                                    _advertenciadelete(context, index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
