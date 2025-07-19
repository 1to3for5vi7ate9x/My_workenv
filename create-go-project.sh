#!/bin/bash

# Default values
PROJECT_TYPE="basic"
SKIP_GIT=false
PROJECT_NAME=""

# Function to display help
show_help() {
    cat << EOF
Usage: go_project [PROJECT_NAME] [OPTIONS]

Create a new Go project with customizable structure.

OPTIONS:
    --type TYPE    Project type (default: basic)
                   Available types:
                   - basic: Standard Go project with cmd/pkg/internal
                   - cli: CLI application with cobra
                   - api: REST API with chi router
                   - lib: Library (no cmd directory)
                   - minimal: Just main.go file
    
    --no-git       Skip git initialization
    -h, --help     Show this help message

EXAMPLES:
    go_project myproject                # Basic project
    go_project mycli --type cli         # CLI application
    go_project myapi --type api         # API server
    go_project mylib --type lib         # Go library

Project types:
- basic: Standard layout with cmd/, pkg/, internal/ directories
- cli: Includes cobra for CLI apps, config handling
- api: Includes chi router, middleware, handlers structure
- lib: Library structure without cmd directory
- minimal: Single main.go file for simple scripts
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        --type)
            PROJECT_TYPE="$2"
            shift 2
            ;;
        --no-git)
            SKIP_GIT=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
            fi
            shift
            ;;
    esac
done

# Validate project type
case $PROJECT_TYPE in
    basic|cli|api|lib|minimal)
        ;;
    *)
        echo "Invalid project type: $PROJECT_TYPE"
        echo "Valid types: basic, cli, api, lib, minimal"
        exit 1
        ;;
esac

# If no project name provided, prompt for it
if [ -z "$PROJECT_NAME" ]; then
    echo "Enter the Go project name:"
    read PROJECT_NAME
fi

# Show selected configuration
echo "Creating Go project with the following configuration:"
echo "  Project name: $PROJECT_NAME"
echo "  Project type: $PROJECT_TYPE"
echo "  Git initialization: $([ "$SKIP_GIT" = false ] && echo "Yes" || echo "No")"
echo ""

# Create the directory path
go_dir="$HOME/Documents/Go_projects"
mkdir -p "$go_dir"

# Navigate to the Go projects directory
cd "$go_dir"

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize the Go module
go mod init "$PROJECT_NAME"

# Create structure based on project type
case $PROJECT_TYPE in
    minimal)
        # Just create main.go
        cat <<EOF > main.go
package main

import "fmt"

func main() {
    fmt.Println("Hello from $PROJECT_NAME!")
}
EOF
        ;;
    
    lib)
        # Library structure
        mkdir -p internal examples
        
        # Create the main library file
        cat <<EOF > ${PROJECT_NAME}.go
// Package $PROJECT_NAME provides...
package $PROJECT_NAME

// Version is the current version of the library
const Version = "0.1.0"

// Hello returns a greeting message
func Hello(name string) string {
    if name == "" {
        name = "World"
    }
    return "Hello, " + name + "!"
}
EOF
        
        # Create an example
        mkdir -p examples/basic
        cat <<EOF > examples/basic/main.go
package main

import (
    "fmt"
    "$PROJECT_NAME"
)

func main() {
    message := $PROJECT_NAME.Hello("Go Developer")
    fmt.Println(message)
    fmt.Printf("Using $PROJECT_NAME version %s\n", $PROJECT_NAME.Version)
}
EOF
        
        # Create test file
        cat <<EOF > ${PROJECT_NAME}_test.go
package $PROJECT_NAME

import "testing"

func TestHello(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
    }{
        {"Empty name", "", "Hello, World!"},
        {"With name", "Go", "Hello, Go!"},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Hello(tt.input)
            if result != tt.expected {
                t.Errorf("Hello(%q) = %q, want %q", tt.input, result, tt.expected)
            }
        })
    }
}
EOF
        ;;
    
    cli)
        # CLI application structure
        mkdir -p cmd/$PROJECT_NAME internal/config internal/commands
        
        # Main entry point
        cat <<EOF > cmd/$PROJECT_NAME/main.go
package main

import (
    "fmt"
    "os"
    
    "$PROJECT_NAME/internal/commands"
)

func main() {
    if err := commands.Execute(); err != nil {
        fmt.Fprintf(os.Stderr, "Error: %v\n", err)
        os.Exit(1)
    }
}
EOF
        
        # Root command
        cat <<EOF > internal/commands/root.go
package commands

import (
    "fmt"
    
    "github.com/spf13/cobra"
)

var (
    // Version information
    Version = "0.1.0"
    
    // Root command
    rootCmd = &cobra.Command{
        Use:   "$PROJECT_NAME",
        Short: "$PROJECT_NAME is a CLI application",
        Long:  \`$PROJECT_NAME is a command-line application built with Go and Cobra.
        
This application provides various commands to help you with your tasks.\`,
        Version: Version,
    }
)

// Execute runs the root command
func Execute() error {
    return rootCmd.Execute()
}

func init() {
    // Add commands here
    rootCmd.AddCommand(helloCmd)
}

// Example command
var helloCmd = &cobra.Command{
    Use:   "hello [name]",
    Short: "Print a greeting",
    Args:  cobra.MaximumNArgs(1),
    Run: func(cmd *cobra.Command, args []string) {
        name := "World"
        if len(args) > 0 {
            name = args[0]
        }
        fmt.Printf("Hello, %s!\n", name)
    },
}
EOF
        
        # Config package
        cat <<EOF > internal/config/config.go
package config

import (
    "encoding/json"
    "os"
)

// Config holds application configuration
type Config struct {
    // Add your configuration fields here
    Debug bool   \`json:"debug"\`
    Port  int    \`json:"port"\`
}

// Load reads configuration from a file
func Load(path string) (*Config, error) {
    file, err := os.Open(path)
    if err != nil {
        return nil, err
    }
    defer file.Close()
    
    var cfg Config
    decoder := json.NewDecoder(file)
    if err := decoder.Decode(&cfg); err != nil {
        return nil, err
    }
    
    return &cfg, nil
}

// Save writes configuration to a file
func (c *Config) Save(path string) error {
    file, err := os.Create(path)
    if err != nil {
        return err
    }
    defer file.Close()
    
    encoder := json.NewEncoder(file)
    encoder.SetIndent("", "  ")
    return encoder.Encode(c)
}
EOF
        
        # Update go.mod to add cobra dependency
        go get github.com/spf13/cobra@latest
        ;;
    
    api)
        # API server structure
        mkdir -p cmd/$PROJECT_NAME internal/handlers internal/middleware internal/models
        
        # Main entry point
        cat <<EOF > cmd/$PROJECT_NAME/main.go
package main

import (
    "fmt"
    "log"
    "net/http"
    "os"
    
    "$PROJECT_NAME/internal/handlers"
    "$PROJECT_NAME/internal/middleware"
    
    "github.com/go-chi/chi/v5"
    "github.com/go-chi/chi/v5/middleware"
)

func main() {
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }
    
    r := chi.NewRouter()
    
    // Middleware
    r.Use(middleware.Logger)
    r.Use(middleware.Recoverer)
    r.Use(middleware.RequestID)
    r.Use(middleware.RealIP)
    r.Use(customMiddleware.Cors)
    
    // Routes
    r.Get("/", handlers.Home)
    r.Get("/health", handlers.Health)
    
    // API routes
    r.Route("/api/v1", func(r chi.Router) {
        r.Use(customMiddleware.ContentTypeJSON)
        
        r.Get("/hello", handlers.Hello)
        // Add more API routes here
    })
    
    log.Printf("Server starting on port %s", port)
    if err := http.ListenAndServe(":"+port, r); err != nil {
        log.Fatal(err)
    }
}
EOF
        
        # Handlers
        cat <<EOF > internal/handlers/handlers.go
package handlers

import (
    "encoding/json"
    "net/http"
)

// Response is a generic API response
type Response struct {
    Success bool        \`json:"success"\`
    Message string      \`json:"message,omitempty"\`
    Data    interface{} \`json:"data,omitempty"\`
    Error   string      \`json:"error,omitempty"\`
}

// Home handles the root endpoint
func Home(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("Welcome to $PROJECT_NAME API"))
}

// Health handles health check requests
func Health(w http.ResponseWriter, r *http.Request) {
    response := Response{
        Success: true,
        Message: "Service is healthy",
        Data: map[string]string{
            "status": "ok",
            "service": "$PROJECT_NAME",
        },
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

// Hello handles hello requests
func Hello(w http.ResponseWriter, r *http.Request) {
    name := r.URL.Query().Get("name")
    if name == "" {
        name = "World"
    }
    
    response := Response{
        Success: true,
        Data: map[string]string{
            "message": "Hello, " + name + "!",
        },
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}
EOF
        
        # Middleware
        cat <<EOF > internal/middleware/middleware.go
package middleware

import (
    "net/http"
)

// Cors adds CORS headers
func Cors(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Access-Control-Allow-Origin", "*")
        w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
        
        if r.Method == "OPTIONS" {
            w.WriteHeader(http.StatusOK)
            return
        }
        
        next.ServeHTTP(w, r)
    })
}

// ContentTypeJSON ensures JSON content type
func ContentTypeJSON(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        next.ServeHTTP(w, r)
    })
}
EOF
        
        # Models
        cat <<EOF > internal/models/models.go
package models

import "time"

// Add your data models here

// Example User model
type User struct {
    ID        string    \`json:"id"\`
    Name      string    \`json:"name"\`
    Email     string    \`json:"email"\`
    CreatedAt time.Time \`json:"created_at"\`
    UpdatedAt time.Time \`json:"updated_at"\`
}
EOF
        
        # Update go.mod to add chi dependency
        go get github.com/go-chi/chi/v5@latest
        ;;
    
    basic|*)
        # Standard Go project structure
        mkdir -p cmd/$PROJECT_NAME pkg internal
        
        # Create main.go in cmd directory
        cat <<EOF > cmd/$PROJECT_NAME/main.go
package main

import (
    "fmt"
    "log"
)

func main() {
    fmt.Println("Hello from $PROJECT_NAME!")
    
    // Example of using internal package
    // result := internal.ProcessData("example")
    // log.Printf("Result: %s", result)
    
    log.Println("Application started successfully")
}
EOF
        
        # Create example internal package
        mkdir -p internal/core
        cat <<EOF > internal/core/core.go
package core

// ProcessData processes the input data
func ProcessData(input string) string {
    // Add your business logic here
    return "Processed: " + input
}
EOF
        
        # Create example pkg (public package)
        mkdir -p pkg/utils
        cat <<EOF > pkg/utils/utils.go
package utils

import "strings"

// Normalize converts a string to lowercase and trims spaces
func Normalize(s string) string {
    return strings.ToLower(strings.TrimSpace(s))
}
EOF
        ;;
esac

# Create README.md
cat <<EOF > README.md
# $PROJECT_NAME

## Project Type: $PROJECT_TYPE

## Getting Started

### Prerequisites
- Go 1.21 or higher

### Installation

\`\`\`bash
git clone <repository-url>
cd $PROJECT_NAME
go mod tidy
\`\`\`

### Building

\`\`\`bash
go build -o bin/$PROJECT_NAME$([ "$PROJECT_TYPE" != "lib" ] && [ "$PROJECT_TYPE" != "minimal" ] && echo " cmd/$PROJECT_NAME/main.go" || [ "$PROJECT_TYPE" = "minimal" ] && echo " main.go" || echo "")
\`\`\`

### Running

EOF

# Add type-specific running instructions
case $PROJECT_TYPE in
    minimal)
        cat <<EOF >> README.md
\`\`\`bash
go run main.go
\`\`\`
EOF
        ;;
    lib)
        cat <<EOF >> README.md
This is a Go library. To use it in your project:

\`\`\`go
import "$PROJECT_NAME"

func main() {
    message := $PROJECT_NAME.Hello("Developer")
    fmt.Println(message)
}
\`\`\`

To run the example:
\`\`\`bash
go run examples/basic/main.go
\`\`\`
EOF
        ;;
    cli)
        cat <<EOF >> README.md
\`\`\`bash
# Run directly
go run cmd/$PROJECT_NAME/main.go

# Or build and run
./bin/$PROJECT_NAME

# See available commands
./bin/$PROJECT_NAME --help

# Run hello command
./bin/$PROJECT_NAME hello "Your Name"
\`\`\`
EOF
        ;;
    api)
        cat <<EOF >> README.md
\`\`\`bash
# Run the server
go run cmd/$PROJECT_NAME/main.go

# Or build and run
./bin/$PROJECT_NAME

# The server will start on port 8080 by default
# Set PORT environment variable to change it
PORT=3000 ./bin/$PROJECT_NAME
\`\`\`

### API Endpoints

- \`GET /\` - Home page
- \`GET /health\` - Health check
- \`GET /api/v1/hello?name=YourName\` - Hello endpoint
EOF
        ;;
    *)
        cat <<EOF >> README.md
\`\`\`bash
go run cmd/$PROJECT_NAME/main.go
\`\`\`
EOF
        ;;
esac

cat <<EOF >> README.md

### Testing

\`\`\`bash
go test ./...
go test -v ./...  # Verbose output
go test -cover ./...  # With coverage
\`\`\`

### Project Structure

EOF

# Add type-specific structure
case $PROJECT_TYPE in
    minimal)
        cat <<EOF >> README.md
\`\`\`
.
├── go.mod
├── main.go
└── README.md
\`\`\`
EOF
        ;;
    lib)
        cat <<EOF >> README.md
\`\`\`
.
├── go.mod
├── $PROJECT_NAME.go       # Main library file
├── $PROJECT_NAME_test.go  # Tests
├── internal/              # Private packages
├── examples/              # Example usage
│   └── basic/
│       └── main.go
└── README.md
\`\`\`
EOF
        ;;
    cli)
        cat <<EOF >> README.md
\`\`\`
.
├── cmd/
│   └── $PROJECT_NAME/
│       └── main.go        # Entry point
├── internal/
│   ├── commands/          # CLI commands
│   │   └── root.go
│   └── config/            # Configuration
│       └── config.go
├── go.mod
├── go.sum
└── README.md
\`\`\`
EOF
        ;;
    api)
        cat <<EOF >> README.md
\`\`\`
.
├── cmd/
│   └── $PROJECT_NAME/
│       └── main.go        # Entry point
├── internal/
│   ├── handlers/          # HTTP handlers
│   │   └── handlers.go
│   ├── middleware/        # Custom middleware
│   │   └── middleware.go
│   └── models/            # Data models
│       └── models.go
├── go.mod
├── go.sum
└── README.md
\`\`\`
EOF
        ;;
    *)
        cat <<EOF >> README.md
\`\`\`
.
├── cmd/
│   └── $PROJECT_NAME/
│       └── main.go        # Application entry point
├── internal/              # Private packages
│   └── core/
│       └── core.go
├── pkg/                   # Public packages
│   └── utils/
│       └── utils.go
├── go.mod
└── README.md
\`\`\`
EOF
        ;;
esac

cat <<EOF >> README.md

## Development

### Code Style

Format your code:
\`\`\`bash
go fmt ./...
\`\`\`

Lint your code:
\`\`\`bash
golangci-lint run
\`\`\`

### Dependencies

Add a new dependency:
\`\`\`bash
go get github.com/example/package
\`\`\`

Update dependencies:
\`\`\`bash
go get -u ./...
go mod tidy
\`\`\`

## License

[Add your license here]
EOF

# Create .gitignore
cat <<EOF > .gitignore
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with 'go test -c'
*.test

# Output of the go coverage tool
*.out

# Go workspace file
go.work

# Dependency directories
vendor/

# Go module files
go.sum

# IDE files
.idea/
.vscode/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Environment variables
.env
.env.local

# Build output
bin/
dist/

# Log files
*.log

# Temporary files
*.tmp
*.bak

# Project specific
EOF

# Add type-specific gitignore entries
case $PROJECT_TYPE in
    api)
        cat <<EOF >> .gitignore

# API specific
*.pem
*.key
*.crt
uploads/
static/
EOF
        ;;
    cli)
        cat <<EOF >> .gitignore

# CLI specific
config.json
config.yaml
EOF
        ;;
esac

# Create Makefile for common tasks
cat <<EOF > Makefile
.PHONY: build run test clean fmt lint

# Variables
BINARY_NAME=$PROJECT_NAME
$([ "$PROJECT_TYPE" != "lib" ] && [ "$PROJECT_TYPE" != "minimal" ] && echo "MAIN_PATH=cmd/\$(BINARY_NAME)/main.go" || [ "$PROJECT_TYPE" = "minimal" ] && echo "MAIN_PATH=main.go" || echo "")

# Build the application
build:
$([ "$PROJECT_TYPE" = "lib" ] && echo "	@echo \"This is a library project. Run 'make test' instead.\"" || echo "	go build -o bin/\$(BINARY_NAME) \$(MAIN_PATH)")

# Run the application
run:
$([ "$PROJECT_TYPE" = "lib" ] && echo "	@echo \"This is a library project. Run 'make example' instead.\"" || echo "	go run \$(MAIN_PATH)")

$([ "$PROJECT_TYPE" = "lib" ] && cat <<MAKEEOF

# Run example
example:
	go run examples/basic/main.go
MAKEEOF
)

# Run tests
test:
	go test -v ./...

# Run tests with coverage
test-coverage:
	go test -cover ./...

# Format code
fmt:
	go fmt ./...

# Run linter (requires golangci-lint)
lint:
	golangci-lint run

# Clean build artifacts
clean:
	rm -rf bin/
	go clean

# Download dependencies
deps:
	go mod download
	go mod tidy

# Update dependencies
update-deps:
	go get -u ./...
	go mod tidy
EOF

# Initialize git repository if not skipped
if [ "$SKIP_GIT" = false ]; then
    git init
    git add .
    git commit -m "Initial commit: $PROJECT_NAME Go project (type: $PROJECT_TYPE)"
fi

echo ""
echo "Go project '$PROJECT_NAME' created successfully at $go_dir/$PROJECT_NAME"
echo "Project type: $PROJECT_TYPE"
echo ""
echo "To start working on your project:"
echo "  cd $go_dir/$PROJECT_NAME"

# Add type-specific instructions
case $PROJECT_TYPE in
    api)
        echo "  go run cmd/$PROJECT_NAME/main.go  # Start the API server"
        ;;
    cli)
        echo "  go run cmd/$PROJECT_NAME/main.go --help  # See available commands"
        ;;
    lib)
        echo "  go test ./...  # Run tests"
        echo "  go run examples/basic/main.go  # Run example"
        ;;
    minimal)
        echo "  go run main.go"
        ;;
    *)
        echo "  go run cmd/$PROJECT_NAME/main.go"
        ;;
esac

echo ""
echo "Useful make commands:"
echo "  make build    # Build the application"
echo "  make run      # Run the application"
echo "  make test     # Run tests"
echo "  make fmt      # Format code"