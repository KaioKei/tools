package main

import (
	"flag"
	"shuttle/configuration"
)

func main() {
	config := flag.String("c", "/dev/null", "Path to the yaml config file.")
	flag.Parse()

	configuration.Init(*config)
}
