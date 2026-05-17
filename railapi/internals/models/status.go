package models

type Status struct {
	Number string `json:"number"`
	Station string `json:"station"`
	State uint8 `json:"state"`
}
