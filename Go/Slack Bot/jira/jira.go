package jira

import (
	"net/http"
	"time"

	"../logger"
)

const (
	URL  = "https://jira.domain.ru/rest/api/2/search?jql=project=%22DC:%20DEVOPS%22+and+created%20>%3D%20-5m"
	head = "***"
)

func JiraRequest() *http.Response {

	timeout := time.Duration(5 * time.Second)
	client := http.Client{
		Timeout: timeout,
	}
	req, err := http.NewRequest("GET", URL, nil)
	if err != nil {
		logger.PrintError(req.Host+"Jira Request Error", err)
	} else {
		logger.PrintMsg(req.Host + "  Jira Request success")
	}

	req.Header.Set("Authorization", head)

	resp, err := client.Do(req)
	if err != nil {
		logger.PrintError(resp.Request.Host+" Jira Respons Error", err)
	} else {
		logger.PrintMsg(resp.Request.Host + " " + resp.Status + " Jira Respons success")
	}

	return resp

}
