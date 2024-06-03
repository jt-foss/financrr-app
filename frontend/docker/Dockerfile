FROM ghcr.io/cirruslabs/flutter:3.19.5 AS builder

# Set the working directory
WORKDIR /app

# Copy the project files into the Docker image
COPY . /app

# Fetch the dependencies
RUN flutter pub get

# Build the web application
RUN flutter build web --release

# Use nginx to serve the built web application
FROM nginx:1.25.4-alpine3.18

# Copy the built files from the build stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose the port nginx is running on
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
