import 'package:flutter/cupertino.dart';
import 'package:tiszapp_flutter/models/sports_data.dart';
import 'package:tiszapp_flutter/services/api_service.dart';

import '../models/user_data.dart';
import '../services/database_service.dart';

class SportsViewModel with ChangeNotifier {
  late AvailableSports availableSports;
  bool sportsInitialized = false;
  late AllGroups allGroups;
  bool groupsInitialized = false;
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
  UserData user = UserData.empty();
  Map<int, List<String>> teams = {};
  void getData() async {
    final databaseref_sports_results = DatabaseService.database.child('sports');
    databaseref_sports_results.onValue.listen((event) {
      sportsResults = SportsResults.fromSnapshot(event.snapshot);
      initializedResults = true;
      getTeams();
      notifyListeners();
    });
    final databaseref_available_sports =
        DatabaseService.database.child('available_sports');
    databaseref_available_sports.onValue.listen((event) {
      availableSports = AvailableSports.fromSnapshot(event.snapshot);
      sportsInitialized = true;
      notifyListeners();
    });
    final databaseref_all_groups =
        DatabaseService.database.child('sport_groups');
    databaseref_all_groups.onValue.listen((event) {
      allGroups = AllGroups.fromSnapshot(event.snapshot);
      groupsInitialized = true;
      notifyListeners();
    });
  }

  Future<void> getTeams() async {
    final users = await ApiService.getUserInfos();
    for (var user in users) {
      if (user.teamNum == 0) {
        continue;
      }
      if (teams.containsKey(user.teamNum)) {
        if (!teams[user.teamNum]!.contains(user.name)) {
          teams[user.teamNum]!.add(user.name);
        }
      } else {
        teams[user.teamNum] = [user.name];
      }
    }
    for (var entry in teams.entries) {
      teams[entry.key]!.sort();
    }
  }

  void uploadResult() {
    final sportsResult = SportsResult(
        team1,
        team2,
        int.parse(team1ScoreController.value.text),
        int.parse(team2ScoreController.value.text),
        MVPController.value.text);
    var ref = DatabaseService.database.child("sports");
    final key = sportType;
    ref.child(key).child(sportsResult.id).set(sportsResult.toJson());
    clearControllers();
  }

  void clearControllers({dispose = false}) {
    team1ScoreController.clear();
    team2ScoreController.clear();
    MVPController.clear();
    initializedTeam1 = false;
    initializedTeam2 = false;
    initializedSportType = false;
    sportsInitialized = false;
    groupsInitialized = false;
    if (!dispose) {
      notifyListeners();
    }
  }

  void chooseSport(String? s) {
    if (s != null) {
      sportType = s;
      initializedSportType = true;
    }
    notifyListeners();
  }

  List<String> getAvailableSports() {
    List<String> sports = [];
    if (!sportsInitialized) return [];
    for (var type in availableSports.availableSports) {
      sports.add(type);
    }
    sports.sort();
    return sports;
  }

  chooseTeam(int? s, int i) {
    if (s != null) {
      if (i == 1) {
        team1 = s;
        initializedTeam1 = true;
      } else {
        team2 = s;
        initializedTeam2 = true;
      }
    }
    notifyListeners();
  }

  List<int> getAvailableTeams(int i) {
    List<int> availableTeams = [];
    final otherTeam = i == 2
        ? initializedTeam1
            ? team1
            : -1
        : initializedTeam2
            ? team2
            : -1;
    for (var team in teams.keys) {
      if (team != otherTeam) {
        availableTeams.add(team);
      }
    }
    availableTeams.sort();
    return availableTeams;
  }

  List<String> getAvailablePlayers() {
    List<String> players = [];
    if (initializedTeam1) {
      for (final player in teams[team1]!) {
        players.add(player);
      }
    }
    if (initializedTeam2) {
      for (final player in teams[team2]!) {
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

  String getResult(int indexRow, int indexCol, String sport, int groupIndex) {
    final results = sportsResults.resultMap[sport];
    if (indexRow == indexCol) {
      return "X";
    }
    indexRow =
        allGroups.allGroups[sport]!.groups[groupIndex].teams[indexRow - 1];
    indexCol =
        allGroups.allGroups[sport]!.groups[groupIndex].teams[indexCol - 1];
    if (results == null || results.isEmpty) {
      return "?";
    }
    for (var result in results) {
      if ((result.team1 == indexRow && result.team2 == indexCol)) {
        return "${result.team1Score} - ${result.team2Score}";
      } else if ((result.team2 == indexRow && result.team1 == indexCol)) {
        return "${result.team2Score} - ${result.team1Score}";
      }
    }
    return "?";
  }

  String getStats(
      int sportIndex, int groupIndex, int indexPlace, int attrIndex) {
    if (!initializedResults || !sportsInitialized || !groupsInitialized) {
      return "?";
    }
    if (attrIndex == 0) {
      return indexPlace.toString();
    }
    final chosenSport = availableSports.availableSports[sportIndex];
    final teams_ = List<int>.from(
        allGroups.allGroups[chosenSport]!.groups[groupIndex].teams);
    final groupStats = {};
    final stats = ["goals_for", "goals_against", "goal_difference", "points"];
    for (var result in sportsResults.resultMap[chosenSport]!) {
      if (teams_.contains(result.team1) && teams_.contains(result.team2)) {
        if (groupStats.containsKey(result.team1)) {
          groupStats[result.team1]["points"] += result.draw
              ? 1
              : result.team1Score > result.team2Score
                  ? 3
                  : 0;
          groupStats[result.team1]["goals_for"] += result.team1Score;
          groupStats[result.team1]["goals_against"] += result.team2Score;
          groupStats[result.team1]["goal_difference"] +=
              result.team1Score - result.team2Score;
        } else {
          groupStats[result.team1] = {
            "points": result.draw
                ? 1
                : result.team1Score > result.team2Score
                    ? 3
                    : 0,
            "goals_for": result.team1Score,
            "goals_against": result.team2Score,
            "goal_difference": result.team1Score - result.team2Score
          };
        }
        if (groupStats.containsKey(result.team2)) {
          groupStats[result.team2]["points"] += result.draw
              ? 1
              : result.team2Score > result.team1Score
                  ? 3
                  : 0;
          groupStats[result.team2]["goals_for"] += result.team2Score;
          groupStats[result.team2]["goals_against"] += result.team1Score;
          groupStats[result.team2]["goal_difference"] +=
              result.team2Score - result.team1Score;
        } else {
          groupStats[result.team2] = {
            "points": result.draw
                ? 1
                : result.team2Score > result.team1Score
                    ? 3
                    : 0,
            "goals_for": result.team2Score,
            "goals_against": result.team1Score,
            "goal_difference": result.team2Score - result.team1Score
          };
        }
      }
    }
    teams_.sort((int team1, int team2) {
      if (!groupStats.containsKey(team2)) {
        return -1;
      } else if (!groupStats.containsKey(team1)) {
        return 1;
      }
      return -groupStats[team1]["points"]
          .compareTo(groupStats[team2]["points"]);
    });
    if (attrIndex == 1) {
      return teams_[indexPlace - 1].toString();
    }
    if (!groupStats.containsKey(teams_[indexPlace - 1])) {
      return "0";
    }
    return groupStats[teams_[indexPlace - 1]][stats[attrIndex - 2]].toString();
  }
}
