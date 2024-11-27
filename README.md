# Golang Lambda

This is an example project of a working Lambda function using Golang.

For more information on how to work with AWS Lambdas in Golang refer to the offical [docs](https://docs.aws.amazon.com/lambda/latest/dg/lambda-golang.html)

---

To build and package into a .zip that can be deployed to AWS Lambda

```sh
make package
```

It is highly recommended to leverage [Jeeves](https://github.com/obscurelyme/jeeves) alongside this for development.

To start the Lambda function locally
```sh
jeeves faas start
```
