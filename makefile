# Image name
IMAGE_NAME = rust-calculator

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run the container with GPU support
run:
	docker run --gpus all $(IMAGE_NAME)

# Build and run in one command
all: build run

# Clean up Docker images
clean:
	docker rmi $(IMAGE_NAME)

.PHONY: build run all clean
