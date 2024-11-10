# Frontend build stage
FROM node:16 AS frontend-build
WORKDIR /frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# Backend build stage
FROM golang:1.20 AS backend-build
WORKDIR /backend
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ .
RUN go build -o /backend/main .

# Final image
FROM ubuntu:20.04
WORKDIR /app
COPY --from=frontend-build /frontend/build /app/frontend
COPY --from=backend-build /backend/main /app/backend

EXPOSE 3000 8080
CMD ["bash", "-c", "cd /app/frontend && serve -s . -l 3000 & cd /app/backend && ./main"]

