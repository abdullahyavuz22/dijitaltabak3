import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage("assets/images/db.jpg"),
            ),
            const SizedBox(height: 30),
            const ListTile(
              leading: Icon(Icons.person, color: AppColors.primary),
              title: Text("Doğukan BAYESEN"),
            ),
            const ListTile(
              leading: Icon(Icons.email, color: AppColors.primary),
              title: Text("dogukan.bayesen@rumeli.edu.tr"),
            ),
            const ListTile(
              leading: Icon(Icons.phone, color: AppColors.primary),
              title: Text("+90 555 123 45 67"),
            ),
            const ListTile(
              leading: Icon(Icons.info, color: AppColors.primary),
              title: Text("Flutter geliştiricisi, tarif meraklısı."),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
