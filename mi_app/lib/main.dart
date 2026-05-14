import 'package:flutter/material.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Portfolio Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int contador = 0;

  void incrementarContador() {
    setState(() {
      contador++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DBP II')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 243, 33, 33),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.menu_book, color: Color.fromARGB(255, 255, 255, 255), size: 40),
                  SizedBox(height: 10),
                  Text(
                    'Ver más',
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 24),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color.fromARGB(255, 243, 33, 54)),
              title: const Text('Mi Biografía', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const PantallaBiografia())
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate, color: Color.fromARGB(255, 243, 33, 54)),
              title: const Text('Calculadora', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const CalculadoraPage())
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¡Este es un pequeño avance!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/paisaje.jpg',
                  width: 350,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 350,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text('Imagen no encontrada.\nRevisa pubspec.yaml', textAlign: TextAlign.center),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 40, thickness: 2, indent: 50, endIndent: 50),
              Text(
                'Contador actual: $contador',
                style: const TextStyle(fontSize: 22, color: Colors.blue),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: incrementarContador,
                icon: const Icon(Icons.add),
                label: const Text('Incrementar Contador'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PantallaBiografia extends StatelessWidget {
  const PantallaBiografia({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Biografía')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alexis Ivan Mamani Quilca',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Estudiante de Ingeniería de Sistemas - 4to Ciclo'),
            const Text('Universidad Nacional del Altiplano (Puno)'),
            const Divider(height: 30),
            const Text(
              'Intereses y Habilidades:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('• Programación: C++, JavaScript, PHP y Dart/Flutter.'),
            const Text('• Videojuegos: Fanático de Fallout y Pokémon.'),
            const Text('• Matemáticas: Especial interés en Cálculo y Álgebra Lineal.'),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver al Inicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculadoraPage extends StatefulWidget {
  const CalculadoraPage({super.key});

  @override
  State<CalculadoraPage> createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  final TextEditingController txtN1 = TextEditingController();
  final TextEditingController txtN2 = TextEditingController();
  String resultado = "";

  @override
  void dispose() {
    txtN1.dispose();
    txtN2.dispose();
    super.dispose();
  }

  void operar(String op) {
    if (txtN1.text.isEmpty || txtN2.text.isEmpty) {
      setState(() => resultado = "Error: Llene ambos campos");
      return;
    }

    double? n1 = double.tryParse(txtN1.text);
    double? n2 = double.tryParse(txtN2.text);

    if (n1 == null || n2 == null) {
      setState(() => resultado = "Error: Ingrese números válidos");
      return;
    }

    setState(() {
      switch (op) {
        case "+": resultado = (n1 + n2).toString(); break;
        case "-": resultado = (n1 - n2).toString(); break;
        case "*": resultado = (n1 * n2).toString(); break;
        case "/": 
          resultado = (n2 == 0) ? "Error: División por cero" : (n1 / n2).toString();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: txtN1,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Número 1", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: txtN2,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Número 2", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () => operar("+"), child: const Text("+")),
                  ElevatedButton(onPressed: () => operar("-"), child: const Text("-")),
                  ElevatedButton(onPressed: () => operar("*"), child: const Text("x")),
                  ElevatedButton(onPressed: () => operar("/"), child: const Text("÷")),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                "Resultado: $resultado",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver al Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}