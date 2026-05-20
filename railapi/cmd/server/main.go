// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railapi) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

package main

import (
	"log"
	"os"
	"railapi/internals/app"
)

const (
	DB_PATH = "database.db"
	RANK_THRESHOLD = 3
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = 3000
	}

	a, err := app.NewApp(
		DB_PATH,
		port,
		RANK_THRESHOLD,
	)
	if err != nil {
		log.Fatalf(
			"failed to initialize app: %v",
			err.Error(),
		)
	}
	defer a.Deinit()

	err = a.Run()
	if err != nil {
		log.Fatalf(
			"failed to run app: %v",
			err.Error(),
		)
	}
}
