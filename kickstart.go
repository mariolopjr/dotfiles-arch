package main

import (
	"flag"
	"html/template"
	"log"
	"net/http"
	"os"
	"path/filepath"
)

func main() {
	var fdepass, userpass string
	flag.StringVar(&fdepass, "fdepass", "", "enter full disk encryption password")
	flag.StringVar(&userpass, "userpass", "", "enter user password")

	flag.Usage = func() {
		flag.PrintDefaults()
	}
	flag.Parse()

	if fdepass == "" || userpass == "" {
		log.Fatal("please supply an fdepass and a userpass argument")
	}

	// web server for kickstart file
	http.HandleFunc("/", serveKickstart(fdepass, userpass))

	log.Fatal(http.ListenAndServe(":3000", nil))
	log.Println("Use the following in the netinst for Fedora as an example: inst.ks=http://<WEB_SERVER_IP>:3000/monolith.ks")
	log.Println("You can verify kickstart by visiting: http://localhost:3000/monolith.ks")
}

func serveKickstart(fdepass, userpass string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ks := filepath.Join("./kickstarts", filepath.Clean(r.URL.Path))
		data := struct {
			FdePassword  string
			UserPassword string
		}{
			FdePassword:  fdepass,
			UserPassword: userpass,
		}

		if _, err := os.Stat(ks); err != nil {
			if os.IsNotExist(err) {
				http.NotFound(w, r)
				return
			}
		}

		tmpl, err := template.ParseFiles(ks)
		if err != nil {
			log.Printf("err: %v", err)
			http.NotFound(w, r)
			return
		}
		if err := tmpl.ExecuteTemplate(w, "kickstart", data); err != nil {
			log.Printf("err: %v", err)
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "text/html; charset=ascii")
	}
}
