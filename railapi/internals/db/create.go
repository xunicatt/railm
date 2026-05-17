package db

import "database/sql"

func createRouteTable(sql *sql.DB) error {
	_, err := sql.Exec(
		`CREATE TABLE IF NOT EXISTS route(
			id TEXT PRIMARY KEY NOT NULL,
			name TEXT
		);`,
	);
	return err
}

func createStationTable(sql *sql.DB) error {
	_, err := sql.Exec(
		`CREATE TABLE IF NOT EXISTS station(
			id TEXT PRIMARY KEY NOT NULL,
			name TEXT,
			route TEXT,
			position INTEGER,

			FOREIGN KEY(route) REFERENCES route(id)
		);`,
	)
	return err
}

func createTrainTable(sql *sql.DB) error {
	_, err := sql.Exec(
		`CREATE TABLE IF NOT EXISTS train(
			number TEXT PRIMARY KEY NOT NULL,
			name TEXT,
			start TEXT,
			end TEXT
		);`,
	)
	if err != nil {
		return err
	}

	_, err = sql.Exec(
		`CREATE TABLE IF NOT EXISTS stops(
			number TEXT,
			route TEXT,
			station TEXT,
			arrival TEXT,
			departure TEXT,
			position INTEGER,

			PRIMARY KEY (number, route, station),

			FOREIGN KEY (number)  REFERENCES train(number),
			FOREIGN KEY (station) REFERENCES station(id),
			FOREIGN KEY (route)   REFERENCES route(id)
		);`,
	)
	return err
}

func CreateStatusTable(sql *sql.DB) error {
	_, err := sql.Exec(
		`CREATE TABLE IF NOT EXISTS status(
			number TEXT PRIMARY KEY NOT NULL,
			station TEXT,
			status INTEGER,

			FOREIGN KEY(number) REFERENCES train(number),
			FOREIGN KEY(station) REFERENCES station(id)
		);`,
	)
	return err
}
