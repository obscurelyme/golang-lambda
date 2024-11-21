package main

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
)

type ExampleEvent struct {
	Name string `json:"name"`
}

type ExampleResponse struct {
	Message string `json:"message"`
}

func main() {
	lambda.Start(example)
}

func example(ctx context.Context, event json.RawMessage) (string, error) {
	var input ExampleEvent
	err := json.Unmarshal(event, &input)

	if err != nil {
		response, _ := json.Marshal(ExampleResponse{
			Message: err.Error(),
		})

		return string(response), nil
	}

	if input.Name == "" {
		input.Name = "Golang Lambda!"
	}

	response, _ := json.Marshal(ExampleResponse{
		Message: fmt.Sprintf("Hello, %s", input.Name),
	})

	return string(response), nil
}
