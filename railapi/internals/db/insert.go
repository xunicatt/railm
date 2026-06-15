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

func InsertRoute(sql *sql.DB, route *models.Route) error {
	_, err := sql.Exec(
		`INSERT INTO route(
			id,
			name
		) VALUES (?1, ?2);`,
		route.Id,
		route.Name,
	)
	if err != nil {
		return fmt.Errorf(
			"failed to insert into 'route' table: %v",
			err.Error(),
		)
	}

	return nil
}

func InsertStation(sql *sql.DB, station *models.Station) error {
	_, err := sql.Exec(
		`INSERT INTO station(
			id,
			name,
			route,
			position
		) VALUES (?1, ?2, ?3, ?4);`,
		station.Id,
		station.Name,
		station.Route,
		station.Position,
	)
	if err != nil {
		return fmt.Errorf(
			"failed to insert into 'route' table: %v",
			err.Error(),
		)
	}

	return nil
}

func InsertTrain(sql *sql.DB, train *models.Train) error {
	if len(train.Number) <= 0 {
		return nil
	}

	tx, err := sql.Begin()
	if err != nil {
		return fmt.Errorf(
			"failed to begin transaction to insert 'models.Train': %v",
			err.Error(),
		)
	}
	defer tx.Rollback()

	_, err = tx.Exec(
		`INSERT INTO train(
			number,
			name,
			start,
			end
		) VALUES (?1, ?2, ?3, ?4);`,
		train.Number,
		train.Name,
		train.Start,
		train.End,
	)
	if err != nil {
		return fmt.Errorf(
			"failed to insert into 'train' table: %v",
			err.Error(),
		)
	}

	for i, stop := range train.Stops {
		_, err = tx.Exec(
			`INSERT INTO stops(
				number,
				route,
				station,
				arrival,
				departure,
				position	
			) VALUES (?1, ?2, ?3, ?4, ?5, ?6);`,
			train.Number,
			stop.Route,
			stop.Station,
			stop.Arrival,
			stop.Departure,
			i,
		)
		if err != nil {
			return fmt.Errorf(
				"failed to insert into 'stops' table: %v",
				err.Error(),
			)
		}
	}

	err = tx.Commit()
	if err != nil {
		return fmt.Errorf(
			"failed to commit transaction to insert 'models.Train': %v",
			err.Error(),
		)
	}

	return nil
}

func InsertStatus(db *sql.DB, status *models.Status) error {
	_, err := db.Exec(
		`INSERT INTO status(
			number,
			station,
			time
		) values (?1, ?2, ?3);`,
		status.Number,
		status.Station,
		status.Time,
	)
	if err != nil {
		return fmt.Errorf(
			"failed to insert into 'status' table: %v",
			err.Error(),
		)
	}

	return nil
}

func InsertToken(db *sql.DB, token string) error {
	_, err := db.Exec(
		`INSERT INTO tokens(
			token
		) VALUES (?1);`,
		token,
	)
	if err != nil {
		return fmt.Errorf(
			"failed to insert into 'token' table: %v",
			err.Error(),
		)
	}

	return nil
}
