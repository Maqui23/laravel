import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/persona.dart';
import '../services/persona_service.dart';

class CrearPersonaPage extends StatefulWidget {
  final Persona? persona;

  CrearPersonaPage({this.persona});

  @override
  _CrearPersonaPageState createState() => _CrearPersonaPageState();
}

class _CrearPersonaPageState extends State<CrearPersonaPage> {
  final _formKey = GlobalKey<FormState>();
  final PersonaService personaService = PersonaService();

  late TextEditingController nombresCtrl;
  late TextEditingController apellidosCtrl;
  late TextEditingController dniCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController telefonoCtrl;

  bool isLoading = false;
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nombresCtrl = TextEditingController(text: widget.persona?.nombres ?? '');
    apellidosCtrl = TextEditingController(text: widget.persona?.apellidos ?? '');
    dniCtrl = TextEditingController(text: widget.persona?.dni ?? '');
    emailCtrl = TextEditingController(text: widget.persona?.email ?? '');
    telefonoCtrl = TextEditingController(text: widget.persona?.telefono ?? '');
  }

  // --- NUEVA LÓGICA DE SELECCIÓN ---
  void _mostrarOpcionesFotos() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF3F51B5)),
                title: const Text('Elegir de la Galería'),
                onTap: () {
                  _obtenerImagen(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF3F51B5)),
                title: const Text('Tomar Foto ahora'),
                onTap: () {
                  _obtenerImagen(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _obtenerImagen(ImageSource source) async {
    final XFile? imagen = await _picker.pickImage(
      source: source,
      imageQuality: 50, // Comprime la imagen para no saturar tu AWS
    );
    
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }
  // ---------------------------------

  void guardarPersona() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      Map<String, String> data = {
        'nombres': nombresCtrl.text,
        'apellidos': apellidosCtrl.text,
        'dni': dniCtrl.text,
        'email': emailCtrl.text,
        'telefono': telefonoCtrl.text,
      };

      bool success;
      if (widget.persona == null) {
        success = await personaService.createPersona(data, imageFile: _imagenSeleccionada);
      } else {
        success = await personaService.updatePersona(widget.persona!.id, data, imageFile: _imagenSeleccionada);
      }
      
      setState(() => isLoading = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al procesar la solicitud'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool esEdicion = widget.persona != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Registro' : 'Nueva Persona'),
        backgroundColor: const Color(0xFF3F51B5),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _mostrarOpcionesFotos, // <-- Llamamos al menú de opciones
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _imagenSeleccionada != null 
                            ? FileImage(_imagenSeleccionada!) 
                            : (esEdicion && widget.persona!.fotoUrl != null 
                                ? NetworkImage(widget.persona!.fotoUrl!) as ImageProvider
                                : null),
                        child: (_imagenSeleccionada == null && (!esEdicion || widget.persona!.fotoUrl == null))
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF3F51B5),
                        child: Icon(Icons.add_a_photo, size: 18, color: Colors.white),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(nombresCtrl, 'Nombres', Icons.person),
                const SizedBox(height: 15),
                _buildTextField(apellidosCtrl, 'Apellidos', Icons.person_outline),
                const SizedBox(height: 15),
                _buildTextField(dniCtrl, 'DNI', Icons.badge, esNumero: true),
                const SizedBox(height: 15),
                _buildTextField(telefonoCtrl, 'Teléfono', Icons.phone, esNumero: true),
                const SizedBox(height: 15),
                _buildTextField(emailCtrl, 'Email', Icons.email),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: isLoading ? null : guardarPersona,
                    child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : Text(esEdicion ? 'ACTUALIZAR DATOS' : 'GUARDAR REGISTRO', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icono, {bool esNumero = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: esNumero ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: const Color(0xFF3F51B5)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? 'Este campo es requerido' : null,
    );
  }
}