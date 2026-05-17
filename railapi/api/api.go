package api

import (
	"database/sql"
	"fmt"
	"net/http"
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
