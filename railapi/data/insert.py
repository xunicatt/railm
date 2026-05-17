#!/usr/bin/env python3

# Author: xunicatt
#
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

URL = "http://localhost:8080"

def insert(key: str, data: Payload) -> bool:
    resp = requests.post(
        f"{URL}/add/{key}",
        json=data
    )

    obj: dict[str, str] = resp.json()
    if obj["status"] != "success":
        print("Error: ", obj["reason"])
        return False

    return True

def insert_routes(routes: list[Route]):
    for route in routes:
        if not insert("route", route):
            raise Exception("failed to send request")

def insert_station(stations: list[Station]):
    for station in stations:
        if not insert("station", station):
            raise Exception("failed to send request")

def insert_trains(trains: list[Train]):
    for train in trains:
        if not insert("train", train):
            raise Exception("failed to send request")

def main() -> None:
    argv = sys.argv
    argc = len(argv)

    if (argc != 2):
        print(f"usage: {argv[0]} <file-name>.json")
        exit(1)

    try:
        with open(sys.argv[1], encoding="utf-8") as file:
            data: dict[str, list[Any]] = json.load(file)
            for key, value in data.items():
                match key:
                    case "routes":
                        insert_routes(value)
                    case "stations":
                        insert_station(value)
                    case "trains":
                        insert_trains(value)
                    case _:
                        pass

    except Exception as e:
        print(f"[ERROR] {e}")

if __name__ == "__main__":
    main()
