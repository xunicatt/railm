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

	err = CreateStatusTable(sql)
	if err != nil {
		return fmt.Errorf(
			"failed to create 'status' table: %v",
			err.Error(),
		)
	}

	err = resetStatusTable(sql)
	if err != nil {
		return fmt.Errorf(
			"failed to reset 'status' table: %v",
			err.Error(),
		)
	}

	return nil
}
