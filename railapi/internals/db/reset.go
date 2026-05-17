package db

import "database/sql"

func resetStatusTable(sql *sql.DB) error {
	_, err := sql.Exec(`DELETE FROM status;`)
	return err;
}
