import 'package:flutter/material.dart';
import 'package:kasir_app/core/widgets/app_dialog.dart';

import '../../../core/widgets/currency_text_field.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../data/local/pengeluaran_repo.dart';
import '../../widgets/app_drawer.dart';

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  final repo = PengeluaranRepo();

  final nominalController = TextEditingController();
  final catatanController = TextEditingController();

  String kategori = 'Operasional';

  Future<List<Map<String, dynamic>>>? pengeluaranList;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    nominalController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  void loadData() {
    setState(() {
      pengeluaranList = repo.getAll();
    });
  }

  int parseNominal() {
    return int.tryParse(
          nominalController.text.replaceAll('.', '').trim(),
        ) ??
        0;
  }

  Future<void> simpan() async {
    final nominal = parseNominal();

    if (nominal <= 0) {
      AppDialog.error(context, message: 'Nominal wajib diisi');
      return;
    }

    await repo.insert(
      kategori: kategori,
      nominal: nominal,
      catatan: catatanController.text.trim(),
    );

    if (!mounted) return;

    nominalController.clear();
    catatanController.clear();

    loadData();

    AppDialog.success(context, message: 'Pengeluaran berhasil dicatat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran Kas'),
      ),
      drawer: const AppDrawer(
        currentPage: 'Pengeluaran',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: kategori,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      'Operasional',
                      'Belanja',
                      'Transport',
                      'Donasi',
                      'Lainnya',
                    ].map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        kategori = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  CurrencyTextField(
                    controller: nominalController,
                    label: 'Nominal',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: catatanController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: simpan,
                      child: const Text('Simpan Pengeluaran'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: pengeluaranList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data ?? [];

                  if (data.isEmpty) {
                    return const Center(
                      child: Text('Belum ada pengeluaran'),
                    );
                  }

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(item['kategori']?.toString() ?? '-'),
                          subtitle: Text(item['catatan']?.toString() ?? ''),
                          trailing: Text(
                            CurrencyFormatter.format(item['nominal'] ?? 0),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}