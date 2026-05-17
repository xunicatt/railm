package models

type Station struct {
	Id string `json:"id"`
	Name string `json:"name"`
	Route string `json:"route"`
	Position uint16 `json:"position"`
}
