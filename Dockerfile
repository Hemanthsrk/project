# Stage 1: Build the Frontend
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
COPY frontend/ ./

RUN npm install 
RUN npm run build

# Stage 2: Build the Backend
FROM golang:1.21-alpine AS backend-builder
WORKDIR /app/backend
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ ./

RUN go build -o employee-service main.go

# Stage 3: Final Image
FROM alpine:3.18
WORKDIR /app
RUN apk add --no-cache ca-certificates
COPY --from=backend-builder /app/backend/employee-service /app/employee-service
COPY --from=frontend-builder /app/frontend/build /app/frontend/build
EXPOSE 8080

CMD ./employee-service

