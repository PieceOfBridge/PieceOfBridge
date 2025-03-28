package bus

type User struct {
	Id            int    `json:"-" db:"id"`
	Name          string `json:"name" binding:"required"`
	Email         string `json:"email" binding:"required"`
	Username      string `json:"username" binding:"required"`
	Password      string `json:"password" binding:"required"`
	Password_hash string `json:"password_hash"`
}
