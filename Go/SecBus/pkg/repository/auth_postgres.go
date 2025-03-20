package repository

import (
	"bus-app"
	"fmt"

	"github.com/jmoiron/sqlx"
	"github.com/sirupsen/logrus"
)

type AuthPostgres struct {
	db *sqlx.DB
}

func NewAuthPostgres(db *sqlx.DB) *AuthPostgres {
	return &AuthPostgres{db: db}
}

func (r *AuthPostgres) CreateUser(user bus.User) (int, error) {
	var id int
	query := fmt.Sprintf("INSERT INTO %s (name, email, username, password_hash) values ($1, $2, $3, $4) RETURNING id", usersTable)

	row := r.db.QueryRow(query, user.Name, user.Email, user.Username, user.Password)
	if err := row.Scan(&id); err != nil {
		return 0, err
	}

	return id, nil
}

func (r *AuthPostgres) GetUser(username, password string) (bus.User, error) {
	var user bus.User
	query := fmt.Sprintf("SELECT * FROM %s WHERE username = $1 AND password_hash = $2", usersTable)

	err := r.db.Get(&user, query, username, password)
	if err != nil {
		logrus.Errorf("Wrong fields returned")
	}

	return user, err
	// TODO: Return http status code for error
}
