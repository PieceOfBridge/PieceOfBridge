package repository

import (
	"bus-app"

	"github.com/jmoiron/sqlx"
)

// "bus-app"

type Authentication interface {
	CreateUser(user bus.User) (int, error)
	GetUser(username, password string) (bus.User, error)
}

type Project interface {
	Create(userId int, project bus.Project) (int, error)
	GetAll(userId int) ([]bus.Project, error)
	GetById(userId, projectId int) (bus.Project, error)
	Delete(userId, projectId int) error
	Update(userId, projectId int, input bus.UpdateProjectInput) error
}

type Sca interface {
}

type Sast interface {
}

type Repository struct {
	Authentication
	Project
	Sca
	Sast
}

// Initialize repository
func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{
		Authentication: NewAuthPostgres(db),
		Project:        NewProjectPostgres(db),
	}
}
