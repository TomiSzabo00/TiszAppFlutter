import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:tiszapp_flutter/models/sports_data.dart';
import 'package:tiszapp_flutter/services/api_service.dart';

import '../models/user_data.dart';
import '../services/database_service.dart';

class SportsViewModel with ChangeNotifier {

  late SportsResults sportsResults;
  bool initializedResults = false;
  late String sportType;
  bool initializedSportType = false;
  late int team1;
  late int team2;
  bool initializedTeam1 = false;
  bool initializedTeam2 = false;
  final team1ScoreController = TextEditingController();
  final team2ScoreController = TextEditingController();
  final MVPController = TextEditingController();
  UserData user = UserData(uid: "", name: "", isAdmin: false, teamNum: -1);
  Map<int, List<String>> teams = {};
  void getData() async {
    final databaseref = FirebaseDatabase.instance.ref().child(
        'sports');
    databaseref.onValue.listen((event) {
      sportsResults = SportsResults.fromSnapshot(event.snapshot);
      initializedResults = true;
      getTeams();
      notifyListeners();
    });
  }

  Future<void> getTeams() async {
    final users = await ApiService.getUserInfos();
    for(var user in users)
      {
        if(user.teamNum == 0)
        {
          continue;
        }
        if(teams.containsKey(user.teamNum))
        {
          if(!teams[user.teamNum]!.contains(user.name))
          {
            teams[user.teamNum]!.add(user.name);
          }
        }
        else
        {
          teams[user.teamNum] = [user.name];
        }
      }
    for(var entry in teams.entries)
    {
      teams[entry.key]!.sort();
    }
  }

  void uploadResult() {
    final sportsResult = SportsResult(
        team1, team2,
        int.parse(team1ScoreController.value.text),
        int.parse(team2ScoreController.value.text),
        MVPController.value.text);
    var ref = FirebaseDatabase.instance.ref().child("sports");
    final key = sportType;
    ref.child(key).child(sportsResult.id).set(sportsResult.toJson());
    clearControllers();
  }

  void clearControllers() {
    team1ScoreController.clear();
    team2ScoreController.clear();
    MVPController.clear();
    initializedTeam1 = false;
    initializedTeam2 = false;
    initializedSportType = false;
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
    sports.sort();
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
    availableTeams.sort();
    return availableTeams;
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

  String getResult(int indexRow, int indexCol, String sport) {
    final results = sportsResults.resultMap[SportsResults.getSportType(sport)];
    if(indexRow == indexCol)
      {
        return "X";
      }
    for(var result in results!)
      {
        if((result.team1 == indexRow && result.team2 == indexCol))
          {
            return "${result.team1Score} - ${result.team2Score}";
          }
        else if((result.team2== indexRow && result.team1 == indexCol))
        {
          return "${result.team2Score} - ${result.team1Score}";
        }
      }
    return "?";
  }
}