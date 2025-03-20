package repository

import (
	"bus-app"
	"fmt"
	"strings"

	"github.com/jmoiron/sqlx"
	"github.com/sirupsen/logrus"
)

type ProjectPostgres struct {
	db *sqlx.DB
}

func NewProjectPostgres(db *sqlx.DB) *ProjectPostgres {
	return &ProjectPostgres{db: db}
}

// ToDo add error processing. Error should be http status code.
func (r *ProjectPostgres) Create(userId int, project bus.Project) (int, error) {
	tx, err := r.db.Begin()
	if err != nil {
		return 0, err
	}
	var id int
	createProjecQuery := fmt.Sprintf("INSERT INTO %s (title, description) VALUES ($1, $2) RETURNING id", projectTable)
	row := tx.QueryRow(createProjecQuery, project.Title, project.Description)
	if err := row.Scan(&id); err != nil {
		tx.Rollback()
		return 0, err
	}

	createUserProjectQuery := fmt.Sprintf("INSERT INTO %s (user_id, project_id) VALUES ($1, $2)", usersProjectTable)
	_, err = tx.Exec(createUserProjectQuery, userId, id)
	if err != nil {
		tx.Rollback()
		return 0, err
	}

	return id, tx.Commit()
}

// ToDo add error processing. Error should be http status code.
func (r *ProjectPostgres) GetAll(userId int) ([]bus.Project, error) {
	var projects []bus.Project
	query := fmt.Sprintf("SELECT project.id, project.title, project.description FROM %s project INNER JOIN %s ul ON tl.id = ul.list WHERE ul.user_id = $1", projectTable, usersProjectTable)

	err := r.db.Select(&projects, query, userId)

	return projects, err
}

// ToDo add error processing. Error should be http status code.
func (r *ProjectPostgres) GetById(userId, projectId int) (bus.Project, error) {
	var project bus.Project
	query := fmt.Sprintf("SELECT tl.id, tl.title, tl.description FROM %s tl INNER JOIN %s ul ON tl.id = ul.list WHERE ul.user_id = $1 AND ul.list_id = $2", projectTable, usersProjectTable)

	err := r.db.Get(&project, query, userId, projectId)

	return project, err
}

func (r *ProjectPostgres) Delete(userId, projectId int) error {
	query := fmt.Sprintf("DELETE FROM %s tl USING %s ul WHERE tl.id = ul.list_id AND ul.user_id=$1 AND ul.list_id=$2", projectTable, usersProjectTable)
	_, err := r.db.Exec(query, userId, projectId)

	return err
}

func (r *ProjectPostgres) Update(userId, projectId int, input bus.UpdateProjectInput) error {
	setValues := make([]string, 0)
	args := make([]interface{}, 0)
	argsId := 1

	if input.Title != nil {
		setValues = append(setValues, fmt.Sprintf("title = $%d", argsId))
		args = append(args, input.Title)
		argsId++
	}

	if input.Description != nil {
		setValues = append(setValues, fmt.Sprintf("description = $%d", argsId))
		args = append(args, input.Description)
		argsId++
	}

	// title=$1
	// description=$1
	// title=$1, description=$2
	setQuery := strings.Join(setValues, ", ")

	query := fmt.Sprintf("UPDATE %s tl SET %s FROM %s ul WHERE tl.id = ul.list_id AND ul.list_id=$%d AND ul.user_id=$%d", projectTable, setQuery, usersProjectTable, argsId, argsId+1)
	args = append(args, projectId, userId)

	logrus.Debug("updateQuery: %s", query)
	logrus.Debug("updateArgs: %s", args)

	_, err := r.db.Exec(query, args...)
	return err
}
