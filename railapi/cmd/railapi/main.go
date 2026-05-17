package main

import (
	"log"
	"railapi/internals/app"
)

const (
	DB_PATH = "database.db"
	PORT = 8080
)

func main() {
	a, err := app.NewApp(DB_PATH, PORT)
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
