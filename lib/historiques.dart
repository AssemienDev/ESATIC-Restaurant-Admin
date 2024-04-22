import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'acceuil_admin.dart';



class Historiques extends StatefulWidget{
  @override
  StateHistorique createState() => StateHistorique();
}
class StateHistorique extends State<Historiques>{

  Map<String, dynamic>? etudiants = {};
  int? depot=0;
  int? achat=0;

  // Analyser la clé de date/heure dans un format spécifique
  DateTime parseDateTime(String dateTimeString) {
    List<String> dateTimeParts = dateTimeString.split(' ');
    String dateString = dateTimeParts[0];
    String timeString = dateTimeParts[1];

    List<String> dateParts = dateString.split('/');
    List<String> timeParts = timeString.split(':');

    int year = int.parse(dateParts[2]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[0]);
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2]);

    return DateTime(year, month, day, hour, minute, second);
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await salt();
    }
  }


  void listTransactionsOfTheDay() async {
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
              if (value is Map && value['historiques'] is Map) {
                Map<dynamic, dynamic> historiques = value['historiques'];
                historiques.forEach((historiqueKey, historiqueValue) {
                  if (historiqueKey is String && historiqueValue is Map) {
                    List<String> sortedKeys = historiqueKey.split(',').map((e) => e.trim()).toList()..sort();
                    for (int i = sortedKeys.length - 1; i >= 0; i--) {
                      matriculeAndBalance[sortedKeys[i]] = historiqueValue;
                    }
                  }
                });
              }
              etudiants.addAll(matriculeAndBalance);
            }
          });

          List<String> sortedKeys = etudiants.keys.toList();

          // Récupérer la date actuelle
          DateTime currentDate = selectedDate;


          List<String>? filteredKeys = sortedKeys?.where((key) {
            DateTime dateTime = parseDateTime('${etudiants?[key]['date']} ${etudiants?[key]['time']}');
            return dateTime.year == currentDate.year && dateTime.month == currentDate.month && dateTime.day == currentDate.day;
          }).toList();

          Map<String, dynamic> sortedEtudiants = {};
          for (int i = filteredKeys!.length - 1; i >= 0; i--) {
            String key = filteredKeys[i];
            sortedEtudiants[key] = etudiants?[key];
          }



          List depot = [];
          List achat = [];

          sortedEtudiants.forEach((key, value) {
            value.forEach((innerKey, innerValue) {
              if (innerValue == "depot") {
                var montant = sortedEtudiants[key]["montant"];
                depot.add(montant);
              }
            });
          });


          sortedEtudiants.forEach((key, value) {
            value.forEach((innerKey, innerValue) {
              if (innerValue == "Achat") {
                var montant = sortedEtudiants[key]["montant"];
                achat.add(montant);
              }
            });
          });

          int sommeDepot = 0;
          int sommeAchat = 0;

          for (int element in depot) {
            sommeDepot += element;
          }

          for (int element in achat) {
            sommeAchat += element;
          }



          if (mounted) {
            setState(() {
              this.etudiants = sortedEtudiants; // Mettez à jour l'état avec les données triées
              this.depot = sommeDepot;
              this.achat = sommeAchat;
            });
          }


        }
      }
    });
  }

  Future<void> salt() async{
    final ref1 = FirebaseDatabase.instance.ref();
    final snapshot = await ref1.child('comptes').get();
    if (snapshot.exists) {
      if (snapshot.value != null) {
        Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;

        Map<String, dynamic> data = {};
        Map<String, dynamic> etudiants = {};

        rawData.forEach((key, value) {
          if (key is String) {
            data[key] = value;
            Map<String, dynamic> matriculeAndBalance = {};
            if (value is Map && value['historiques'] is Map) {
              Map<dynamic, dynamic> historiques = value['historiques'];
              historiques.forEach((historiqueKey, historiqueValue) {
                if (historiqueKey is String && historiqueValue is Map) {
                  List<String> sortedKeys = historiqueKey.split(',').map((e) =>
                      e.trim()).toList()
                    ..sort();
                  for (int i = sortedKeys.length - 1; i >= 0; i--) {
                    matriculeAndBalance[sortedKeys[i]] = historiqueValue;
                  }
                }
              });
            }
            etudiants.addAll(matriculeAndBalance);
          }
        });

        List<String>? sortedKeys = etudiants?.keys.toList();

        // Récupérer la date actuelle
        DateTime currentDate = selectedDate;


        List<String>? filteredKeys = sortedKeys?.where((key) {
          DateTime dateTime = parseDateTime(
              '${etudiants?[key]['date']} ${etudiants?[key]['time']}');
          return dateTime.year == currentDate.year &&
              dateTime.month == currentDate.month &&
              dateTime.day == currentDate.day;
        }).toList();

        Map<String, dynamic> sortedEtudiants = {};
        for (int i = filteredKeys!.length - 1; i >= 0; i--) {
          String key = filteredKeys[i];
          sortedEtudiants[key] = etudiants?[key];
        }

        List depot = [];
        List achat = [];

        sortedEtudiants.forEach((key, value) {
          value.forEach((innerKey, innerValue) {
            if (innerValue == "depot") {
              var montant = sortedEtudiants[key]["montant"];
              depot.add(montant);
            }
          });
        });


        sortedEtudiants.forEach((key, value) {
          value.forEach((innerKey, innerValue) {
            if (innerValue == "Achat") {
              var montant = sortedEtudiants[key]["montant"];
              achat.add(montant);
            }
          });
        });

        int sommeDepot = 0;
        int sommeAchat = 0;

        for (int element in depot) {
          sommeDepot += element;
        }

        for (int element in achat) {
          sommeAchat += element;
        }


        if (mounted) {
          setState(() {
            this.etudiants =
                sortedEtudiants; // Mettez à jour l'état avec les données triées
            this.depot = sommeDepot;
            this.achat = sommeAchat;
          });
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listTransactionsOfTheDay();
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
          title: const Text("Historique d'activité", style: TextStyle(color: Colors.white),),
        ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 15),child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Historiques", style: TextStyle(
                                fontSize: 20
                            ),
                            ),
                            Padding(padding: EdgeInsets.only(left: 40),
                              child: ElevatedButton(
                                onPressed: () => _selectDate(context),
                                child: Text('Choisir une date',style: TextStyle(
                                    color: Colors.white
                                ),),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                     SingleChildScrollView(
                       padding: EdgeInsets.only(top: 20),
                       scrollDirection: Axis.horizontal,
                       child:  Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text("Totals: ${etudiants?.length}", style: const TextStyle(
                               fontSize: 16
                           ),
                           ),
                           Text("   Depot(frcfa): $depot", style: const TextStyle(
                               fontSize: 16
                           ),
                           ),
                           Text("   Achat(frcfa): $achat", style: const TextStyle(
                               fontSize: 16
                           ),
                           ),
                         ],
                       ),
                     )
                    ],
                ),
              )
              ),
              Padding(padding: EdgeInsets.only(top: 20), child: Text(DateFormat('dd-MM-yyyy').format(selectedDate), style: TextStyle(fontSize: 17),)),
              Padding(padding: EdgeInsets.only(top: 15),
              child: Column(
                children: [
                  historiques()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget historiques() {
    List<Widget> containers = [];
    if(etudiants!.isNotEmpty){
      etudiants?.forEach((key, value) {
        List<Widget> columnChildren = [];

        this.etudiants?[key].forEach((key, value) {
          columnChildren.add(
            Text(" $key: $value", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          );
        });

        containers.add(
          Container(
            color: Color.fromARGB(220, 0, 70, 146),
            margin: EdgeInsets.all(4.0),
            padding: EdgeInsets.all(17.0),
            width: MediaQuery.of(context).size.width/1.15,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
               SingleChildScrollView(
                 scrollDirection: Axis.horizontal,
                 child:  Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: columnChildren, // Utiliser la liste de widgets pour enfants de la colonne
                 ),
               )
              ],
            ),
          ),
        );
      });

      // Vérifier si containers est vide
      if (containers.isEmpty) {
        return const Text("Aucun achat trouvé", style: TextStyle(
          fontSize: 30
        ),); // Retourner un widget approprié si la liste est vide
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
      return const Text("Aucun achat trouvé", style: TextStyle(
          fontSize: 25
      ),);
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