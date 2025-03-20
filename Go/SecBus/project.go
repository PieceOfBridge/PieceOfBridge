package bus

import "errors"

type UserProject struct {
	Id        int
	UserId    int
	ProjectId int
}

type Sast struct {
	Id         int
	ProjectId  int
	SastScanId int
}

type Sca struct {
	Id        int
	ProjectId int
	ScaScanId int
}

type Project struct {
	Id          int    `json:"id" db:"id"`
	Title       string `json:"title" db:"title" binding:"required"`
	Description string `json:"description" db:"description"`
	GitUrl      string `json:"git_url" db:"git_url"`
}

type SastScanList struct {
	Id             int    `json:"id"`
	Title          string `json:"title"`
	Description    string `json:"description"`
	Version        string `json:"ver"`
	Done           bool   `json:"done"`
	Status         string `json:"status"`
	ProcessingTime int    `json:"processing_time"`
	ResultUrl      string `json:"result_url"`
}

type ScaScanList struct {
	Id             int    `json:"id"`
	Title          string `json:"title"`
	Description    string `json:"description"`
	Version        string `json:"ver"`
	Done           bool   `json:"done"`
	Status         string `json:"status"`
	ProcessingTime int    `json:"processing_time"`
	ResultUrl      string `json:"result_url"`
}

type UpdateProjectInput struct {
	Title       *string `json:"title"`
	Description *string `json:"description"`
}

func (i UpdateProjectInput) Validate() error {
	if i.Title == nil && i.Description == nil {
		return errors.New("Update structure has no values")
	}

	return nil
}
