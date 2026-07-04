import 'package:railm/components/map.dart';

class SearchHistory {
   final MapData mapData; 
   final String srcStationId;
   final String trainNumber;

   const SearchHistory({
        required this.mapData,
        required this.srcStationId,
        required this.trainNumber,
   });

   Map<String, dynamic> toMap() {
        return {
            'map-data': mapData.toMap(),
            'src-station-id': srcStationId,
            'train-number': trainNumber,
        };
   }

   factory SearchHistory.fromMap(Map<String, dynamic> map) {
        return SearchHistory(
            mapData: MapData.fromMap(map['map-data']),
            srcStationId: map['src-station-id'],
            trainNumber: map['train-number'],
        );
   }
}
