// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railapi) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

package db

import (
	"database/sql"
	"fmt"
)

func Init(sql *sql.DB) error {
	err := createRouteTable(sql)
	if err != nil {
		return fmt.Errorf(
			"failed to create 'route' table: %v",
			err.Error(),
		)
	}

	err = createStationTable(sql)
	if err != nil {
		return fmt.Errorf(
			"failed to create 'station' table: %v",
			err.Error(),
		)
	}

	err = createTrainTable(sql)
	if err != nil {
		return fmt.Errorf(
			"failed to create 'train' table: %v",
			err.Error(),
		)
	}

	err = createStatusTable(sql)
	if err != nil {
		return fmt.Errorf(
			"failed to create 'status' table: %v",
			err.Error(),
		)
	}

	err = createTokenTable(sql)
	if err != nil {
		return fmt.Errorf(
			"failed to create 'token' table: %v",
			err.Error(),
		)
	}

	return nil
}
