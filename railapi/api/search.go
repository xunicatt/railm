package api

import (
	"encoding/json"
	"log"
	"net/http"
	"railapi/internals/db"
)

func (c *Context) GetRoutes(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	routes, err := db.GetRoutes(c.sql)
	if err != nil {
		log.Printf(
			"failed to get 'routes': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	data, err := json.Marshal(routes)
	if err != nil {
		log.Printf(
			"failed to encode 'routes': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	w.Write(data)
}

func (c *Context) GetStations(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	stations, err := db.GetStations(c.sql)
	if err != nil {
		log.Printf(
			"failed to get 'stations': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	data, err := json.Marshal(stations)
	if err != nil {
		log.Printf(
			"failed to encode 'stations': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	w.Write(data)
}

func (c *Context) GetStation(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	id := r.PathValue("id")
	station, err := db.GetStation(c.sql, id)
	if err != nil {
		log.Printf(
			"failed to get 'station': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	data, err := json.Marshal(station)
	if err != nil {
		log.Printf(
			"failed to encode 'station': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	w.Write(data)
}

func (c *Context) GetStationsInRoute(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	id := r.PathValue("id")
	stations, err := db.GetStationsInRoute(c.sql, id)
	if err != nil {
		log.Printf(
			"failed to get 'stations-in-route': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	data, err := json.Marshal(stations)
	if err != nil {
		log.Printf(
			"failed to encode 'stations': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	w.Write(data)
}

func (c *Context) GetTrains(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	trains, err := db.GetTrains(c.sql)
	if err != nil {
		log.Printf(
			"failed to get 'trains': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	data, err := json.Marshal(trains)
	if err != nil {
		log.Printf(
			"failed to encode 'trains': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	w.Write(data)
}

func (c *Context) GetTrain(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	number := r.PathValue("number")
	train, err := db.GetTrain(c.sql, number)
	if err != nil {
		log.Printf(
			"failed to get 'train': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	data, err := json.Marshal(train)
	if err != nil {
		log.Printf(
			"failed to encode 'train': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	w.Write(data)
}

func (c *Context) GetTrainsBetweenStations(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	src := r.PathValue("src")
	dest := r.PathValue("dest")

	trains, err := db.GetTrainsBetweenStations(c.sql, src, dest)
	if err != nil {
		log.Printf(
			"failed to get 'trains-between-stations': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	data, err := json.Marshal(trains)
	if err != nil {
		log.Printf(
			"failed to encode 'trains': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	w.Write(data)
}

func (c *Context) GetTrainsInRoute(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	id := r.PathValue("id")

	trains, err := db.GetTrainsInRoute(c.sql, id)
	if err != nil {
		log.Printf(
			"failed to get 'trains-in-route': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	data, err := json.Marshal(trains)
	if err != nil {
		log.Printf(
			"failed to encode 'trains': %v",
			err.Error(),
		)
		serverError(w)
		return
	}

	w.Write(data)
}
