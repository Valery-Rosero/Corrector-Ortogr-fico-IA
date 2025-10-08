import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class CorrectorOrtograficoScreen extends StatefulWidget {
  const CorrectorOrtograficoScreen({super.key});

  @override
  State<CorrectorOrtograficoScreen> createState() =>
      _CorrectorOrtograficoScreenState();
}

class _CorrectorOrtograficoScreenState extends State<CorrectorOrtograficoScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String _correctedText = '';
  final _formKey = GlobalKey<FormState>();

  Future<String> correctText(String textValue) async {
    setState(() => _isLoading = true);

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key no encontrada en el archivo .env');
      }

      final model = GenerativeModel(
        model: 'gemini-2.0-flash', 
        apiKey: apiKey,
      );

      final prompt =
          'Eres un experto corrector ortográfico y de estilo del idioma español. '
          'Corrige el siguiente texto, manteniendo su tono y significado, pero mejorando ortografía, '
          'gramática y puntuación. Devuelve solo el texto corregido, sin explicaciones:\n\n$textValue';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? 'No se pudo obtener una corrección.';
    } catch (e) {
      return '⚠️ Error: ${e.toString()}';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleCorrection() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      String result = await correctText(_textController.text);
      setState(() => _correctedText = result);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA7FFEB), Color(0xFF64FFDA), Color(0xFF1DE9B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '✍️ Corrector Ortográfico IA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _textController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'Texto para corregir',
                          hintText: 'Escribe o pega tu texto aquí...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa texto para corregir';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _isLoading ? null : _handleCorrection,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Corregir texto',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'Texto corregido:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.shade100),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _correctedText.isEmpty
                                ? 'El texto corregido aparecerá aquí...'
                                : _correctedText,
                            style: TextStyle(
                              color: _correctedText.isEmpty
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
