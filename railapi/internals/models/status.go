// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railapi) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

package models

type TrainStatus uint8

const (
	STATUS_RUNNING TrainStatus = iota
	STATUS_ARRIVED
	STATUS_LEFT
)

type Status struct {
	Number string `json:"number"`
	Station string `json:"station"`
	State TrainStatus `json:"state"`
	Time string `json:"time"`
}
