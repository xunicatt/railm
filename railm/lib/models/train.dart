import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:railm/configs/configs.dart';

class TrainStop {
    String station;
    String route;
    String arrival;
    String departure;

    TrainStop(this.station, this.route,
              this.arrival, this.departure);

    factory TrainStop.fromJson(Map<String, dynamic> json) {
        return TrainStop(
            json["station"],
            json["route"],
            json["arrival"],
            json["departure"],
        );
    }
}

class Train {
    String number;
    String name;
    String start;
    String end;
    List<TrainStop> stops;

    Train(this.number, this.name, this.start,
          this.end, this.stops);

    factory Train.fromJson(Map<String, dynamic> json) {
        List<TrainStop> stops = (json["stops"] as List<dynamic>).map(
            (e) => TrainStop.fromJson(e)
        ).toList();

        return Train(
            json["number"],
            json["name"],
            json["start"],
            json["end"],
            stops,
        );
    }

    static Future<List<String>> fetchTrainNumbersBetweenStations(
        String src,
        String dest,
    ) async {
        final String url = "${Configs.baseUrl}/trains/between/$src/$dest";
        var response = await http.get(Uri.parse(url));
        return List<String>.from(jsonDecode(response.body));
    }

    static Future<List<Train>> fetchTrainsBetweenStations(
        String src,
        String dest,
    ) async {
        final String url = "${Configs.baseUrl}/trains";
        final numbers = await fetchTrainNumbersBetweenStations(
            src, dest,
        );

        final futures = numbers.map((number) async {
            final resp = await http.get(Uri.parse("$url/$number"));
            final data = jsonDecode(resp.body);
            return Train.fromJson(data);
        });

        return await Future.wait(futures);
    }
}
