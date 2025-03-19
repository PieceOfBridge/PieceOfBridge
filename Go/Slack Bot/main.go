package main

import (
	"time"

	"./jira"
	"./text"
)

func main() {
	for {
		respons := jira.JiraRequest()
		text.TxtDecode(*respons)
		time.Sleep(5 * time.Minute)
	}

}
