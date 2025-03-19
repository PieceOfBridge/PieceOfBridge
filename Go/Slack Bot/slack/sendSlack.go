package sendSlack

import (
	"bytes"
	"encoding/json"

	// "errors"
	"net/http"
	"time"

	"../logger"
)

const (
	webhookUrl = "https://hooks.slack.com/services/***/***/***"
)

type SlackRequestBody struct {
	Text string `json:"text"`
}

//Функция вызывающая отправку сообщений

func SendSlackNotification(msg string) error {

	slackBody, _ := json.Marshal(SlackRequestBody{Text: msg})
	req, err := http.NewRequest(http.MethodPost, webhookUrl, bytes.NewBuffer(slackBody))
	if err != nil {
		logger.PrintError(req.Host+"Slack Request Error", err)
	} else {
		logger.PrintMsg(req.Host + " Request success")
	}

	req.Header.Add("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	if msg != "" {
		resp, err := client.Do(req)
		if err != nil {
			logger.PrintError(resp.Request.Host+" Slack Respons Error", err)
		} else {
			logger.PrintMsg(resp.Request.Host + " " + resp.Status + " Slack Respons success")
		}
	}
	return nil
}
