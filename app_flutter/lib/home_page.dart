import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'providers/upload_notifier.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _controller = TextEditingController();
  File? _selectedFile;
  Uint8List? _selectedFileBytes;
  String? _fileName;

  /// Borra la selección del archivo cuando el usuario escribe en el campo de texto.
  void _clearFileSelection() {
    setState(() {
      _selectedFile = null;
      _selectedFileBytes = null;
      _fileName = null;
    });
  }

  /// Selecciona un archivo y borra el texto del campo de entrada.
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _controller.clear(); // Borra el texto si se elige un archivo
        if (kIsWeb) {
          _selectedFileBytes = result.files.single.bytes;
          _fileName = result.files.single.name;
          _selectedFile = null;
        } else {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
          _selectedFileBytes = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InclusIA'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Ingresa tu texto'),
                onChanged: (value) {
                  _clearFileSelection(); // Borra la selección del archivo al escribir
                },
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Seleccionar Archivo (.txt o .pdf)'),
              ),

              if (_fileName != null)
                Text('Archivo seleccionado: $_fileName', style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  if (_selectedFile != null) {
                    ref.read(uploadNotifierProvider.notifier).uploadFile(
                      file: _selectedFile!,
                      fileName: _fileName!,
                    );
                  } else if (_selectedFileBytes != null) {
                    ref.read(uploadNotifierProvider.notifier).uploadFile(
                      fileBytes: _selectedFileBytes!,
                      fileName: _fileName!,
                    );
                  } else if (_controller.text.isNotEmpty) {
                    ref.read(uploadNotifierProvider.notifier).uploadText(_controller.text);
                  }
                },
                child: const Text('Subir'),
              ),

              const SizedBox(height: 16),

              if (uploadState.status == UploadStatus.uploading)
                const CircularProgressIndicator(),
              if (uploadState.status == UploadStatus.success)
                Text('Corrección del texto: \n ${uploadState.message}'),
              if (uploadState.status == UploadStatus.error)
                Text('Error: ${uploadState.message}', style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
