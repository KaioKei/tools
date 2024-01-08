package configuration

import (
	"errors"
	"github.com/spf13/viper"
	"log"
	"path/filepath"
	"strings"
)

type machine struct {
	Remote   string
	Local    string
	Hostname string
}

type config struct {
	Shuttles []machine
}

// getConfigNameAndExt returns the filename and its extension from a path
func getConfigNameAndExt(path string) (string, string) {
	fileBase := filepath.Base(path)
	splits := strings.Split(fileBase, ".")
	return splits[0], splits[1]
}

var Configuration config

func Init(path string) {
	//configName, configExt := getConfigNameAndExt(path)

	// validate config
	viper.AddConfigPath(path)
	viper.SetConfigFile(path)
	if err := viper.ReadInConfig(); err != nil {
		var configFileNotFoundError viper.ConfigFileNotFoundError
		if errors.As(err, &configFileNotFoundError) {
			log.Println("Config file not found:", err)
		} else {
			log.Println("Config error:", err)
		}
	}

	// load config
	if err := viper.Unmarshal(&Configuration); err != nil {
		log.Println("Unable to validate the config schema:", path)
		log.Fatalln(err)
	}

	log.Println("Configuration loaded:", Configuration.Shuttles)

	//viper.SetConfigName(configName)
	//viper.SetConfigType(configExt)
}
