package text

import (
	"encoding/json"
	"fmt"
	"net/http"

	"../logger"
	sendSlack "../slack"
)

const (
	jiraUrl = "https://jira.vk.team/browse/"
)

type Reporter struct {
	EmailAddress string `json:"emailAddress,omitempty"`
	DisplayName  string `json:"displayName,omitempty"`
}

type Priority struct {
	Name string `json:"name,omitempty"`
}

type Fields struct {
	Reporter    *Reporter `json:"reporter,omitempty"`
	Description string    `json:"description,omitempty"`
	Summary     string    `json:"summary,omitempty"`
	Priority    *Priority `json:"priority,omitempty"`
}

type Issues struct {
	Key    string  `json:"key,omitempty"`
	Fields *Fields `json:"fields,omitempty"`
}

type Respons struct {
	Expand     string    `json:"expand,omitempty"`
	StartAt    int       `json:"startAt,omitempty"`
	MaxResults int       `json:"maxResults,omitempty"`
	Total      int       `json:"total,omitempty"`
	Issues     *[]Issues `json:"issues,omitempty"`
}

func TxtDecode(resp http.Response) {
	defer resp.Body.Close()

	decoder := json.NewDecoder(resp.Body)

	val := &Respons{}

	err := decoder.Decode(val)

	if err != nil {
		logger.PrintError("Decode Error", err)
	} else {
		logger.PrintMsg("Decode success")
		txtDrafting(val)
	}

	fmt.Println("Number of issues", val.Total)
}

func txtDrafting(val *Respons) {
	if val.Total > 0 {
		for _, i := range *val.Issues {
			tickStat := statMsg(i.Fields.Priority.Name)
			tickName := fmt.Sprint("<", jiraUrl+i.Key, "|", i.Fields.Summary, ">\n")
			report := fmt.Sprint("Ticket from -->  <mailto:", i.Fields.Reporter.EmailAddress, "|", i.Fields.Reporter.DisplayName, ">\n")
			descrip := fmt.Sprint("Description:\n ```", i.Fields.Description, "```")
			msg := tickStat + tickName + report + descrip
			sendSlack.SendSlackNotification(msg)
		}
	}
}

func statMsg(inStat string) (stat string) {
	switch inStat {
	case "Самый низкий":
		stat = string(":gachi-lick: *Самый низкий*\n")
	case "Низкий":
		stat = string(":ricardo-flick: *Низкий*\n")
	case "Средний":
		stat = string(":smekalochka: *Средний*\n")
	case "Блокирующий":
		stat = string(":aaaaa: *Блокирующий*\n")
	case "":
		stat = string(":eyebrows:")
	default:
		logger.PrintMsg("Status field missing in api response")
	}
	return stat
}
