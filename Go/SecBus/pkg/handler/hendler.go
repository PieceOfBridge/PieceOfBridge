package handler

import (
	"bus-app/pkg/service"

	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	_ "bus-app/docs"
)

type Handler struct {
	services *service.Service
}

// Dependency Injection
func NewHandler(services *service.Service) *Handler {
	return &Handler{
		services: services,
	}
}

func (h *Handler) InitRoutes() *gin.Engine {
	router := gin.New()

	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))

	auth := router.Group("/auth")
	{
		auth.POST("/sign-up", h.signUp)
		auth.POST("/sign-in", h.signIn)
	}

	api := router.Group("/api", h.userIdentity)
	{
		project := api.Group("/project")
		{
			project.GET("/", h.getAllProjects)
			project.GET("/:id", h.getProjectsById)
			project.POST("/", h.createProject)
			project.PUT("/:id", h.updateProject)
			project.DELETE("/:id", h.deleteProject)
		}
		sca := api.Group("/sca")
		{
			sca.GET("/list", h.getAllSca)
			sca.GET("/list/:id", h.getScaById)
			sca.GET("/status", h.getScaStatus)
			sca.POST("/start", h.startSca)
			sca.DELETE("/:id", h.deleteSca)
		}
		sast := api.Group("/sast")
		{
			sast.GET("/list", h.getAllSast)
			sast.GET("/list/:id", h.getSastById)
			sast.GET("/status", h.getSastStatus)
			sast.POST("/start", h.startSast)
			sast.DELETE("/:id", h.deleteSast)
		}
	}

	return router
}
