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

func UpdateStatus(sql *sql.DB, status *models.Status) error {
	_, err := sql.Exec(
	   `UPDATE status
		SET
			station = (?1),
			state = (?2),
			time = (?3),
		WHERE number == (?4);`,
		status.Station,
		status.State,
		status.Time,
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
