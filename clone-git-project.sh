#!/bin/bash

# Clone git project into language-specific directory

# Default values
SHALLOW=false
BRANCH=""
RECURSIVE=false
QUIET=false
FORCE=false
TARGET_LANG=""
CUSTOM_NAME=""
OPEN_AFTER=false
DEPTH=""

# Function to display help
show_help() {
    cat << EOF
Usage: clone [OPTIONS] GIT_URL

Clone a git repository into a language-specific directory based on the
primary language detected in the repository.

OPTIONS:
    -b, --branch BRANCH     Clone a specific branch
    -s, --shallow           Shallow clone (depth=1)
    -d, --depth N           Shallow clone with depth N
    -r, --recursive         Clone submodules recursively
    -q, --quiet             Suppress output
    -f, --force             Force clone even if directory exists
    -l, --lang LANGUAGE     Override language detection
    -n, --name NAME         Use custom directory name
    -o, --open              Open in VS Code after cloning
    -h, --help              Show this help message

SUPPORTED LANGUAGES:
    python, go, javascript/js, rust, java, c, ruby, php, swift, other

The repository will be cloned into:
  ~/Documents/Python_projects     for Python projects
  ~/Documents/Go_projects         for Go projects
  ~/Documents/JavaScript_projects for JavaScript/TypeScript projects
  ~/Documents/Rust_projects       for Rust projects
  ~/Documents/Java_projects       for Java projects
  ~/Documents/C_projects          for C/C++ projects
  ~/Documents/Ruby_projects       for Ruby projects
  ~/Documents/PHP_projects        for PHP projects
  ~/Documents/Swift_projects      for Swift projects
  ~/Documents/Other_projects      for other languages

EXAMPLES:
    clone https://github.com/user/repo.git
    clone -b develop https://github.com/user/repo.git
    clone --shallow https://github.com/user/repo.git
    clone -l rust -n my-project https://github.com/user/repo.git
    clone -o https://github.com/user/repo.git  # Clone and open in VS Code

The script will:
1. Clone the repository (with specified options)
2. Detect the primary language (unless overridden)
3. Move the repository to the appropriate directory
4. Display the final location

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -s|--shallow)
            SHALLOW=true
            DEPTH="1"
            shift
            ;;
        -d|--depth)
            SHALLOW=true
            DEPTH="$2"
            shift 2
            ;;
        -r|--recursive)
            RECURSIVE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -l|--lang)
            TARGET_LANG="$2"
            shift 2
            ;;
        -n|--name)
            CUSTOM_NAME="$2"
            shift 2
            ;;
        -o|--open)
            OPEN_AFTER=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
        *)
            GIT_URL="$1"
            shift
            ;;
    esac
done

# Check if URL is provided
if [[ -z "$GIT_URL" ]]; then
    echo "Error: No git URL provided"
    echo "Use -h or --help for usage information"
    exit 1
fi

# Extract repository name from URL or use custom name
if [[ -n "$CUSTOM_NAME" ]]; then
    REPO_NAME="$CUSTOM_NAME"
else
    REPO_NAME=$(basename "$GIT_URL" .git)
fi

# Create a temporary directory for cloning
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Build git clone command
GIT_CMD="git clone"

if [[ -n "$BRANCH" ]]; then
    GIT_CMD="$GIT_CMD -b $BRANCH"
fi

if [[ "$SHALLOW" == true ]] && [[ -n "$DEPTH" ]]; then
    GIT_CMD="$GIT_CMD --depth $DEPTH"
fi

if [[ "$RECURSIVE" == true ]]; then
    GIT_CMD="$GIT_CMD --recursive"
fi

if [[ "$QUIET" == true ]]; then
    GIT_CMD="$GIT_CMD -q"
    echo "Cloning repository..."
else
    echo "Cloning repository..."
fi

# Execute git clone
if [[ "$QUIET" == true ]]; then
    if ! $GIT_CMD "$GIT_URL" "$TEMP_DIR/$REPO_NAME" 2>/dev/null; then
        echo "Error: Failed to clone repository"
        exit 1
    fi
else
    if ! $GIT_CMD "$GIT_URL" "$TEMP_DIR/$REPO_NAME"; then
        echo "Error: Failed to clone repository"
        exit 1
    fi
fi

cd "$TEMP_DIR/$REPO_NAME"

# Function to count files by extension
count_files() {
    local ext="$1"
    find . -type f -name "*.$ext" 2>/dev/null | grep -v "/.git/" | wc -l | tr -d ' '
}

# Count files for each language
py_count=$(count_files "py")
go_count=$(count_files "go")
js_count=$(($(count_files "js") + $(count_files "jsx") + $(count_files "ts") + $(count_files "tsx")))
rs_count=$(count_files "rs")
java_count=$(count_files "java")
c_count=$(($(count_files "c") + $(count_files "cpp") + $(count_files "cc") + $(count_files "h") + $(count_files "hpp")))
rb_count=$(count_files "rb")
php_count=$(count_files "php")
swift_count=$(count_files "swift")

# Also check for language-specific files
[ -f "package.json" ] && js_count=$((js_count + 10))
[ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ] && py_count=$((py_count + 10))
[ -f "go.mod" ] && go_count=$((go_count + 10))
[ -f "Cargo.toml" ] && rs_count=$((rs_count + 10))
[ -f "pom.xml" ] || [ -f "build.gradle" ] && java_count=$((java_count + 10))
[ -f "Gemfile" ] && rb_count=$((rb_count + 10))
[ -f "composer.json" ] && php_count=$((php_count + 10))
[ -f "Package.swift" ] && swift_count=$((swift_count + 10))

# Check if language was manually specified
if [[ -n "$TARGET_LANG" ]]; then
    # Normalize language input
    case "${TARGET_LANG,,}" in
        "python"|"py")
            primary_lang="Python"
            ;;
        "go"|"golang")
            primary_lang="Go"
            ;;
        "javascript"|"js"|"typescript"|"ts")
            primary_lang="JavaScript"
            ;;
        "rust"|"rs")
            primary_lang="Rust"
            ;;
        "java")
            primary_lang="Java"
            ;;
        "c"|"cpp"|"c++")
            primary_lang="C"
            ;;
        "ruby"|"rb")
            primary_lang="Ruby"
            ;;
        "php")
            primary_lang="PHP"
            ;;
        "swift")
            primary_lang="Swift"
            ;;
        "other")
            primary_lang="Other"
            ;;
        *)
            echo "Warning: Unknown language '$TARGET_LANG', using 'Other'"
            primary_lang="Other"
            ;;
    esac
else
    # Auto-detect the primary language
    max_count=0
    primary_lang="Other"

    if [ $py_count -gt $max_count ]; then
        max_count=$py_count
        primary_lang="Python"
    fi

    if [ $go_count -gt $max_count ]; then
        max_count=$go_count
        primary_lang="Go"
    fi

    if [ $js_count -gt $max_count ]; then
        max_count=$js_count
        primary_lang="JavaScript"
    fi

    if [ $rs_count -gt $max_count ]; then
        max_count=$rs_count
        primary_lang="Rust"
    fi

    if [ $java_count -gt $max_count ]; then
        max_count=$java_count
        primary_lang="Java"
    fi

    if [ $c_count -gt $max_count ]; then
        max_count=$c_count
        primary_lang="C"
    fi

    if [ $rb_count -gt $max_count ]; then
        max_count=$rb_count
        primary_lang="Ruby"
    fi

    if [ $php_count -gt $max_count ]; then
        max_count=$php_count
        primary_lang="PHP"
    fi

    if [ $swift_count -gt $max_count ]; then
        max_count=$swift_count
        primary_lang="Swift"
    fi
fi

# Set target directory based on language
case $primary_lang in
    "Python")
        TARGET_DIR="$HOME/Documents/Python_projects"
        ;;
    "Go")
        TARGET_DIR="$HOME/Documents/Go_projects"
        ;;
    "JavaScript")
        TARGET_DIR="$HOME/Documents/JavaScript_projects"
        ;;
    "Rust")
        TARGET_DIR="$HOME/Documents/Rust_projects"
        ;;
    "Java")
        TARGET_DIR="$HOME/Documents/Java_projects"
        ;;
    "C")
        TARGET_DIR="$HOME/Documents/C_projects"
        ;;
    "Ruby")
        TARGET_DIR="$HOME/Documents/Ruby_projects"
        ;;
    "PHP")
        TARGET_DIR="$HOME/Documents/PHP_projects"
        ;;
    "Swift")
        TARGET_DIR="$HOME/Documents/Swift_projects"
        ;;
    *)
        TARGET_DIR="$HOME/Documents/Other_projects"
        ;;
esac

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Check if repository already exists in target directory
if [ -d "$TARGET_DIR/$REPO_NAME" ]; then
    if [[ "$FORCE" == true ]]; then
        [[ "$QUIET" != true ]] && echo "Force replacing existing repository..."
        rm -rf "$TARGET_DIR/$REPO_NAME"
    else
        echo "Warning: Repository '$REPO_NAME' already exists in $TARGET_DIR"
        echo -n "Do you want to replace it? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Cloning cancelled."
            exit 0
        fi
        rm -rf "$TARGET_DIR/$REPO_NAME"
    fi
fi

# Move repository to target directory
mv "$TEMP_DIR/$REPO_NAME" "$TARGET_DIR/"

# Output results
if [[ "$QUIET" != true ]]; then
    echo ""
    echo "Repository cloned successfully!"
    if [[ -n "$TARGET_LANG" ]]; then
        echo "Language: $primary_lang (manually specified)"
    else
        echo "Language detected: $primary_lang"
    fi
    echo "Location: $TARGET_DIR/$REPO_NAME"
    if [[ -n "$BRANCH" ]]; then
        echo "Branch: $BRANCH"
    fi
    echo ""
    echo "To navigate to the project:"
    echo "  cd $TARGET_DIR/$REPO_NAME"
fi

# Open in VS Code if requested
if [[ "$OPEN_AFTER" == true ]]; then
    if command -v code &> /dev/null; then
        [[ "$QUIET" != true ]] && echo "Opening in VS Code..."
        code "$TARGET_DIR/$REPO_NAME"
    else
        echo "Warning: VS Code command 'code' not found. Please install VS Code or add it to PATH."
    fi
fi