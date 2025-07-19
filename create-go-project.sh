#!/bin/bash

# Check if project name is provided as argument
if [ $# -eq 1 ]; then
    project_name="$1"
else
    # Prompt for the project name
    echo "Enter the Go project name:"
    read project_name
fi

# Create the directory path
go_dir="$HOME/Documents/Go_projects"
mkdir -p "$go_dir"

# Navigate to the Go projects directory
cd "$go_dir"

# Create the base directory
mkdir -p $project_name/{cmd/$project_name,pkg,internal}

# Navigate into the project directory
cd $project_name

# Initialize the Go module
go mod init $project_name

# Create a basic main.go file inside the cmd/ directory
cat <<EOF > cmd/$project_name/main.go
package main

import "fmt"

func main() {
    fmt.Println("Hello, $project_name!")
}
EOF

# Create a README file
cat <<EOF > README.md
# $project_name

This is a basic Go project setup.
EOF

# Create a .gitignore file
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

# OS files
.DS_Store
Thumbs.db

# Environment variables
.env
.env.local

# Build output
bin/
dist/
EOF

# Initialize git repository
git init
git add .
git commit -m "Initial commit: $project_name Go project setup"

echo "Go project '$project_name' created successfully at $go_dir/$project_name"
echo ""
echo "To start working on your project:"
echo "  cd $go_dir/$project_name"
echo "  go run cmd/$project_name/main.go"
