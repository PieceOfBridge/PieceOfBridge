package logger

import (
	"fmt"
	"log"
	"os"
	"time"
)

var (
	outfile, _ = os.OpenFile("/var/log/J-S_bot.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0755)
	LogFile    = log.New(outfile, "", 0)
)

func ForError(er error) {
	if er != nil {
		LogFile.Fatalln(er)
	}
}

func PrintError(errType string, err error) {
	timeN := time.Now()
	fmt.Println(timeN, "->", errType, " ", err)
}

func PrintMsg(st string) {
	timeN := time.Now()
	fmt.Println(timeN, "->", st)
}
