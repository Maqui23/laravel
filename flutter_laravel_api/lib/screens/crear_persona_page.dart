import 'dart:io';
import 'dart:ui'; // Necesario para el efecto cristal
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController direccionCtrl;

  // --- NUEVO CONTROLADOR ---
  late TextEditingController nivelEducativoCtrl;

  // --- VARIABLES PARA CATEGORÍAS Y FAVORITOS ---
  String? _categoriaSeleccionada;
  bool _esFavorito = false;
  final List<String> _categorias = ['Familia', 'Trabajo', 'Universidad', 'Amigos', 'Otro'];

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
    direccionCtrl = TextEditingController(text: widget.persona?.direccion ?? '');

    // --- INICIALIZAR EL NUEVO CONTROLADOR ---
    nivelEducativoCtrl = TextEditingController(text: widget.persona?.nivelEducativo ?? '');

    if (widget.persona?.categoria != null && _categorias.contains(widget.persona!.categoria)) {
      _categoriaSeleccionada = widget.persona!.categoria;
    } else {
      _categoriaSeleccionada = null;
    }

    _esFavorito = widget.persona?.esFavorito ?? false;
  }

  // --- MODAL DE FOTOS (TEMA OSCURO) ---
  void _mostrarOpcionesFotos() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E2A32),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            border: Border(top: BorderSide(color: Colors.cyanAccent, width: 2)),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: Center(
                    child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Colors.cyanAccent),
                  title: const Text('Elegir de la Galería', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onTap: () {
                    _obtenerImagen(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Colors.cyanAccent),
                  title: const Text('Tomar Foto ahora', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onTap: () {
                    _obtenerImagen(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _obtenerImagen(ImageSource source) async {
    final XFile? imagen = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }

  void guardarPersona() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      Map<String, String> data = {
        'nombres': nombresCtrl.text,
        'apellidos': apellidosCtrl.text,
        'dni': dniCtrl.text,
        'email': emailCtrl.text,
        'telefono': telefonoCtrl.text,
        'direccion': direccionCtrl.text,
        'es_favorito': _esFavorito ? '1' : '0',

        // --- AGREGAMOS EL DATO AL MAPA PARA EL BACKEND ---
        'nivel_educativo': nivelEducativoCtrl.text,
      };

      if (_categoriaSeleccionada != null) {
        data['categoria'] = _categoriaSeleccionada!;
      }

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
          SnackBar(
            content: const Text('Error al procesar la solicitud en el servidor', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool esEdicion = widget.persona != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: Text(
          esEdicion ? 'ACTUALIZAR REGISTRO' : 'NUEVO REGISTRO',
          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5, fontSize: 18)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: Stack(
        children: [
          // --- FONDO TECNOLÓGICO NEÓN ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
          ),
          Positioned(
            top: 50, left: -80,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF3F51B5).withOpacity(0.2)),
            ),
          ),

          // --- FORMULARIO ---
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // --- AVATAR CON GLOW NEÓN ---
                      GestureDetector(
                        onTap: _mostrarOpcionesFotos,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.cyanAccent, width: 2),
                                boxShadow: [
                                  BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)
                                ]
                              ),
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: const Color(0xFF1E2A32),
                                backgroundImage: _imagenSeleccionada != null
                                    ? FileImage(_imagenSeleccionada!)
                                    : (esEdicion && widget.persona!.fotoUrl != null
                                        ? NetworkImage(widget.persona!.fotoUrl!) as ImageProvider
                                        : null),
                                child: (_imagenSeleccionada == null && (!esEdicion || widget.persona!.fotoUrl == null))
                                    ? const Icon(Icons.person_add_alt_1_rounded, size: 50, color: Colors.white54)
                                    : null,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3F51B5),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.cyanAccent, width: 1.5),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),

                      // --- INTERRUPTOR DE FAVORITOS (GLASSMORPHISM) ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _esFavorito ? Colors.amber.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
                            ),
                            child: SwitchListTile(
                              title: const Text('Marcar como Prioritario', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              subtitle: Text('Destacar en la base de datos', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                              secondary: Icon(Icons.star_rounded, color: _esFavorito ? Colors.amberAccent : Colors.white24, size: 30),
                              value: _esFavorito,
                              activeColor: Colors.amberAccent,
                              activeTrackColor: Colors.amberAccent.withOpacity(0.3),
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.white12,
                              onChanged: (bool value) {
                                setState(() {
                                  _esFavorito = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // --- CAMPOS DE TEXTO ---
                      _buildTextField(nombresCtrl, 'Nombres', Icons.person_rounded),
                      const SizedBox(height: 16),
                      _buildTextField(apellidosCtrl, 'Apellidos', Icons.badge_outlined),
                      const SizedBox(height: 16),

                      // --- MENÚ DESPLEGABLE DE CATEGORÍA ---
                      DropdownButtonFormField<String>(
                        value: _categoriaSeleccionada,
                        dropdownColor: const Color(0xFF1E2A32), // Fondo oscuro para las opciones
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.cyanAccent),
                        decoration: InputDecoration(
                          labelText: 'Clasificación',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: const Icon(Icons.category_rounded, color: Colors.cyanAccent),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5)),
                        ),
                        items: _categorias.map((String categoria) {
                          return DropdownMenuItem(value: categoria, child: Text(categoria));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _categoriaSeleccionada = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // --- NUEVO CAMPO: NIVEL EDUCATIVO ---
                      _buildTextField(nivelEducativoCtrl, 'Nivel Educativo', Icons.school_rounded, esOpcional: true),
                      const SizedBox(height: 16),
                      // --------------------------------------------

                      _buildTextField(dniCtrl, 'DNI', Icons.credit_card_rounded, esNumero: true, maxLength: 8),
                      const SizedBox(height: 16),
                      _buildTextField(telefonoCtrl, 'Teléfono', Icons.phone_android_rounded, esNumero: true, maxLength: 9),
                      const SizedBox(height: 16),
                      _buildTextField(emailCtrl, 'Correo Electrónico', Icons.alternate_email_rounded),
                      const SizedBox(height: 16),
                      _buildTextField(direccionCtrl, 'Dirección Física', Icons.my_location_rounded, esOpcional: true),

                      const SizedBox(height: 40),

                      // --- BOTÓN DE GUARDADO NEÓN ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black87,
                            elevation: 8,
                            shadowColor: Colors.cyanAccent.withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: isLoading ? null : guardarPersona,
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.black87)
                              : Text(esEdicion ? 'SINCRONIZAR CAMBIOS' : 'REGISTRAR ENTIDAD',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET PERSONALIZADO PARA CAMPOS TIPO CRISTAL ---
  Widget _buildTextField(TextEditingController controller, String label, IconData icono, {bool esNumero = false, bool esOpcional = false, int? maxLength}) {
    return TextFormField(
      controller: controller,
      keyboardType: esNumero ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      inputFormatters: esNumero ? [FilteringTextInputFormatter.digitsOnly] : [],
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icono, color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        counterText: "", // Oculta el contador de caracteres nativo
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
      ),
      validator: (v) {
        if (!esOpcional && (v == null || v.trim().isEmpty)) {
          return 'Dato requerido por el sistema';
        }
        if (label == 'DNI' && v != null && v.length != 8) {
          return 'Se requieren exactamente 8 dígitos';
        }
        if (label == 'Teléfono' && v != null && v.isNotEmpty && v.length != 9) {
          return 'Se requieren exactamente 9 dígitos';
        }
        return null;
      },
    );
  }
}
