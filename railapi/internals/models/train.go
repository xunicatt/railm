package models

type TrainStop struct {
	Station string `json:"station"`
	Route string `json:"route"`
	Arrival string `json:"arrival"`
	Departure string `json:"departure"`
}

type Train struct {
	Number string `json:"number"`
	Name string `json:"name"`
	Start string `json:"start"`
	End string `json:"end"`
	Stops []TrainStop `json:"stops"`
}
