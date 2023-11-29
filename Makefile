gen:
	mkdir -p golang/$(service)
	protoc -I ./ \
		--go_out ./golang \
		--go_opt=paths=source_relative \
		--go-grpc_out ./golang \
		--go-grpc_opt=paths=source_relative \
		./$(service)/*.proto
	cd golang/$(service) && \
		(go mod init github.com/huytran2000-hcmus/grpc-microservices-proto/golang/$(service) || true) && \
		go mod tidy

