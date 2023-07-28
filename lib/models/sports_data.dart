import 'package:firebase_database/firebase_database.dart';

enum SportType {
  soccerGirls,
  soccerBoys,
  volleyballMixed
}

class SportsResults {
  final Map<SportType, List<SportsResult>> resultMap = {};

  static final Map<String, SportType> sportNames = {
    "Lány Foci": SportType.soccerGirls,
    "Fiú Foci": SportType.soccerBoys,
    "Röpi": SportType.volleyballMixed
  };
  static final Map<SportType, String> sportTypes = {
    SportType.soccerGirls: "Lány Foci",
    SportType.soccerBoys: "Fiú Foci",
    SportType.volleyballMixed: "Röpi"
  };

  static String getSportName(SportType sportType)
  {
    return sportTypes[sportType]!;
  }

  static SportType getSportType(String sportName)
  {
    return sportNames[sportName]!;
  }


  SportsResults.fromSnapshot(DataSnapshot snapshot)
  {
    for(DataSnapshot child in snapshot.children)
      {
        resultMap[sportNames[child.key]!] = [];
        for(DataSnapshot resultChild in child.children)
          {
            resultMap[sportNames[child.key]!]!.add(SportsResult.fromSnapshot(resultChild));
          }
      }
  }
}

class SportsResult {
  final int team1;
  final int team2;
  final int team1Score;
  final int team2Score;
  late bool draw;
  late int winner;
  late String MVP;
  late String id;
  SportsResult(this.team1, this.team2, this.team1Score, this.team2Score, this.MVP, {draw, winner=-1})
  {
    id = "$team1 _ $team2";
    if(draw == null)
    {
      this.draw = (team1Score == team2Score);
    }
    else{
      this.draw = draw;
    }
    if(winner == -1)
      {
        this.winner = this.draw ? -1 : team1Score > team2Score ? team1 : team2;
      }
    else{
      this.winner = winner;
    }
  }

  SportsResult.fromSnapshot(DataSnapshot snapshot):
        team1 = int.parse(snapshot.child("team1").value.toString()),
        team2 = int.parse(snapshot.child("team2").value.toString()),
        team1Score = int.parse(snapshot.child("team1Score").value.toString()),
        team2Score = int.parse(snapshot.child("team2Score").value.toString()),
        draw = bool.parse(snapshot.child("draw").value.toString()),
        winner = int.parse(snapshot.child("winner").value.toString()),
        MVP = snapshot.child("MVP").value.toString(),
        id = snapshot.key.toString();

  Map<String, dynamic> toJson() => {
    'team1': team1,
    'team2': team2,
    'team1Score': team1Score,
    'team2Score': team2Score,
    'draw': draw,
    'winner': winner,
    'MVP': MVP
  };
}