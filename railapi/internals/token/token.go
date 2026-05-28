// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railapi)
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

package token

import (
	"database/sql"
	"fmt"
	"railapi/internals/db"
)

var (
	tokens map[string]struct{}
)

func Init(sql *sql.DB) error {
	tokensList, err := db.GetTokens(sql)
	if err != nil {
		return fmt.Errorf(
			"failed to get tokens: %v",
			err.Error(),
		)
	}

	tokens = make(map[string]struct{})
	for _, t := range tokensList {
		tokens[t] = struct{}{}
	}

	return nil
}

func IsValid(token string) bool {
	_, ok := tokens[token]
	return ok
}
