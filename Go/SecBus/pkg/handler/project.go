package handler

import (
	"bus-app"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// @Summary Create project list
// @Security ApiKeyAuth
// @Tags Projects
// @Description create project list
// @ID create-project
// @Accept  json
// @Produce  json
// @Param input body bus.Project true "project info"
// @Success 200 {integer} integer 1
// @Failure 400,404 {object} errorResponse
// @Failure 500 {object} errorResponse
// @Failure default {object} errorResponse
// @Router /api/project [post]

// Create project
func (h *Handler) createProject(c *gin.Context) {
	userId, err := getUserId(c)
	if err != nil {
		return
	}

	var input bus.Project
	if err := c.BindJSON(&input); err != nil {
		newErrorResponse(c, http.StatusBadRequest, "Invalid request body")
		return
	}

	id, err := h.services.Project.Create(userId, input)
	if err != nil {
		newErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	c.JSON(http.StatusOK, map[string]interface{}{
		"id": id,
	})

}

// Delete project by id
func (h *Handler) deleteProject(c *gin.Context) {
	userId, err := getUserId(c)
	if err != nil {
		return
	}

	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		newErrorResponse(c, http.StatusBadRequest, "Invalid project id")
		return
	}

	err = h.services.Project.Delete(userId, id)
	if err != nil {
		newErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	c.JSON(http.StatusOK, statusResponse{
		Status: "ok",
	})
}

// Update project by id
func (h *Handler) updateProject(c *gin.Context) {
	userId, err := getUserId(c)
	if err != nil {
		return
	}

	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		newErrorResponse(c, http.StatusBadRequest, "Invalid project id")
		return
	}

	var input bus.UpdateProjectInput
	if err := c.BindJSON(&input); err != nil {
		newErrorResponse(c, http.StatusBadRequest, err.Error())
		return
	}

	if err := h.services.Update(userId, id, input); err != nil {
		newErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	c.JSON(http.StatusOK, statusResponse{
		Status: "ok",
	})
}

type getAllProjectsResponse struct {
	Data []bus.Project `json:"data"`
}

// @Summary Get All Projects
// @Security ApiKeyAuth
// @Tags Projects
// @Description get all Projects
// @ID get-all-projects
// @Accept  json
// @Produce  json
// @Success 200 {object} getAllProjectsResponse
// @Failure 400,404 {object} errorResponse
// @Failure 500 {object} errorResponse
// @Failure default {object} errorResponse
// @Router /api/project [get]

// Get all project
func (h *Handler) getAllProjects(c *gin.Context) {
	userId, err := getUserId(c)
	if err != nil {
		return
	}

	projects, err := h.services.Project.GetAll(userId)
	if err != nil {
		newErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	c.JSON(http.StatusOK, getAllProjectsResponse{
		Data: projects,
	})
}

// @Summary Get Project By Id
// @Security ApiKeyAuth
// @Tags Projects
// @Description get project by id
// @ID get-project-by-id
// @Accept  json
// @Produce  json
// @Success 200 {object} bus.Project
// @Failure 400,404 {object} errorResponse
// @Failure 500 {object} errorResponse
// @Failure default {object} errorResponse
// @Router /api/project/:id [get]

// Get project by id
func (h *Handler) getProjectsById(c *gin.Context) {
	userId, err := getUserId(c)
	if err != nil {
		return
	}

	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		newErrorResponse(c, http.StatusBadRequest, "Invalid project id")
		return
	}

	project, err := h.services.Project.GetById(userId, id)
	if err != nil {
		newErrorResponse(c, http.StatusInternalServerError, err.Error())
		return
	}

	c.JSON(http.StatusOK, project)
}
