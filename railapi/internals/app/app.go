package app

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"railapi/api"
	"railapi/internals/db"
	_ "github.com/mattn/go-sqlite3"
)

type App struct {
	port uint16
	ctx *api.Context
	mux *http.ServeMux
}

func NewApp(path string, port uint16) (*App, error) {
	sql, err := sql.Open("sqlite3", path)
	if err != nil {
		return nil, fmt.Errorf(
			"failed to open database: %v",
			err.Error(),
		)
	}

	err = db.Init(sql)
	if err != nil {
		return nil, fmt.Errorf(
			"failed to initialize database: %v",
			err.Error(),
		)
	}

	ctx := api.NewContext(sql)
	mux := http.NewServeMux()

	mux.HandleFunc("GET /routes", ctx.GetRoutes)
	mux.HandleFunc("GET /routes/{id}/stations", ctx.GetStationsInRoute)
	mux.HandleFunc("GET /routes/{id}/trains", ctx.GetTrainsInRoute)
	mux.HandleFunc("POST /routes", ctx.AddRoute)

	mux.HandleFunc("GET /stations", ctx.GetStations)
	mux.HandleFunc("GET /stations/{id}", ctx.GetStation)
	mux.HandleFunc("POST /stations", ctx.AddStation)

	mux.HandleFunc("GET /trains", ctx.GetTrains)
	mux.HandleFunc("GET /trains/{number}", ctx.GetTrain)
	mux.HandleFunc("GET /trains/between/{src}/{dest}", ctx.GetTrainsBetweenStations)
	mux.HandleFunc("POST /trains", ctx.AddTrain)

	a := &App{
		port: port,
		ctx: ctx,
		mux: mux,
	}

	return a, nil
}

func (a *App) Deinit() {
	a.ctx.Deinit()
}

func (a *App) Run() error {
	log.Printf("started server on port: %v", a.port)

	return http.ListenAndServe(
		fmt.Sprintf(":%v", a.port),
		a.mux,
	)
}
