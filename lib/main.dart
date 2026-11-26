import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const FisicaSSTApp());
}

class FisicaSSTApp extends StatelessWidget {
  const FisicaSSTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Física Mecánica SST',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final modulos = [
      {
        'titulo': 'Movimiento Rectilíneo Uniforme',
        'sigla': 'MRU',
        'descripcion': 'Distancia, velocidad y tiempo',
        'icono': Icons.swap_horiz,
        'color': Colors.blue,
      },
      {
        'titulo': 'Movimiento Uniformemente Acelerado',
        'sigla': 'MRUA',
        'descripcion': 'Velocidad y aceleración',
        'icono': Icons.speed,
        'color': Colors.orange,
      },
      {
        'titulo': 'Caída libre',
        'sigla': 'CAIDA',
        'descripcion': 'Altura y tiempo de caída',
        'icono': Icons.arrow_downward,
        'color': Colors.teal,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Física Mecánica SST',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Aprende física aplicada al trabajo',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona el módulo que deseas estudiar y realiza tus cálculos.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ...modulos.map((modulo) {
            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: (modulo['color'] as Color).withOpacity(0.15),
                  child: Icon(
                    modulo['icono'] as IconData,
                    color: modulo['color'] as Color,
                    size: 28,
                  ),
                ),
                title: Text(
                  modulo['sigla'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(modulo['descripcion'] as String),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CalculadoraPage(
                        modulo: modulo['sigla'] as String,
                        titulo: modulo['titulo'] as String,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE1F3E8),
                child: Icon(Icons.health_and_safety, color: Colors.green),
              ),
              title: const Text(
                'Ejercicios SST',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Situaciones prácticas del entorno laboral',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EjerciciosSSTPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),
          const Center(
            child: Text(
              'Una herramienta para aprender y prevenir.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class CalculadoraPage extends StatefulWidget {
  final String modulo;
  final String titulo;

  const CalculadoraPage({
    super.key,
    required this.modulo,
    required this.titulo,
  });

  @override
  State<CalculadoraPage> createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  late String objetivo;
  final Map<String, TextEditingController> controles = {};
  String resultado = '';
  String procedimiento = '';
  String formula = '';

  final Map<String, String> nombres = {
    'd': 'Distancia (m)',
    'v': 'Velocidad (m/s)',
    't': 'Tiempo (s)',
    'vi': 'Velocidad inicial (m/s)',
    'vf': 'Velocidad final (m/s)',
    'a': 'Aceleración (m/s²)',
    'h': 'Altura (m)',
  };

  final Map<String, String> unidades = {
    'd': 'm',
    'v': 'm/s',
    't': 's',
    'vi': 'm/s',
    'vf': 'm/s',
    'a': 'm/s²',
    'h': 'm',
  };

  @override
  void initState() {
    super.initState();

    objetivo = widget.modulo == 'MRU'
        ? 'v'
        : widget.modulo == 'MRUA'
            ? 'vf'
            : 't';

    actualizarControles();
  }

  List<String> obtenerEntradas() {
    if (widget.modulo == 'MRU') {
      switch (objetivo) {
        case 'v':
          return ['d', 't'];
        case 'd':
          return ['v', 't'];
        default:
          return ['d', 'v'];
      }
    }

    if (widget.modulo == 'MRUA') {
      switch (objetivo) {
        case 'vf':
          return ['vi', 'a', 't'];
        case 'vi':
          return ['vf', 'a', 't'];
        case 'a':
          return ['vi', 'vf', 't'];
        case 't':
          return ['vi', 'vf', 'a'];
        default:
          return ['vi', 'a', 't'];
      }
    }

    if (objetivo == 't') {
      return ['h'];
    }

    return ['t'];
  }

  void actualizarControles() {
    for (final control in controles.values) {
      control.dispose();
    }
    controles.clear();

    for (final campo in obtenerEntradas()) {
      controles[campo] = TextEditingController();
    }

    resultado = '';
    procedimiento = '';
    formula = '';
  }

  double leer(String clave) {
    final valor = double.tryParse(
      controles[clave]!.text.trim().replaceAll(',', '.'),
    );

    if (valor == null || !valor.isFinite) {
      throw Exception('Verifica el dato: ${nombres[clave]}');
    }

    return valor;
  }

  void calcular() {
    try {
      final datos = <String, double>{};

      for (final campo in obtenerEntradas()) {
        datos[campo] = leer(campo);
      }

      double respuesta = 0;
      String operacion = '';
      String pasos = '';

      if (widget.modulo == 'MRU') {
        final d = datos['d'];
        final v = datos['v'];
        final t = datos['t'];

        if (objetivo == 'v') {
          if (t! <= 0) throw Exception('El tiempo debe ser mayor que cero.');
          respuesta = d! / t;
          operacion = 'v = d / t';
          pasos = 'v = $d / $t = $respuesta m/s';
        } else if (objetivo == 'd') {
          if (v! < 0 || t! < 0) {
            throw Exception('Los valores no pueden ser negativos.');
          }
          respuesta = v * t;
          operacion = 'd = v × t';
          pasos = 'd = $v × $t = $respuesta m';
        } else {
          if (v! <= 0) throw Exception('La velocidad debe ser mayor que cero.');
          if (d! < 0) throw Exception('La distancia no puede ser negativa.');
          respuesta = d / v;
          operacion = 't = d / v';
          pasos = 't = $d / $v = $respuesta s';
        }
      } else if (widget.modulo == 'MRUA') {
        final vi = datos['vi'];
        final vf = datos['vf'];
        final a = datos['a'];
        final t = datos['t'];

        if (objetivo == 'vf') {
          respuesta = vi! + a! * t!;
          operacion = 'vf = vi + a × t';
          pasos = 'vf = $vi + ($a × $t) = $respuesta m/s';
        } else if (objetivo == 'vi') {
          respuesta = vf! - a! * t!;
          operacion = 'vi = vf - a × t';
          pasos = 'vi = $vf - ($a × $t) = $respuesta m/s';
        } else if (objetivo == 'a') {
          if (t! <= 0) throw Exception('El tiempo debe ser mayor que cero.');
          respuesta = (vf! - vi!) / t;
          operacion = 'a = (vf - vi) / t';
          pasos = 'a = ($vf - $vi) / $t = $respuesta m/s²';
        } else if (objetivo == 't') {
          if (a! == 0) throw Exception('La aceleración no puede ser cero.');
          respuesta = (vf! - vi!) / a;
          operacion = 't = (vf - vi) / a';
          pasos = 't = ($vf - $vi) / $a = $respuesta s';
        } else {
          if (t! < 0) throw Exception('El tiempo no puede ser negativo.');
          respuesta = vi! * t + 0.5 * a! * t * t;
          operacion = 'd = vi × t + ½ × a × t²';
          pasos = 'd = ($vi × $t) + (0.5 × $a × $t²) = $respuesta m';
        }
      } else {
        const g = 9.81;

        if (objetivo == 't') {
          final h = datos['h']!;
          if (h < 0) throw Exception('La altura no puede ser negativa.');
          respuesta = math.sqrt((2 * h) / g);
          operacion = 't = √(2 × h / g)';
          pasos = 't = √(2 × $h / 9.81) = $respuesta s';
        } else {
          final t = datos['t']!;
          if (t < 0) throw Exception('El tiempo no puede ser negativo.');
          respuesta = 0.5 * g * t * t;
          operacion = 'h = ½ × g × t²';
          pasos = 'h = 0.5 × 9.81 × $t² = $respuesta m';
        }
      }

      if (!respuesta.isFinite) {
        throw Exception('No fue posible obtener un resultado válido.');
      }

      setState(() {
        resultado =
            '${nombres[objetivo]}: ${respuesta.toStringAsFixed(3)} ${unidades[objetivo]}';
        formula = operacion;
        procedimiento = pasos;
      });
    } catch (error) {
      setState(() {
        resultado = 'No se pudo realizar el cálculo';
        formula = '';
        procedimiento = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    for (final control in controles.values) {
      control.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opciones = widget.modulo == 'MRU'
        ? {'v': 'Velocidad', 'd': 'Distancia', 't': 'Tiempo'}
        : widget.modulo == 'MRUA'
            ? {
                'vf': 'Velocidad final',
                'vi': 'Velocidad inicial',
                'a': 'Aceleración',
                't': 'Tiempo',
                'd': 'Desplazamiento',
              }
            : {
                't': 'Tiempo de caída',
                'h': 'Altura de caída',
              };

    return Scaffold(
      appBar: AppBar(title: Text(widget.modulo)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.titulo,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Selecciona qué variable deseas calcular. '
            'Después ingresa los datos que conoces.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          const Text(
            '¿Qué deseas calcular?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: objetivo,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              labelText: 'Variable desconocida',
            ),
            items: opciones.entries.map((opcion) {
              return DropdownMenuItem(
                value: opcion.key,
                child: Text(opcion.value),
              );
            }).toList(),
            onChanged: (valor) {
              if (valor == null) return;
              setState(() {
                objetivo = valor;
                actualizarControles();
              });
            },
          ),
          const SizedBox(height: 25),
          const Text(
            'Ingresa los datos conocidos:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...obtenerEntradas().map((campo) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextField(
                controller: controles[campo],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: nombres[campo],
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit),
                ),
              ),
            );
          }),
          FilledButton.icon(
            onPressed: calcular,
            icon: const Icon(Icons.calculate),
            label: const Text('CALCULAR'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          if (resultado.isNotEmpty) ...[
            const SizedBox(height: 25),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RESULTADO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      resultado,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (formula.isNotEmpty) ...[
                      const Divider(height: 25),
                      const Text(
                        'Fórmula utilizada',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(formula),
                    ],
                    const SizedBox(height: 15),
                    const Text(
                      'Procedimiento',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(procedimiento),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EjerciciosSSTPage extends StatelessWidget {
  const EjerciciosSSTPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejercicios SST')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.health_and_safety,
              size: 55,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'Física aplicada a la prevención',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'En este módulo incorporaremos situaciones laborales '
              'para analizar velocidades, desplazamientos, aceleraciones '
              'y distancias de seguridad.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Card(
              child: ListTile(
                leading: Icon(Icons.local_shipping),
                title: Text('Movimiento de vehículos'),
                subtitle: Text(
                  'Análisis de velocidad y desplazamiento.',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.warning_amber),
                title: Text('Prevención de accidentes'),
                subtitle: Text(
                  'Aplicación de conceptos físicos en el trabajo.',
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Módulo inicial: ampliaremos sus ejercicios en la siguiente etapa.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
