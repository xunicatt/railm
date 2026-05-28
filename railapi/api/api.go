// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railapi)
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

package api

import (
	"database/sql"
	"fmt"
	"net/http"
	"railapi/internals/token"
)

type Context struct {
	sql *sql.DB
}

func NewContext(sql *sql.DB) *Context {
	return &Context{
		sql: sql,
	}
}

func (c *Context) Deinit() {
	c.sql.Close()
}

func AuthMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func (w http.ResponseWriter, r *http.Request) {
		auth := r.URL.Query().Get("auth")

		if !token.IsValid(auth) {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func success(w http.ResponseWriter) {
	fmt.Fprint(w, `{"status": "success"}`)
}

func failed(w http.ResponseWriter, format string, args ...any) {
	fmt.Fprintf(
		w,
		`{"status": "failed", "reason": "%v"}`,
		fmt.Sprintf(format, args...),
	)
}

func serverError(w http.ResponseWriter) {
	w.WriteHeader(http.StatusInternalServerError)
}

func notFound(w http.ResponseWriter) {
	w.WriteHeader(http.StatusNotFound)
}

func badRequest(w http.ResponseWriter) {
	w.WriteHeader(http.StatusBadRequest)
}

func appendCrosHeaders(h *http.Header) {
	h.Set("Access-Control-Allow-Origin", "*")
	h.Set("Access-Control-Allow-Methods", "GET, POST")
	h.Set("Access-Control-Allow-Headers", "Content-Type")
}
