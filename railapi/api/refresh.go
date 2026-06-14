package api

import (
	"net/http"
	"railapi/internals/db"
	"railapi/internals/token"
)

func (c *Context) Refresh(w http.ResponseWriter, r *http.Request) {
	rtype := r.PathValue("type")
	var err error

	switch rtype {
	case "status":
		err = db.ResetStatusTable(c.sql)

	case "tokens":
		err = token.Init(c.sql)

	default:
		failed(w, "unknown type")
		return
	}

	if err != nil {
		failed(
			w,
			"failed to refresh '%v': %v",
			rtype, err.Error(),
		)
		return
	}

	success(w)
}
