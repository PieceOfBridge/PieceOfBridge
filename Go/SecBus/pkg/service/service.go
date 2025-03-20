package service

import (
	"bus-app"
	"bus-app/pkg/repository"
)

type Authentication interface {
	CreateUser(user bus.User) (int, error)
	GenerateToken(username, password string) (string, error)
	ParseToken(token string) (int, error)
}

type Project interface {
	Create(userId int, project bus.Project) (int, error)
	GetAll(useId int) ([]bus.Project, error)
	GetById(userId, projectId int) (bus.Project, error)
	Delete(userId, projectId int) error
	Update(userId, projectId int, input bus.UpdateProjectInput) error
}

type Sca interface {
}

type Sast interface {
}

type Service struct {
	Authentication
	Project
	Sca
	Sast
}

// Initialize service
func NewService(repos *repository.Repository) *Service {
	return &Service{
		Authentication: NewAuthService(repos.Authentication),
		Project:        NewProjectService(repos.Project),
	}
}
