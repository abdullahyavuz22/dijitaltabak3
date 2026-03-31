/*import 'dart:html';

import 'package:flutter/material.dart';

void main() => runApp(const NavigationApp());

class NavigationApp extends StatelessWidget{
  const NavigationApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      initialRoute:'/',
      routes:{
        '/':(ctx) => const AnaSayfa(),
        '/detay': (ctx) => const DetaySayfa(),
        '/form':(ctx) => const FormSayfa(),
      },
    );
  }
}
class AnaSayfa extends StatelessWidget{
  const AnaSayfa({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Anasayfa')),
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/detay',
                arguments:{'id':42, 'baslik':'Flutter Dersi'},);
              },
              child: const Text('Detay Sayfası'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async{
                final sonuc = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const FormSayfa()),
                );
                if(context.mounted && sonuc != null){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Form sonucu: $sonuc')),
                  );
                }
              },
              child: const Text('Form Sayfası'),
            )
          ],
        )
      ),
    );
  }
}

class DetaySayfa extends StatelessWidget{
  const DetaySayfa({super.key});
  
  @override
  Widget build(BuildContext context){
    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    return Scaffold(
      appBar: AppBar(title: const Text('Detay Sayfası')),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(args != null)...[
              Text('ID: ${args['id']}', style: const TextStyle(fontSize: 20)),
              Text('Başlık:${args['baslik']}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 30)
            ],
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Geri dön'),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              child: const Text('Anasayfaya dön')
            )
          ],
        )
      )
    );
  }
}
class FormSayfa extends StatefulWidget{
  const FormSayfa({super.key});

  @override
  State<FormSayfa> createState() => _FormSayfa();

}
class _FormSayfa extends State<FormSayfa>{
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext content){
    return Scaffold(
      appBar: AppBar(title: const Text('Form sayfası')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Bir şeyler yaz',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text('Kaydet ve geri dön'),
            )
          ],
        ),
      )
    );
    @override
    void dispose(){
      _controller.dispose();
    }
  }
}*/
