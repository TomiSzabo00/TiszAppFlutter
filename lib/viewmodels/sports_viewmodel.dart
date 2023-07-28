import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:tiszapp_flutter/models/sports_data.dart';

import '../models/user_data.dart';
import '../services/database_service.dart';

class SportsViewModel with ChangeNotifier {

  late SportsResults sportsResults;
  late String sportType;
  bool initializedSportType = false;
  late int team1;
  late int team2;
  bool initializedTeam1 = false;
  bool initializedTeam2 = false;
  final team1ScoreController = TextEditingController();
  final team2ScoreController = TextEditingController();
  late String MVP;
  bool initializedMVP = false;
  UserData user = UserData(uid: "", name: "", isAdmin: false, teamNum: -1);
  Map<int, List<String>> teams = {};
  void getData() async {
    final databaseref = FirebaseDatabase.instance.ref().child(
        'sports');
    databaseref.onValue.listen((event) {
      sportsResults = SportsResults.fromSnapshot(event.snapshot);
      getTeams();
      notifyListeners();
    });
  }

  Future<void> getTeams() async {
    await FirebaseDatabase.instance.ref().child("users").get().then((snapshot) {
      for (DataSnapshot user in snapshot.children) {
        final name = user.child("userName").value!.toString();
        final groupNr = int.parse(user.child("groupNumber").value!.toString());
        if(groupNr == 0)
          {
            continue;
          }
        if(teams.containsKey(groupNr))
          {
            teams[groupNr]!.add("$groupNr - $name");
          }
        else
          {
            teams[groupNr] = [name];
          }
      }
      for(var entry in teams.entries)
        {
          teams[entry.key]!.sort();
        }
    });
  }

  void uploadResult() {
    final sportsResult = SportsResult(
        team1, team2,
        int.parse(team1ScoreController.value.text),
        int.parse(team1ScoreController.value.text),
        MVP);
    var ref = FirebaseDatabase.instance.ref().child("sports");
    final key = sportType;
    ref.child(key).child(sportsResult.id).set(sportsResult.toJson());
    _clearControllers();
  }

  void _clearControllers() {
    team1ScoreController.clear();
    team2ScoreController.clear();
    notifyListeners();
  }

  void chooseSport(String? s) {
    if(s != null)
      {
        sportType = s;
        initializedSportType = true;
      }
    notifyListeners();
  }

  List<String> getAvailableSports() {
    List<String> sports = [];
    for(var type in SportType.values)
      {
        sports.add(SportsResults.getSportName(type));
      }
    return sports;
  }

  chooseTeam(int? s, int i) {
    if(s != null){
      if(i == 1){
        team1 = s;
        initializedTeam1 = true;
      }
      else {
        team2 = s;
        initializedTeam2 = true;
      }
    }
    notifyListeners();
  }

  List<int> getAvailableTeams(int i) {
    List<int> availableTeams = [];
    final otherTeam = i == 2 ? initializedTeam1 ? team1 : -1 : initializedTeam2 ? team2 : -1;
    for(var team in teams.keys)
      {
        if(team != otherTeam) {
          availableTeams.add(team);
        }
      }
    return availableTeams;
  }

  chooseMVP(String? s) {
    if(s != null)
    {
      MVP = s;
      initializedMVP = true;
    }
    notifyListeners();
  }

  List<String> getAvailablePlayers() {
    List<String> players = [];
    if(initializedTeam1)
    {
      for(final player in teams[team1]!)
      {
        players.add(player);
      }
    }
    if(initializedTeam2)
      {
        for(final player in teams[team2]!)
        {
          players.add(player);
        }
      }
    return players;
  }
  Future<int> getNumberOfTeams() async {
    final num = await DatabaseService.getNumberOfTeams();
    notifyListeners();
    return num;
  }
}