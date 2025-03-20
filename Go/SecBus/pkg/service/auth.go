package service

import (
	"bus-app"
	"bus-app/pkg/repository"
	"crypto/sha512"
	"errors"
	"fmt"
	"time"

	"github.com/dgrijalva/jwt-go"
)

const (
	salt       = "zYVZXemdwKHa&!vRNWUQ4tJ@3hhNh#emEhPKBqdk9CJ2^jq65yKMVWT*2oXX2d#nMxg7X#N4CkyjYjnEi$NxdK7uY&U9iR8jRhS6Wc#z6rMdEzESdai@&!MFsx4P9y^X"
	signingKey = "Rk2kTY%TC%eMLiqm#RMWhLcDBQzuGKaJsUWwr@z#3hEU76LVynnBcfY$h#dZ4qrN!o@dzfx8YFPfX9&ufJF#p%&nZJPVc!e6smU68YvT7Fu%YUQNcZT$@@a3r@j^$!^e"
	tokenTTL   = 12 * time.Hour
)

type AuthService struct {
	repo repository.Authentication
}

type tokenClaims struct {
	jwt.StandardClaims
	UserId int `json:"user_id"`
}

func NewAuthService(repo repository.Authentication) *AuthService {
	return &AuthService{
		repo: repo,
	}
}

func (s *AuthService) CreateUser(user bus.User) (int, error) {
	user.Password = generatePasswordHash(user.Password)
	return s.repo.CreateUser(user)
}

func (s *AuthService) GenerateToken(username, password string) (string, error) {
	user, err := s.repo.GetUser(username, generatePasswordHash(password))
	if err != nil {
		return "", err
	}

	token := jwt.NewWithClaims(jwt.SigningMethodES256, &tokenClaims{
		jwt.StandardClaims{
			IssuedAt:  time.Now().Unix(),
			ExpiresAt: time.Now().Add(tokenTTL).Unix(),
		},
		user.Id,
	})

	return token.SignedString([]byte(signingKey))
}

func (s *AuthService) ParseToken(accessToken string) (int, error) {
	token, err := jwt.ParseWithClaims(accessToken, &tokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("Invalid signing method")
		}

		return []byte(signingKey), nil

	})
	if err != nil {
		return 0, err
	}

	claims, ok := token.Claims.(*tokenClaims)
	if !ok {
		return 0, errors.New("Token claim are not of type *tokenClaims")
	}

	return claims.UserId, nil
}

func generatePasswordHash(password string) string {
	hash := sha512.New512_256()
	hash.Write([]byte(password))

	return fmt.Sprintf("%x", hash.Sum([]byte(salt)))
}
