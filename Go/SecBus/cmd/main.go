package main

import (
	"bus-app"
	"bus-app/pkg/handler"
	"bus-app/pkg/repository"
	"bus-app/pkg/service"
	"context"
	"os"
	"os/signal"
	"syscall"

	_ "github.com/lib/pq"

	"github.com/joho/godotenv"
	"github.com/sirupsen/logrus"
	"github.com/spf13/viper"
)

// @title Security Bus API
// @version 1.0
// @description API Server for Security Bus

// @host localhost:8080
// @BasePath /

// @securityDefinitions.apikey ApiKeyAuth
// @in header
// @name Authorization

func main() {

	logrus.SetFormatter(new(logrus.JSONFormatter))

	if err := initConfig(); err != nil {
		logrus.Fatalf("Failed to init config: %s", err.Error())
	}

	if err := godotenv.Load(); err != nil {
		logrus.Fatal("Error loading env variables %s", err.Error())
	}
	db, err := repository.NewPostgresDB(repository.Config{
		Host:     viper.GetString("db.host"),
		Port:     viper.GetString("db.port"),
		Username: viper.GetString("db.username"),
		Password: os.Getenv("DB_PASSWORD"),
		DBName:   viper.GetString("db.dbname"),
		SSLMode:  viper.GetString("db.sslmode"),
	})
	if err != nil {
		logrus.Fatalf("Failed to connect to database: %s", err.Error())
	}

	repos := repository.NewRepository(db)
	service := service.NewService(repos)
	handler := handler.NewHandler(service)

	srv := new(bus.Server)

	// Graceful Shutdown
	go func() {
		if err := srv.Run(viper.GetString("port"), handler.InitRoutes()); err != nil {
			logrus.Fatalf("Error occured while running http server: %s", err.Error())
		}
	}()

	logrus.Print("BusApp started")

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGTERM, syscall.SIGINT)
	<-quit

	logrus.Print("BusApp Shutting Down")

	if err := srv.Shutdown(context.Background()); err != nil {
		logrus.Errorf("Error occured on server shutting down: %s", err.Error())
	}

	if err := db.Close(); err != nil {
		logrus.Errorf("Error occured on db connection close: %s", err.Error())
	}
}

func initConfig() error {
	viper.AddConfigPath("configs")
	viper.SetConfigName("config")
	return viper.ReadInConfig()
}
