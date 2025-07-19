#!/bin/bash

# Check if project name is provided as argument
if [ $# -eq 1 ]; then
    project_name="$1"
else
    # Prompt for the project name
    echo "Enter the Next.js project name:"
    read project_name
fi

# Create the directory path
nextjs_dir="$HOME/Documents/Next-js"
mkdir -p "$nextjs_dir"

# Navigate to the Next.js directory
cd "$nextjs_dir"

# Create the Next.js project with default settings
# Using yes to auto-accept npx package installation
# --eslint flag to enable ESLint
# --turbo flag to enable Turbopack
yes | npx create-next-app@latest "$project_name" --ts --tailwind --app --src-dir --import-alias "@/*" --use-bun --eslint --turbo

# Navigate into the project directory
cd "$project_name"

# Next.js already creates a .gitignore, but let's ensure it has comprehensive entries
cat <<EOF >> .gitignore

# Additional entries
# Environment variables
.env
.env.local
.env.production.local
.env.development.local
.env.test.local

# IDE files
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
bun-error.log*
lerna-debug.log*

# Testing
coverage/
.nyc_output/

# Misc
*.pem
EOF

# Initialize git repository (Next.js might already do this, but we'll ensure it)
if [ ! -d .git ]; then
    git init
fi
git add .
git commit -m "Initial commit: $project_name Next.js project setup"

echo "Next.js project '$project_name' created successfully at $nextjs_dir/$project_name"
echo ""
echo "To start working on your project:"
echo "  cd $nextjs_dir/$project_name"
echo "  bun install  # Install dependencies if needed"
echo "  bun dev      # Start development server"