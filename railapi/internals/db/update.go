package db

import (
	"database/sql"
	"fmt"
	"railapi/internals/models"
)

func UpdateStatus(db *sql.DB, status *models.Status) error {
	_, err := db.Exec(
	   `UPDATE status
		SET
			station = (?1),
			state = (?2)
		WHERE number == (?3);`,
		status.Station,
		status.State,
		status.Number,
	)

	if err != nil {
		return fmt.Errorf(
			"failed to update 'status' table: %v",
			err.Error(),
		)
	}

	return nil
}
