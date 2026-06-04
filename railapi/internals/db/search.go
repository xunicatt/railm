// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railapi) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

package db

import (
	"database/sql"
	"fmt"
	"railapi/internals/models"
)

func GetRoutes(db *sql.DB) ([]models.Route, error) {
	rows, err := db.Query(
		`SELECT
			id,
			name
		FROM route;`,
	)
	if err != nil {
		return nil, fmt.Errorf(
			"failed to query 'route' table: %v",
			err.Error(),
		)
	}
	defer rows.Close()

	routes := []models.Route{}
	for rows.Next() {
		route := models.Route{}
		err = rows.Scan(
			&route.Id,
			&route.Name,
		)
		if err != nil {
			return nil, fmt.Errorf(
				"failed to scan row from 'route' table: %v",
				err.Error(),
			)
		}

		routes = append(routes, route)
	}

	return routes, nil
}

func GetStations(db *sql.DB) ([]string, error) {
	rows, err := db.Query(
		`SELECT
			id
		FROM station;`,
	)
	if err != nil {
		return nil, fmt.Errorf(
			"failed to query 'station' table: %v",
			err.Error(),
		)
	}
	defer rows.Close()

	ids := []string{}
	for rows.Next() {
		id := ""
		err = rows.Scan(&id)
		if err != nil {
			return nil, fmt.Errorf(
				"failed to scan row from 'station' table: %v",
				err.Error(),
			)
		}

		ids = append(ids, id)
	}

	return ids, nil
}

func GetStation(db *sql.DB, id string) (*models.Station, error) {
	row := db.QueryRow(
		`SELECT
			name,
			route,
			position
		FROM station
		WHERE
			id == (?1);`,
		id,
	)
	if row.Err() != nil {
		return nil, fmt.Errorf(
			"failed to query 'station' table: %v",
			row.Err().Error(),
		)
	}

	station := &models.Station{
		Id: id,
	}
	err := row.Scan(
		&station.Name,
		&station.Route,
		&station.Position,
	)

	if err == sql.ErrNoRows {
		return nil, nil 
	}

	if err != nil {
		return nil, fmt.Errorf(
			"failed to scan row from 'station' table: %v",
			err.Error(),
		)
	}

	return station, nil
}

func GetStationsInRoute(db *sql.DB, route string) ([]string, error) {
	rows, err := db.Query(
		`SELECT
			id
		FROM station
		WHERE
			route == (?1);`,
		route,
	)
	if err != nil {
		return nil, fmt.Errorf(
			"failed to query 'station' table: %v",
			err.Error(),
		)
	}
	defer rows.Close()

	ids := []string{}
	for rows.Next() {
		id := ""
		err := rows.Scan(&id)
		if err != nil {
			return nil, fmt.Errorf(
				"failed to scan row from 'station' table: %v",
				err.Error(),
			)
		}

		ids = append(ids, id)
	}

	return ids, nil
}

func GetTrains(db *sql.DB) ([]string, error) {
	rows, err := db.Query(
		`SELECT
			number
		FROM train;`,
	)
	if err != nil {
		return nil, fmt.Errorf(
			"failed to query 'train' table: %v",
			err.Error(),
		)
	}
	defer rows.Close()

	numbers := []string{}
	for rows.Next() {
		number := ""
		err = rows.Scan(&number)
		if err != nil {
			return nil, fmt.Errorf(
				"failed to scan row from 'train' table: %v",
				err.Error(),
			)
		}

		numbers = append(numbers, number)
	}

	return numbers, nil
}

func GetTrain(db *sql.DB, number string) (*models.Train, error) {
	row := db.QueryRow(
		`SELECT
			name,
			start,
			end
		FROM train
		WHERE number == (?1);`,
		number,
	)

	if row.Err() != nil {
		return nil, fmt.Errorf(
			"failed to query 'train' table: %v",
			row.Err().Error(),
		)
	}

	train := &models.Train{
		Number: number,
	}
	err := row.Scan(
		&train.Name,
		&train.Start,
		&train.End,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}

	if err != nil {
		return nil, fmt.Errorf(
			"failed to scan row from 'train' table: %v",
			err.Error(),
		)
	}

	rows, err := db.Query(
		`SELECT
			station,
			route,
			arrival,
			departure
		FROM stops
		WHERE
			number == (?1)
		ORDER BY position;`,
		train.Number,
	)
	if err != nil {
		return nil, fmt.Errorf(
			"failed to query 'stops' table: %v",
			err.Error(),
		)
	}
	defer rows.Close()

	stops := []models.TrainStop{}
	for rows.Next() {
		stop := models.TrainStop{}
		err = rows.Scan(
			&stop.Station,
			&stop.Route,
			&stop.Arrival,
			&stop.Departure,
		)
		if err != nil {
			return nil, fmt.Errorf(
				"failed to scan row from 'stop' table: %v",
				err.Error(),
			)
		}

		stops = append(stops, stop)
	}

	train.Stops = stops
	return train, nil
}

func GetTrainsInRoute(db *sql.DB, route string) ([]string, error) {
	rows, err := db.Query(
		`SELECT
			number
		FROM stops
		WHERE
			route == (?1)
		GROUP BY number;`,
		route,
	)
	if err != nil {
		return nil, fmt.Errorf(
			"failed to query 'stops' table: %v",
			err.Error(),
		)
	}
	defer rows.Close()

	numbers := []string{}
	for rows.Next() {
		number := ""
		err = rows.Scan(&number)
		if err != nil {
			return nil, fmt.Errorf(
				"failed to scan row from 'stops' table: %v",
				err.Error(),
			)
		}

		numbers = append(numbers, number)
	}

	return numbers, nil
}

func GetTrainsBetweenStations(db *sql.DB, src, dest string) ([]string, error) {
	rows, err := db.Query(
		`SELECT
			s1.number
		FROM stops s1
		JOIN stops s2
			ON s1.number == s2.number
		WHERE
			s1.station == (?1)
				AND 
			s2.station == (?2)
				AND
			s1.position < s2.position;`,
		src,
		dest,
	)
	if err != nil {
		return nil, fmt.Errorf(
			"failed to query 'stops' table: %v",
			err.Error(),
		)
	}
	defer rows.Close()

	numbers := []string{}
	for rows.Next() {
		number := ""
		err = rows.Scan(&number)
		if err != nil {
			return nil, fmt.Errorf(
				"failed to scan row from 'stops' table: %v",
				err.Error(),
			)
		}

		numbers = append(numbers, number)
	}

	return numbers, nil
}

func GetStatus(db *sql.DB, number string) (*models.Status, error) {
	row := db.QueryRow(
		`SELECT
			station,
			state,
			time
		FROM status
		WHERE number == (?1)`, 
		number,
	)
	if row.Err() != nil {
		return nil, fmt.Errorf(
			"failed to query 'status' table: %v",
			row.Err(),
		)
	}

	status := &models.Status{
		Number: number,
	}
	err := row.Scan(
		&status.Station,
		&status.State,
		&status.Time,
	)
	if err == sql.ErrNoRows {
		return nil, nil 
	}

	if err != nil {
		return nil, fmt.Errorf(
			"failed to scan from 'status' table: %v",
			err.Error(),
		)
	}

	return status, nil
}

func GetTokens(db *sql.DB) ([]string, error) {
	rows, err := db.Query(
		`SELECT token FROM tokens;`,
	)
	if err != nil {
		return nil, fmt.Errorf(
			"failed to query 'token' table: %v",
			err.Error(),
		)
	}
	defer rows.Close()

	tokens := []string{}
	for rows.Next() {
		token := ""
		err = rows.Scan(&token)
		if err != nil {
			return nil, fmt.Errorf(
				"failed to scan row from 'token' table: %v",
				err.Error(),
			)
		}

		tokens = append(tokens, token)
	}

	return tokens, nil
}
