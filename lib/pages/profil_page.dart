import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: const Color(0xFF68BE6D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(
                "assets/images/db.jpg",
              ),
            ),
            const SizedBox(height: 30),
            const ListTile(
              leading: Icon(Icons.person, color: Color(0xFF68BE6D)),
              title: Text("Doğukan BAYESEN"),
            ),
            const ListTile(
              leading: Icon(Icons.email, color: Color(0xFF68BE6D)),
              title: Text("dogukan.bayesen@rumeli.edu.tr"),
            ),
            const ListTile(
              leading: Icon(Icons.phone, color: Color(0xFF68BE6D)),
              title: Text("+90 555 123 45 67"),
            ),
            const ListTile(
              leading: Icon(Icons.info, color: Color(0xFF68BE6D)),
              title: Text("Flutter geliştiricisi, tarif meraklısı."),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF68BE6D),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil düzenleme tıklandı")),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text("Profili Düzenle"),
            ),
          ],
        ),
      ),
    );
  }
}
