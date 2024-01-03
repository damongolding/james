package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	"github.com/gin-gonic/gin"
)

type Settings struct {
	UseCelsius                  bool    `json:"useCelsius"`
	OnContinually               bool    `json:"onContinually"`
	StartTime                   int     `json:"startTime"`
	EndTime                     int     `json:"endTime"`
	CompensateTemperature       bool    `json:"compensateTemperature"`
	CompensateTemperatureFactor float64 `json:"compensateTemperatureFactor"`
}

func loadSettings() (Settings, error) {
	var settings Settings

	jsonFile, err := os.Open(exPath + "/settings.json")
	if err != nil {
		return settings, err
	}
	defer jsonFile.Close()

	bytes, _ := io.ReadAll(jsonFile)

	err = json.Unmarshal(bytes, &settings)
	if err != nil {
		return settings, err
	}

	return settings, nil
}

func saveSettings(settings Settings) error {

	out, err := json.Marshal(settings)
	if err != nil {
		return err
	}

	err = os.WriteFile(exPath+"/settings.json", out, 0777)
	if err != nil {
		return err
	}

	return nil
}

var exPath string

func init() {
	ex, err := os.Executable()
	if err != nil {
		panic(err)
	}
	exPath = filepath.Dir(ex)
	fmt.Println(exPath)

}

func defaultSetter[T int | bool | float64](err error, v *T, defaultValue T) {
	if err != nil {
		*v = defaultValue
	}
}

func main() {
	r := gin.Default()

	r.LoadHTMLFiles(exPath + "/../frontend/dist/index.html")
	r.Static("/assets", exPath+"/../frontend/dist/assets")

	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", nil)
	})

	r.POST("/", func(c *gin.Context) {

		useCelsius, err := strconv.ParseBool(c.PostForm("use-celsius"))
		defaultSetter(err, &useCelsius, false)

		onContinually, err := strconv.ParseBool(c.PostForm("on-continually"))
		defaultSetter(err, &onContinually, false)

		startTime, err := strconv.Atoi(c.PostForm("start-time"))
		defaultSetter(err, &startTime, 7)

		endTime, err := strconv.Atoi(c.PostForm("end-time"))
		defaultSetter(err, &endTime, 18)

		compensateTemperature, err := strconv.ParseBool(c.PostForm("compensate-temperature"))
		defaultSetter(err, &compensateTemperature, false)

		compensateTemperatureFactor, err := strconv.ParseFloat(c.PostForm("compensate-temperature-factor"), 64)
		defaultSetter(err, &compensateTemperatureFactor, 2.6)

		settings := Settings{
			UseCelsius:                  useCelsius,
			OnContinually:               onContinually,
			StartTime:                   startTime,
			EndTime:                     endTime,
			CompensateTemperature:       compensateTemperature,
			CompensateTemperatureFactor: compensateTemperatureFactor,
		}

		err = saveSettings(settings)
		if err != nil {
			fmt.Println(err)
			c.JSON(http.StatusOK, gin.H{
				"success": false,
				"saved":   false,
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"saved":   true,
		})
	})

	r.GET("/settings", func(c *gin.Context) {

		settings, err := loadSettings()
		if err != nil {
			fmt.Println(err)
		}

		c.JSON(http.StatusOK, settings)
	})

	r.Run(":8080")
}
