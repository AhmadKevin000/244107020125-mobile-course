import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        body: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.school, size: 72),
            SizedBox(height: 16),
            Text('Ahmad Kevin Malik Zakaria', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('NIM: 244107020125', style: TextStyle(fontSize: 18)),
            Text('Kelas: TI-3E | Absen: 5', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Pemrograman Mobile — Minggu 1'),
          ]),
        ),
      ),
    );
  }
}