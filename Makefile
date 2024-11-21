clean:
	rm -rf ./bootstrap

build:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o bootstrap -tags lambda.norpc main.go

package: clean build
	zip golang-function.zip bootstrap