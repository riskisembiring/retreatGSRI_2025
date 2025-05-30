import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retreat 2025',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomePage(),
    );
  }
}

// Halaman Awal
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Retreat Pemuda-Pemudi 2025')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Retreat Pemuda-Pemudi Tahun 2025',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Text('Tema     : "Bertumbuh dalam kasih, Bersinar dalam iman"'),
            Text('Hari     : Kamis - Jumat'),
            Text('Tanggal  : 01 - 02 Mei 2025'),
            SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DaftarPage()),
                      );
                    },
                    child: Text('Daftar'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DataPage()),
                      );
                    },
                    child: Text('Lihat Data Pendaftar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Form Pendaftaran
class DaftarPage extends StatefulWidget {
  @override
  _DaftarPageState createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  final TextEditingController nameController = TextEditingController();
  String selectedSize = '';
  final List<String> ukuranBaju = ['S', 'M', 'L', 'XL', 'XXL'];

  void showSnackbar(String message, [Color color = Colors.redAccent]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void saveData() async {
    String name = nameController.text.trim();
    String size = selectedSize;

    if (name.isEmpty || size.isEmpty) {
      showSnackbar('Nama dan Ukuran harus diisi!');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('baju').add({
        'name': name,
        'size': size,
        'timestamp': FieldValue.serverTimestamp(),
      });

      showSnackbar('Data berhasil disimpan!', Colors.green);

      setState(() {
        nameController.clear();
        selectedSize = '';
      });

      // Navigasi ke halaman data
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DataPage()),
        );
      });
    } catch (e) {
      showSnackbar('Gagal menyimpan: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Pendaftaran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama Lengkap'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Ukuran Baju'),
              value: selectedSize.isEmpty ? null : selectedSize,
              items: ukuranBaju.map((size) {
                return DropdownMenuItem<String>(
                  value: size,
                  child: Text(size),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSize = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: saveData,
              icon: Icon(Icons.send),
              label: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman untuk Menampilkan Data Peserta
class DataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data Peserta')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('baju')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Belum ada data pendaftar.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text(data['name']),
                  subtitle: Text('Ukuran: ${data['size']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
