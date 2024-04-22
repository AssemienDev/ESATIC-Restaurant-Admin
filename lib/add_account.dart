import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:resto_admin/acceuil_admin.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';





class AddAccount extends StatefulWidget{
  @override
  StateAddAccount createState() => StateAddAccount();
}

class StateAddAccount extends State<AddAccount>{

  late TextEditingController card;
  late TextEditingController nom;
  late TextEditingController prenom;
  late TextEditingController matricule;
  late TextEditingController filiere;
  late TextEditingController niveau;
  late TextEditingController code;
  late TextEditingController email;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    card = TextEditingController();
    nom = TextEditingController();
    prenom = TextEditingController();
    matricule = TextEditingController();
    filiere = TextEditingController();
    niveau = TextEditingController();
    code = TextEditingController();
    email = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    card.dispose();
    nom.dispose();
    prenom.dispose();
    matricule.dispose();
    filiere.dispose();
    niveau.dispose();
    code.dispose();
    email.dispose();
  }

  sendEmail(String recipientEmail, String account, String password) async {
    String username = 'newworlddesign01@gmail.com'; // Remplacez par votre adresse e-mail
    String password = 'tzwgncrbsvksmydm'; // Remplacez par votre mot de passe

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'RestoEsatic')
      ..recipients.add(recipientEmail)
      ..subject = 'Informations de compte'
      ..text = 'ICI vos informations:\n\n'
          'cardNumber: $account\n'
          'Password: $password';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ${sendReport.toString()}');
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,), onPressed: () {
          Navigator.of(context).push(_routeAcceuil());
        },
        ),
        title: const Text("Ajouter Compte", style: TextStyle(color: Colors.white),),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10),
        child: Padding(
          padding: EdgeInsets.only(top: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                 Center(child:  Padding(padding: EdgeInsets.only(top: 5), child: Text("Formulaire d'ajout", style: TextStyle(color: Color.fromARGB(220, 0, 70, 146), fontSize: 20),),),),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("Carte:"),

                        saisie(controller: card, clavier: TextInputType.number)
                      ]
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("Nom:"),
                        saisie(controller: nom, clavier: TextInputType.text)
                      ]
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("Prenom:"),
                        saisie(controller: prenom, clavier: TextInputType.text)
                      ]
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("matricule:"),
                        saisie(controller: matricule, clavier: TextInputType.text, width: 290)
                      ]
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("Email:"),
                        saisie(controller: email, clavier: TextInputType.text)
                      ]
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("Filière:"),
                        saisie(controller: filiere, clavier: TextInputType.text)
                      ]
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("Niveau:"),
                        saisie(controller: niveau, clavier: TextInputType.text)
                      ]
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("Code:"),
                        saisie(controller: code, clavier: TextInputType.number)
                      ]
                  ),

                  Padding(padding: EdgeInsets.only(top: 25, bottom: 40),
                  child: Center(
                    child: ElevatedButton(onPressed: (){
                      if(card.text.isNotEmpty && nom.text.isNotEmpty && prenom.text.isNotEmpty && matricule.text.length == 15 && filiere.text.isNotEmpty && niveau.text.isNotEmpty && code.text.length == 4){
                        enregistrer();
                      }else{

                        final snackBar = SnackBar(content: Text("Veuiller remplir tout les champs"), backgroundColor:Color.fromARGB(255, 0, 48, 81) );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                        , child: Text("ENREGISTRER", style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 70, 146),
                      ),
                    ),
                  ),
                  )
                ],
            ),
          ),
        ),
      ),
    );
  }

  Widget saisie({TextInputType? clavier, TextEditingController? controller, double width=300}){
    return Container(
    width: width,
    margin: EdgeInsets.only(bottom: 0),
    child: Padding(
      padding: EdgeInsets.all(30),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        keyboardType: clavier,
        maxLines: 1, // Permet un nombre illimité de lignes
      ),
    ),
  );
  }

  void enregistrer() async{

    DateTime now = DateTime.now();

    final ref1 = FirebaseDatabase.instance.ref();
    final snapshot = await ref1.child('comptes/${card.text}').get();

    if (snapshot.exists) {
      final snackBar = SnackBar(content: Text("Compte existant"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }else{
      DatabaseReference ref2 = FirebaseDatabase.instance.ref('comptes').child(card.text);

      await ref2.set({
        "nom": "${nom.text}",
        "prenom": "${prenom.text}",
        "niveau": "${niveau.text}",
        "matricule": "${matricule.text}",
        "email": "${email.text}",
        "filiere": "${filiere.text}",
        "code": "${code.text}",
        "balance": 0,
        "etat":"actif"
      });

      DatabaseReference ref3 = FirebaseDatabase.instance.ref("comptes/${card.text}");

      await ref3.child('historiques').push().set({
        "date": "${now.day}/${now.month}/${now.year}",
        "montant": 0,
        "statut": "depot",
        "time" : "${now.hour}:${now.minute}:${now.second}"
      });

      sendEmail(email.text, card.text, code.text);

      Navigator.of(context).push(_routeAcceuil());
    }

  }

  Route _routeAcceuil() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AcceuilAdmin(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = 0.0;
        final end = 1.0;
        final curve = Curves.ease;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        final scaleAnimation = animation.drive(tween);

        return ScaleTransition(
          scale: scaleAnimation,
          child: child,
        );
      },
    );
  }
}