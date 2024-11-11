# ====== Stage 1: Build the Frontend Application ======
FROM node:18 AS frontend-builder
WORKDIR /frontend-app
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# ====== Stage 2: Build the Backend Application ======
FROM golang:1.21 AS backend-builder
WORKDIR /backend-app
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# ====== Stage 3: Create the Final Production Image ======
FROM nginx:alpine AS final-stage
WORKDIR /app
COPY --from=backend-builder /backend-app/main /app/backend
COPY --from=frontend-builder /frontend-app/build /usr/share/nginx/html
EXPOSE 8080 80

CMD ["sh", "-c", "nginx -g 'daemon off;' & ./backend"]

