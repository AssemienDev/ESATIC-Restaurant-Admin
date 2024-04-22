import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:resto_admin/add_account.dart';
import 'package:resto_admin/historiques.dart';
import 'package:resto_admin/login_resto.dart';
import 'package:resto_admin/update_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcceuilAdmin extends StatefulWidget{

  @override
  StateAcceuilAdmin createState() => StateAcceuilAdmin();
}

class StateAcceuilAdmin extends State<AcceuilAdmin>{

  String? numberCard;
  String? matricule;
  int? depot;
  int? balance;
  String? _selectedValue;
  Map<String, dynamic> etudiants = {};
  late TextEditingController searchController;
  late TextEditingController solde;

  // Initialiser une référence à la base de données
  final ref = FirebaseDatabase.instance.ref();


  Future<bool> connexion() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else{
      return false;
    }
  }

  Future<void> testeConnexion() async{
    bool valeur = await connexion();
    if(valeur == false){
      final snackbar = SnackBar(content: Text("Veuillez vous connecter a Internet"), backgroundColor: Colors.red,);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  String searchQuery = '';




  Future<void> supprime() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('login');
  }

  Future<void> init() async{
    final ref1 = FirebaseDatabase.instance.ref();
    ref1.child('comptes').onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        if (snapshot.value != null) {

          Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;

          Map<String, dynamic> data = {};
          Map<String, dynamic> etudiants = {};


          rawData.forEach((key, value) {
            if (key is String) {
              data[key] = value;
              Map<String, dynamic> matriculeAndBalance = {};
              data[key].forEach((key, value){
                if (key == 'matricule' || key == 'balance') {
                  matriculeAndBalance[key] = value;
                }
              });
              etudiants[key]=matriculeAndBalance;
            }
          });

          if (mounted) {
            setState(() {
              this.etudiants = etudiants;
            });
          }

        }
      }
    });

    ref1.child('moment').onValue.listen((event) {
      final snapshot = event.snapshot;
      setState(() {
        _selectedValue = snapshot.value as String?;
      });
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    testeConnexion();
    init();
    solde = TextEditingController();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    supprime();
    super.dispose();
  }


  void searchByMatricule(String query) {
    // Vérifiez si le texte de recherche est vide
    if (query.isNotEmpty) {

      // Filtrer les comptes par matricule
      Map<String, dynamic> filteredEtudiants = {};
      etudiants.forEach((key, value) {
        if (value['matricule'].toString().toLowerCase().contains(query.toLowerCase()) || value['matricule'].toString().toLowerCase() == query) {
          filteredEtudiants[key] = value;
        }
      });
      // Mettre à jour l'interface utilisateur avec les comptes filtrés
      setState(() {
        this.etudiants = filteredEtudiants;
      });
      print(this.etudiants);
    } else {
      // Si le texte de recherche est vide, afficher tous les comptes
      init(); // Recharger tous les comptes
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white,), onPressed: () {
          voirDialogueDeco(alerte: alerteDeco("Voulez vous deconnecter", 25));
        },
        ),
        title: const Text("Espace Administrateur", style: TextStyle(color: Colors.white),),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20),
                child:SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ElevatedButton(onPressed: (){
                        Navigator.of(context).push(_routeAddAccount());
                      }, child: Text("ADD ACCOUNT", style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 50),
                            backgroundColor: Colors.blue,
                            elevation: 6
                        ),
                      ),
                      ElevatedButton(onPressed: (){
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return choixMoment();
                          },
                        );
                      }, child: Text("MOMENT", style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 50),
                            backgroundColor: Colors.blue,
                            elevation: 6
                        ),
                      ),
                      ElevatedButton(onPressed: (){
                        Navigator.of(context).push(_routeHistorique());
                      }, child: Text("HISTORIQUE", style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 50),
                            backgroundColor: Colors.blue,
                            elevation: 5
                        ),
                      ),
                    ],
                   ),
                ),
              ),
                const Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: Center(child: Text("Comptes", style: TextStyle(fontSize: 25, color: Color.fromARGB(230, 0, 70, 146) )
                  ),
                  ),
                ),
              TextField(
                controller: searchController, // Supposons que vous utilisez un TextEditingController nommé searchController
                onSubmitted: (query) {
                  searchByMatricule(query); // Appeler la fonction de recherche lors de la soumission du texte
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher par matricule...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear(); // Effacer le texte du champ de recherche
                      searchByMatricule(''); // Réinitialiser la recherche lorsque l'utilisateur appuie sur le bouton pour effacer
                    },
                  ),
                ),
              ),
              (this.etudiants.isEmpty || this.etudiants.length < 1) ? const Text("Aucun compte trouvé") : comptes(),
            ],
          ),
        ),
      ),
    );
  }

  AlertDialog alerteDeco(String texte, double? size) {
    return AlertDialog(
      content: Text(texte, style: TextStyle(fontSize: size, color: Colors.red),
      ),
      backgroundColor: Colors.white,
      actions: [
        Row(
          children: [
            TextButton(onPressed: (){
              Navigator.of(context).push( _routeConnexionLogin());
            }, child: Text("OK", style: TextStyle(color: Colors.red),)),
            TextButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: Text("Annuler", style: TextStyle(color: Colors.blue),))
          ],
        )

      ],
    );

  }

  void voirDialogueDeco({required AlertDialog alerte}){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx){
          return alerte;
        });
  }

  Widget comptes() {
    List<Widget> containers = [];
    if(this.etudiants.length>0){
      this.etudiants.forEach((key, value) {
        List<Widget> columnChildren = [
          Text("$key", style: TextStyle(color: Colors.white)), // Ajouter le texte de la clé en dehors de la boucle interne
        ];

        this.etudiants[key].forEach((key, value) {
          columnChildren.add(
            Text("$key: $value", style: TextStyle(color: Colors.white)),
          );
        });

        containers.add(
          Container(
            color: Color.fromARGB(220, 0, 70, 146),
            margin: EdgeInsets.all(4.0),
            padding: EdgeInsets.all(17.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: columnChildren, // Utiliser la liste de widgets pour enfants de la colonne
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: (){
                        voirDialogueSupp(alerte: alerteSupp(key));
                      },
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        voirDialogue(alerte: alerte(value: key));
                        setState(() {
                          depot = this.etudiants[key]['balance'];
                        });
                      },
                      child: Icon(Icons.monetization_on_rounded, color: Colors.white),
                    ),
                    TextButton(
                      onPressed: (){
                        updateAccount(key);
                      },
                      child: Icon(Icons.info_outline, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });

      // Vérifier si containers est vide
      if (containers.isEmpty) {
        return const Text("Aucun compte trouvé"); // Retourner un widget approprié si la liste est vide
      }

      return Padding(
        padding: const EdgeInsets.only(top: 15),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: containers,
          ),
        )
      );
    }else{
      return const Text("Aucun compte trouvé");
    }


  }


  AlertDialog alerteSupp(String texte) {
    return AlertDialog(
      content: const Text("Voulez vous vraiment le supprimer?", style: TextStyle(fontSize: 18, color: Colors.black87),
      ),
      backgroundColor: Colors.white,
      actions: [
        Row(
          children: [
            TextButton(onPressed: (){
              deleteAccount(texte);
              Navigator.of(context).pop();
            }, child: const Text("OK", style: TextStyle(color: Colors.red),)),
            TextButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: const Text("Annuler", style: TextStyle(color: Colors.blue),))
          ],
        )

      ],
    );

  }

  void voirDialogueSupp({required AlertDialog alerte}){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx){
          return alerte;
        });
  }

  AlertDialog alerte({required String value}) {
    return AlertDialog(
      content: Text(
        value,
        style: TextStyle(fontSize: 16, color: Color.fromARGB(220, 0, 70, 146)),
      ),
      backgroundColor: Colors.white,
      actions: [
        TextFormField(
          controller: solde,
          keyboardType: TextInputType.number,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                if(value.length>=3){
                  updateCompteAdd(value);
                }
                Navigator.of(context).pop();
              },
              child: Text("Ajouter", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                if(value.length>=3) {

                  updateCompteRetire(value);
                }
                Navigator.of(context).pop();
              },
              child: Text("Retirer", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  solde.text='';
                });
                Navigator.of(context).pop();
                final snackBar = SnackBar(content: Text("Mise a jour du solde annuler"), backgroundColor: Color.fromARGB(255, 0, 48, 81),);
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Text("Annuler", style: TextStyle(color: Colors.red)),
            )
          ],
        )
      ],
    );
  }

  void voirDialogue({required AlertDialog alerte}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return alerte;
      },
    );
  }

  AlertDialog choixMoment(){
    return AlertDialog(
      title: Text('Choisissez(moment actuelle $_selectedValue)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: Text('matin'),
            value: 'matin',
            groupValue: _selectedValue,
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
              sendMoment(_selectedValue!);
              Navigator.of(context).pop();
            },
          ),
          RadioListTile<String>(
            title: Text('midi'),
            value: 'midi',
            groupValue: _selectedValue,
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
              sendMoment(_selectedValue!);
              Navigator.of(context).pop();
            },
          ),
          RadioListTile<String>(
            title: Text('soir'),
            value: 'soir',
            groupValue: _selectedValue,
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
              sendMoment(_selectedValue!);
              Navigator.of(context).pop();
            },
          ),
          RadioListTile<String>(
            title: Text('arreter'),
            value: 'arreter',
            groupValue: _selectedValue,
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
              sendMoment(_selectedValue!);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void sendMoment(String value) async{
    final ref3 = FirebaseDatabase.instance.ref("moment");
    await ref3.set(value);
  }

  void updateCompteAdd(String value) async{
    DateTime now = DateTime.now();

    depot = depot! + int.parse(solde.text);

    await ref.child("comptes/$value").update({
      "balance": depot,
    });


    final ref3 = FirebaseDatabase.instance.ref("comptes/$value");

    await ref3.child('historiques').push().set({
      "date": "${now.day}/${now.month}/${now.year}",
      "time" : "${now.hour}:${now.minute}:${now.second}",
      "statut": "depot",
      "montant": int.parse(solde.text),

    });

    setState(() {
      solde.text='';
    });

    final snackBar = SnackBar(content: Text("Mise a jour du solde réussi"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void updateCompteRetire(String value) async{
    DateTime now = DateTime.now();

    if(int.parse(solde.text)<depot!){
      depot = depot! - int.parse(solde.text);

      await ref.child("comptes/$value").update({
        "balance": depot,
      });


      final ref3 = FirebaseDatabase.instance.ref("comptes/$value");

      await ref3.child('historiques').push().set({
        "date": "${now.day}/${now.month}/${now.year}",
        "time" : "${now.hour}:${now.minute}:${now.second}",
        "statut": "erreur d'envoi",
        "montant": -int.parse(solde.text),
      });

      setState(() {
        solde.text='';
      });

      final snackBar = SnackBar(content: Text("Mise a jour du solde réussi"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }else{
      final snackBar = SnackBar(content: Text("Solde inférieure au montant de l'erreur"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }


  }

  void deleteAccount(String value) async{
    if(this.etudiants.length > 1){
      DatabaseReference ref2 = FirebaseDatabase.instance.ref("comptes/$value");

      await ref2.remove();

      final snackBar = SnackBar(content: Text("Comptes supprimer avec succès"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        init();

      });
    }else if(this.etudiants.length==1){
      DatabaseReference ref2 = FirebaseDatabase.instance.ref("comptes/$value");

      await ref2.remove();

      final snackBar = SnackBar(content: Text("Comptes supprimer avec succès"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        init();
        this.etudiants = {};
      });
    }


  }

  Route _routeAddAccount() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AddAccount(),
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

  Route _routeConnexionLogin() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MyHomePage(),
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


  void updateAccount(String valeur) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cardMember', valeur);
    Navigator.push(context, routeUpdateAccount());
  }

  Route routeUpdateAccount() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => UpdateAccount(),
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

  Route _routeHistorique() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Historiques(),
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