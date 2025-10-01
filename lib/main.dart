import 'package:flutter/material.dart';
import 'package:flutter_sqlite_3/database_helper.dart';
import 'libros.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _EditTituloLibro = TextEditingController();
  List<Libro> _items = [];

  // Claves para los formularios
  final _formKeyAgregar = GlobalKey<FormState>();
  final _formKeyEditar = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cargarListaLibros();
  }

  // Método para cargar todos los libros desde la base de datos
  Future<void> _cargarListaLibros() async {
    final items = await _dbHelper.getItems();
    setState(() {
      _items = items;
    });
  }

  // Método para agregar un nuevo libro a la base de datos
  void _agregarNuevoLibro(String tituloLibro) async {
    final nuevoLibro = Libro(tituloLibro: tituloLibro);
    await _dbHelper.insertLibro(nuevoLibro);
    print("SE AGREGO UN NUEVO LIBRO");
    // Recargar la lista para mostrar el nuevo libro
    _cargarListaLibros();
    // Limpiar el campo de texto después de agregar el libro
    _EditTituloLibro.clear();
  }

  // Mostrar formulario para agregar un nuevo libro
  void _mostrarFormularioAgregar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKeyAgregar,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Agregar Nuevo Libro",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _EditTituloLibro,
                    decoration: InputDecoration(
                      labelText: "Título del libro",
                      hintText: "Ingrese el título del libro",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un título';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancelar"),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKeyAgregar.currentState!.validate()) {
                            _agregarNuevoLibro(
                              _EditTituloLibro.text.toString(),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text("Agregar"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Eliminar un libro de la base de datos por su ID
  void _eliminarLibro(int id) async {
    await _dbHelper.eliminar('libros', where: 'id = ?', whereArgs: [id]);
    _cargarListaLibros();
  }

  // Mostrar formulario de confirmación para eliminar un libro
  void _mostrarFormularioEliminar(int id, String tituloLibro) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Confirmar Eliminación",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "¿Estás seguro de que quieres eliminar el libro:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "'$tituloLibro'?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancelar"),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      _eliminarLibro(id);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Eliminar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Actualizar el título de un libro existente
  void _actualizarLibro(int id, String nuevoTitulo) async {
    await _dbHelper.actualizar(
      'libros',
      {'tituloLibro': nuevoTitulo},
      where: 'id = ?',
      whereArgs: [id],
    );
    _cargarListaLibros();
  }

  // Mostrar formulario para editar el título de un libro
  void _mostrarFormularioEditar(int id, String tituloActual) {
    // Controlador para el campo de texto con el título actual del libro
    TextEditingController _tituloController = TextEditingController(
      text: tituloActual,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKeyEditar,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Editar Libro",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("ID: $id", style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _tituloController,
                    decoration: InputDecoration(
                      labelText: "Nuevo título del libro",
                      hintText: "Ingrese el nuevo título",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un título';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancelar"),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKeyEditar.currentState!.validate()) {
                            _actualizarLibro(
                              id,
                              _tituloController.text.toString(),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text("Guardar Cambios"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SqlLite Flutter"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      // Lista de libros usando ListView.separated para mejor rendimiento
      body: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final libro = _items[index];
          return ListTile(
            title: Text(libro.tituloLibro),
            subtitle: Text('ID: ${libro.id}'),
            // Botón para eliminar el libro
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.grey),
              onPressed: () {
                _mostrarFormularioEliminar(
                  int.parse(libro.id.toString()),
                  libro.tituloLibro,
                );
              },
            ),
            // Al hacer tap en el libro, abrir formulario de edición
            onTap: () {
              _mostrarFormularioEditar(
                int.parse(libro.id.toString()),
                libro.tituloLibro,
              );
            },
          );
        },
      ),
      // Botón flotante para agregar nuevos libros
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioAgregar,
        child: Icon(Icons.add),
      ),
    );
  }
}
