import 'package:flutter/material.dart';
import 'dart:math'; // Obligatoire pour utiliser Random()
void main() {
  runApp(const MyApp());
}
//------------------------MyApp---------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Akey(),
      title: "DEVINEM",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}
//------------------------ Akèy---------------------------------
class Akey extends StatelessWidget {
   const Akey({super.key});

   @override
   Widget build(BuildContext context) {
     return Scaffold(
        appBar: AppBar(
          title: Text("Devinem",
            style: TextStyle(
                fontSize: 42, color: Colors.white
            ),

          ),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🤔", style: TextStyle(fontSize: 60)),
              SizedBox(height: 20),
              Text("Eskew ka devinem??",
              style: TextStyle(
                fontSize: 26,
              ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder:(context)=>const JeuDevinettePage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Bouton bleu
                  foregroundColor: Colors.white, // Texte du bouton en blanc
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "JOUER",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

//------------------------ jwèt--------------------------------

// Ta classe de modèle
class Mo {
  final String nom;
  final String desc;
  Mo({required this.nom, required this.desc});
}

class JeuDevinettePage extends StatefulWidget {
  const JeuDevinettePage({super.key});

  @override
  State<JeuDevinettePage> createState() => _JeuDevinettePageState();
}

class _JeuDevinettePageState extends State<JeuDevinettePage> {
  // --- VARIABLES D'ÉTAT ---
  late String motADeviner;
  late String description;
  late List<String> lettresDuMot;
  late List<String> affichageActuel;
  int viesRestantes = 5;
  String derniereLettreChoisie = "";
  bool partieTerminee = false;

  @override
  void initState() {
    super.initState();
    _initialiserJeu();
  }

  // Ta fonction modifiée pour s'intégrer à l'état
  void _initialiserJeu() {
    Map<String, dynamic> donnees = pranmo();
    setState(() {
      motADeviner = donnees['mot'];
      description = donnees['description'];
      lettresDuMot = donnees['lettres'];
      affichageActuel = donnees['affichage'];
      viesRestantes = 5;
      derniereLettreChoisie = "";
      partieTerminee = false;
    });
  }

  // Logique lorsqu'on appuie sur une lettre
  void _verifierLettre(String lettre) {
    // On arrête si la partie est finie
    if (partieTerminee) return;

    setState(() {
      derniereLettreChoisie = lettre;
      bool lettreTrouvee = false;

      // On cherche l'index de la première occurrence de la lettre
      // qui est encore cachée (représentée par '*')
      for (int i = 0; i < lettresDuMot.length; i++) {
        if (lettresDuMot[i] == lettre && affichageActuel[i] == "*") {
          affichageActuel[i] = lettre; // On révèle uniquement celle-là
          lettreTrouvee = true;
          break; // TRES IMPORTANT : On sort de la boucle immédiatement
        }
      }

      if (!lettreTrouvee) {
        viesRestantes--;
      }

      _verifierFinDePartie();
    });
  }  void _verifierFinDePartie() {
    // CAS 1 : VICTOIRE
    if (!affichageActuel.contains("*")) {
      partieTerminee = true;
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>const genyen()));
    }
    // CAS 2 : DÉFAITE
    else if (viesRestantes <= 0) {
      partieTerminee = true;
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>const pedi()));
    }
  }

  void _allerAPageVictoire() {
    print("Bravo ! Redirection vers la page de succès...");
    // TODO: Navigator.push(context, MaterialPageRoute(builder: (context) => PageSucces()));
  }

  void _allerAPageDefaite() {
    print("Dommage ! Redirection vers la page d'échec...");
    // TODO: Navigator.push(context, MaterialPageRoute(builder: (context) => PageEchec()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Devine le mot !"), centerTitle: true),
      body: Column(
        children: [
          // 1. Infos du jeu (Vies et dernière lettre)
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Vies: ❤️ $viesRestantes", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                Text("Lettre: $derniereLettreChoisie", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // 2. Description (Indice)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
          ),

          const Spacer(),

          // 3. Affichage des Astérisques / Lettres trouvées
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: affichageActuel.map((char) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.only(bottom: 5),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 2))),
              child: Text(char, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            )).toList(),
          ),

          const Spacer(),

          // 4. Clavier QWERTY personnalisé
          _buildClavier(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget du clavier
  Widget _buildClavier() {
    List<List<String>> rows = [
      ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
      ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
      ["Z", "X", "C", "V", "B", "N", "M"]
    ];

    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(5),
      child: Column(
        children: rows.map((row) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((lettre) => Expanded(
            child: GestureDetector(
              onTap: () => _verifierLettre(lettre),
              child: Container(
                margin: const EdgeInsets.all(3),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(child: Text(lettre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ),
          )).toList(),
        )).toList(),
      ),
    );
  }

  // --- TA FONCTION PRANMO REPLACÉE ICI ---
  Map<String, dynamic> pranmo() {
    List<Mo> lis = [
      Mo(nom: "tab", desc: "Mwen gen kat pye, mwen pa ka mache."),
      Mo(nom: "kokoye", desc: "Mwen se Dlo ki kanpe lwen anlè."),
      Mo(nom: "Van", desc: "Mwen pase devan pòt wa, wa pa ka fè m anyen."),
      Mo(nom: "Rido", desc: "Mwen gen rad, mwen pa gen kò."),
      Mo(nom: "Egui", desc: "Mwen gen yon sèl je, men mwen pa ka wè."),
      Mo(nom: "Revey", desc: "Depi m fèt m ap mache, mwen pa janm rive okenn kote."),
      Mo(nom: "Peny", desc: "Mwen gen dan, mwen pa ka mòde.."),
      Mo(nom: "Djondjon", desc: "Mwen gen yon chapo, men mwen pa gen tèt."),
      Mo(nom: "Demen", desc: "Mwen toujou devan w, men ou pa janm ka kenbe m."),
      Mo(nom: "Liv", desc: "Mwen gen anpil fèy, men mwen pa yon pyebwa."),
    ];

    final random = Random();
    Mo choix = lis[random.nextInt(lis.length)];
    String mot = choix.nom.toUpperCase();
    List<String> lettresDuMot = mot.split('');
    List<String> asterisques = List.generate(lettresDuMot.length, (index) => "*");

    return {
      'mot': mot,
      'description': choix.desc,
      'lettres': lettresDuMot,
      'affichage': asterisques,
    };
  }
}

//------------------------ genyen--------------------------------
class genyen extends StatelessWidget {
  const genyen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Devinem",
          style: TextStyle(
              fontSize: 42, color: Colors.white
          ),

        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🤩", style: TextStyle(fontSize: 60)),
            SizedBox(height: 20),
            Text("Bravo, ou fò",
              style: TextStyle(
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder:(context)=>const Akey()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Bouton bleu
                foregroundColor: Colors.white, // Texte du bouton en blanc
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Retounen",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//------------------------ pedi--------------------------------

class pedi extends StatelessWidget {
  const pedi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Devinem",
          style: TextStyle(
              fontSize: 42, color: Colors.white
          ),

        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("😟", style: TextStyle(fontSize: 60)),
            SizedBox(height: 20),
            Text("Domaj, ou te preske??",
              style: TextStyle(
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder:(context)=>const Akey()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Bouton bleu
                foregroundColor: Colors.white, // Texte du bouton en blanc
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Retounen",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
