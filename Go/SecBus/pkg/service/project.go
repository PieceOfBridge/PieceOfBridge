package service

import (
	"bus-app"
	"bus-app/pkg/repository"
)

type ProjectService struct {
	repo repository.Project
}

func NewProjectService(repo repository.Project) *ProjectService {
	return &ProjectService{
		repo: repo,
	}
}

func (s *ProjectService) Create(userId int, project bus.Project) (int, error) {
	return s.repo.Create(userId, project)
}

func (s *ProjectService) GetAll(userId int) ([]bus.Project, error) {
	return s.repo.GetAll(userId)
}

func (s *ProjectService) GetById(userId, projectId int) (bus.Project, error) {
	return s.repo.GetById(userId, projectId)
}

func (s *ProjectService) Delete(userId, projectId int) error {
	return s.repo.Delete(userId, projectId)
}

func (s *ProjectService) Update(userId, projectId int, input bus.UpdateProjectInput) error {
	if err := input.Validate(); err != nil {
		return err
	}

	return s.repo.Update(userId, projectId, input)
}
