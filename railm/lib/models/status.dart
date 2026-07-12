// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:railm/configs/configs.dart';

class Status {
    final String number;
    final String station;
    final String time;

    const Status({
        required this.number,
        required this.station,
        required this.time,
    });

    factory Status.fromJson(Map<String, dynamic> json) {
        return Status(
            number: json["number"],
            station: json["station"],
            time: json["time"],
        );
    }

    static Future<Status?> fetchStatus(String number) async {
        final String url = "${Configs.railApiBaseUrl}/status/$number?auth=${Configs.railApiToken}";
        var response = await http.get(Uri.parse(url));
        var data = jsonDecode(response.body) as Map<String, dynamic>;

        if ((data.containsKey("status") && data["status"] == "failed") ||
                (data.containsKey("reason") && data["reason"] == "unknown")) {
            return null; 
        }

        return Status.fromJson(data);
    }

    static Future<bool> updateStatus(String trainNumber, String stationId, String time) async {
        final String url = "${Configs.railApiBaseUrl}/status/$trainNumber/$stationId?auth=${Configs.railApiToken}&time=$time";
        var response = await http.post(Uri.parse(url));
        var data = jsonDecode(response.body) as Map<String, dynamic>;

        return data.containsKey("status") && data["status"] == "success";
    }
}
