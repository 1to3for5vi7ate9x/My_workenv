#!/bin/bash

# Default values
USE_TURBO=true
USE_ESLINT=true
USE_TAILWIND=true
USE_APP_ROUTER=true
PACKAGE_MANAGER="bun"
USE_TYPESCRIPT=true
SKIP_GIT=false
PROJECT_NAME=""

# Function to display help
show_help() {
    cat << EOF
Usage: next [PROJECT_NAME] [OPTIONS]

Create a new Next.js project with customizable settings.

OPTIONS:
    --no-turbo          Disable Turbopack
    --no-eslint         Disable ESLint
    --no-tailwind       Disable Tailwind CSS
    --pages             Use Pages Router instead of App Router
    --npm               Use npm as package manager
    --yarn              Use yarn as package manager
    --pnpm              Use pnpm as package manager
    --no-typescript     Use JavaScript instead of TypeScript
    --no-git            Skip git initialization
    -h, --help          Show this help message

EXAMPLES:
    next myproject                      # Create with default settings
    next myproject --no-turbo --npm     # Create without Turbopack using npm
    next myproject --pages --no-eslint  # Use Pages Router without ESLint

Default settings: TypeScript, Tailwind CSS, App Router, ESLint, Turbopack, Bun
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        --no-turbo)
            USE_TURBO=false
            shift
            ;;
        --no-eslint)
            USE_ESLINT=false
            shift
            ;;
        --no-tailwind)
            USE_TAILWIND=false
            shift
            ;;
        --pages)
            USE_APP_ROUTER=false
            shift
            ;;
        --npm)
            PACKAGE_MANAGER="npm"
            shift
            ;;
        --yarn)
            PACKAGE_MANAGER="yarn"
            shift
            ;;
        --pnpm)
            PACKAGE_MANAGER="pnpm"
            shift
            ;;
        --no-typescript)
            USE_TYPESCRIPT=false
            shift
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

# If no project name provided, prompt for it
if [ -z "$PROJECT_NAME" ]; then
    echo "Enter the Next.js project name:"
    read PROJECT_NAME
fi

# Show selected configuration
echo "Creating Next.js project with the following configuration:"
echo "  Project name: $PROJECT_NAME"
echo "  TypeScript: $([ "$USE_TYPESCRIPT" = true ] && echo "Yes" || echo "No")"
echo "  Tailwind CSS: $([ "$USE_TAILWIND" = true ] && echo "Yes" || echo "No")"
echo "  Router: $([ "$USE_APP_ROUTER" = true ] && echo "App Router" || echo "Pages Router")"
echo "  ESLint: $([ "$USE_ESLINT" = true ] && echo "Yes" || echo "No")"
echo "  Turbopack: $([ "$USE_TURBO" = true ] && echo "Yes" || echo "No")"
echo "  Package Manager: $PACKAGE_MANAGER"
echo "  Git initialization: $([ "$SKIP_GIT" = false ] && echo "Yes" || echo "No")"
echo ""

# Create the directory path
nextjs_dir="$HOME/Documents/Next-js"
mkdir -p "$nextjs_dir"

# Navigate to the Next.js directory
cd "$nextjs_dir"

# Build create-next-app command
CREATE_CMD="npx create-next-app@latest \"$PROJECT_NAME\""

# Add TypeScript flag
if [ "$USE_TYPESCRIPT" = true ]; then
    CREATE_CMD="$CREATE_CMD --ts"
else
    CREATE_CMD="$CREATE_CMD --js"
fi

# Add Tailwind flag
if [ "$USE_TAILWIND" = true ]; then
    CREATE_CMD="$CREATE_CMD --tailwind"
else
    CREATE_CMD="$CREATE_CMD --no-tailwind"
fi

# Add Router flag
if [ "$USE_APP_ROUTER" = true ]; then
    CREATE_CMD="$CREATE_CMD --app"
else
    CREATE_CMD="$CREATE_CMD --no-app"
fi

# Add src directory and import alias (standard for all projects)
CREATE_CMD="$CREATE_CMD --src-dir --import-alias \"@/*\""

# Add ESLint flag
if [ "$USE_ESLINT" = true ]; then
    CREATE_CMD="$CREATE_CMD --eslint"
else
    CREATE_CMD="$CREATE_CMD --no-eslint"
fi

# Add Turbopack flag
if [ "$USE_TURBO" = true ]; then
    CREATE_CMD="$CREATE_CMD --turbo"
else
    CREATE_CMD="$CREATE_CMD --no-turbo"
fi

# Add package manager flag
case $PACKAGE_MANAGER in
    npm)
        CREATE_CMD="$CREATE_CMD --use-npm"
        ;;
    yarn)
        CREATE_CMD="$CREATE_CMD --use-yarn"
        ;;
    pnpm)
        CREATE_CMD="$CREATE_CMD --use-pnpm"
        ;;
    bun)
        # Check if bun is installed
        if command -v bun &> /dev/null; then
            CREATE_CMD="$CREATE_CMD --use-bun"
        else
            echo "Bun not found. Falling back to npm..."
            echo "To install Bun, run: curl -fsSL https://bun.sh/install | bash"
            CREATE_CMD="$CREATE_CMD --use-npm"
            PACKAGE_MANAGER="npm"
        fi
        ;;
esac

# Execute the create-next-app command
echo "Running: $CREATE_CMD"
yes | eval $CREATE_CMD

# Navigate into the project directory
cd "$PROJECT_NAME"

# Add additional .gitignore entries
if [ "$SKIP_GIT" = false ]; then
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
    git commit -m "Initial commit: $PROJECT_NAME Next.js project setup"
fi

echo ""
echo "Next.js project '$PROJECT_NAME' created successfully at $nextjs_dir/$PROJECT_NAME"
echo ""
echo "To start working on your project:"
echo "  cd $nextjs_dir/$PROJECT_NAME"

# Show package manager specific commands
case $PACKAGE_MANAGER in
    npm)
        echo "  npm install  # Install dependencies if needed"
        echo "  npm run dev  # Start development server"
        ;;
    yarn)
        echo "  yarn         # Install dependencies if needed"
        echo "  yarn dev     # Start development server"
        ;;
    pnpm)
        echo "  pnpm install # Install dependencies if needed"
        echo "  pnpm dev     # Start development server"
        ;;
    bun)
        echo "  bun install  # Install dependencies if needed"
        echo "  bun dev      # Start development server"
        ;;
esac