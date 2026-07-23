#!/usr/bin/env python3

# SPDX-License-Identifier: GPL-2.0
# Author: xunicatt
# Project: railm (railapi) 
# Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

# By default no database is bundled with the server.
# Just to play with the server, we need some kind of dummy
# database.
#
# Here comes the python script to RESCUE! ^._.^
# Run this script with the test data json file to add some
# test data to the server's database!
#
# usage: ./data/add.py ./data/test-data.json
#
# This script is solely made for testing purposes.

import json
import sys
import requests
from typing import TypedDict, Any

class Route(TypedDict):
    id: str
    name: str

class Station(TypedDict):
    id: str
    name: str
    route: str
    position: int

class TrainStops(TypedDict):
    station: str
    route: str
    arrival: str
    departure: str


class Train(TypedDict):
    number: str
    name: str
    start: int
    end: int
    stops: list[TrainStops]

Payload = Route | Station | Train

def insert(url: str, token: str, key: str, data: Payload) -> bool:
    resp = requests.post(
        f"{url}/{key}",
        headers={"Authorization": f"Token {token}"},
        json=json.dumps(data),
    )

    if resp.status_code != 200:
        raise Exception(f"got code: {resp.status_code}")

    obj: dict[str, str] = resp.json()
    if obj["status"] != "success":
        print("Error: ", obj["reason"])
        return False

    return True

def insert_routes(url: str, token: str, routes: list[Route]):
    for route in routes:
        if not insert(url, token, "routes", route):
            raise Exception("failed to send request")

def insert_station(url: str, token: str, stations: list[Station]):
    for station in stations:
        if not insert(url, token, "stations", station):
            raise Exception("failed to send request")

def insert_trains(url: str, token: str, trains: list[Train]):
    for train in trains:
        if not insert(url, token, "trains", train):
            raise Exception("failed to send request")

def main() -> None:
    argv = sys.argv
    argc = len(argv)

    if (argc != 4):
        print(f"usage: {argv[0]} <url> <token> <file-name>.json")
        exit(1)

    url = argv[1]
    token = argv[2]

    try:
        with open(sys.argv[3], encoding="utf-8") as file:
            data: dict[str, list[Any]] = json.load(file)
            for key, value in data.items():
                match key:
                    case "routes":
                        insert_routes(url, token, value)
                    case "stations":
                        insert_station(url, token, value)
                    case "trains":
                        insert_trains(url, token, value)
                    case _:
                        pass

    except Exception as e:
        print(f"[ERROR] {e}")

if __name__ == "__main__":
    main()
