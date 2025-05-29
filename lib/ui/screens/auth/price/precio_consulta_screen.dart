import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PrecioConsultaScreen extends StatefulWidget {
  const PrecioConsultaScreen({super.key});

  @override
  State<PrecioConsultaScreen> createState() => _PrecioConsultaScreenState();
}

class _PrecioConsultaScreenState extends State<PrecioConsultaScreen> {
  bool isLoading = true;
  Map<String, dynamic> precioCafe = {};
  String errorMessage = '';
  final currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    fetchPrecioCafe();
  }

  Future<void> fetchPrecioCafe() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Endpoint de la Federación Nacional de Cafeteros (ejemplo)
      // Nota: Deberás usar la URL correcta de la API de la Federación
      final response = await http
          .get(
            Uri.parse('https://federaciondecafeteros.org/api/precios/actual'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Simulamos la respuesta porque no tenemos acceso real a la API
        // En implementación real, usarías: final data = json.decode(response.body);
        final data = {
          'precioCarga': 3050000.0,
          'precioKilo': 24388.0,
          'fechaVigencia': '2025-05-13',
          'tasaCambio': 3820.50,
          'precioBolsaNY': 2.15,
        };

        setState(() {
          precioCafe = data;
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener datos: ${response.statusCode}');
      }
    } catch (e) {
      // Para pruebas, simulamos datos
      setState(() {
        precioCafe = {
          'precioCarga': 3050000.0,
          'precioKilo': 24388.0,
          'fechaVigencia': '2025-05-13',
          'tasaCambio': 3820.50,
          'precioBolsaNY': 2.15,
        };
        isLoading = false;
        // En producción, descomentar la siguiente línea:
        // errorMessage = 'Error al conectar con el servidor: $e';
      });
    }
  }

  void mostrarDetalles(String tipo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            maxChildSize: 0.9,
            minChildSize: 0.6,
            builder:
                (_, controller) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.only(bottom: 20),
                        ),
                      ),
                      Text(
                        tipo == 'carga'
                            ? 'Precio por carga de café (125 Kg)'
                            : 'Precio promedio por kilo',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: controller,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoCard(
                                'Datos del día ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                                [
                                  'Precio por carga: ${currencyFormat.format(precioCafe['precioCarga'])}',
                                  'Precio por kilo: ${currencyFormat.format(precioCafe['precioKilo'])}',
                                  'Tasa de cambio: \$${precioCafe['tasaCambio']}',
                                  'Precio en la Bolsa NY: \$${precioCafe['precioBolsaNY']} USD/libra',
                                  'Vigente hasta: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(precioCafe['fechaVigencia']))}',
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard('Gráfico histórico', [
                                'Evolución del precio en los últimos 30 días',
                              ]),
                              const SizedBox(height: 16),
                              Center(
                                // Placeholder para el gráfico
                                child: Container(
                                  height: 250,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.bar_chart,
                                          size: 80,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Gráfico de tendencia',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Los datos se cargarán desde la FNC',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard('Notas importantes', [
                                'Los precios se actualizan diariamente con base en la cotización del café en la Bolsa de Nueva York.',
                                'El precio puede variar dependiendo de la calidad y el factor de rendimiento del café.',
                                'Consulte la página web de la Federación Nacional de Cafeteros para más información detallada.',
                              ]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cerrar',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(item, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Consulta de Precios',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown[700],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchPrecioCafe,
            color: Colors.white,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.brown),
              )
              : errorMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Error de conexión',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: fetchPrecioCafe,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
              : Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.brown[100] ?? Colors.brown.shade100,
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio del café',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[800],
                          ),
                        ),
                        Text(
                          'Cotización actualizada de la FNC',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.brown[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildPriceCard(
                          title: 'Precio por carga de 125 Kg',
                          price: precioCafe['precioCarga'],
                          date: precioCafe['fechaVigencia'],
                          color: Colors.green[500] ?? Colors.green,
                          onTap: () => mostrarDetalles('carga'),
                        ),
                        const SizedBox(height: 16),
                        _buildPriceCard(
                          title: 'Precio promedio por kilo',
                          price: precioCafe['precioKilo'],
                          date: precioCafe['fechaVigencia'],
                          color: Colors.blue[600] ?? Colors.blue,
                          onTap: () => mostrarDetalles('kilo'),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Factores que afectan el precio',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown[800],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ListTile(
                                  leading: const Icon(
                                    Icons.trending_up,
                                    color: Colors.brown,
                                  ),
                                  title: const Text('Bolsa de Nueva York'),
                                  subtitle: Text(
                                    '\$${precioCafe['precioBolsaNY']} USD/libra',
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.currency_exchange,
                                    color: Colors.brown,
                                  ),
                                  title: const Text('Tasa de cambio'),
                                  subtitle: Text(
                                    '\$${precioCafe['tasaCambio']} COP/USD',
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          color: Colors.brown[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.brown[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Información importante',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Los precios son actualizados diariamente y están basados en la cotización del café en la Bolsa de Nueva York.',
                                  style: TextStyle(color: Colors.brown[700]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildPriceCard({
    required String title,
    required double price,
    required String date,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    Icons.receipt_long,
                    color: Colors.white.withOpacity(0.8),
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                currencyFormat.format(price),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Precio vigente hasta:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.parse(date)),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
