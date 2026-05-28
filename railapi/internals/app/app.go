// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railapi)
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

package app

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"railapi/api"
	"railapi/internals/db"
	"railapi/internals/rank"
	"railapi/internals/token"

	_ "github.com/tursodatabase/libsql-client-go/libsql"
)

type App struct {
	port string
	ctx *api.Context
	handler http.Handler
}

func NewApp(url string, port string, threshold uint) (*App, error) {
	sql, err := sql.Open("libsql", url)
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

	err = token.Init(sql)
	if err != nil {
		return nil, fmt.Errorf(
			"failed to initialize token: %v",
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

	mux.HandleFunc("GET /status/{number}", ctx.GetStatus)
	mux.HandleFunc("POST /status/{number}/{station}", ctx.UpdateStatus)

	rank.Init(threshold)

	handler := api.AuthMiddleware(mux)

	a := &App{
		port: port,
		ctx: ctx,
		handler: handler,
	}

	return a, nil
}

func (a *App) Deinit() {
	a.ctx.Deinit()
}

func (a *App) Run() error {
	log.Print("started server on port: " + a.port)

	return http.ListenAndServe(
		":" + a.port,
		a.handler,
	)
}
