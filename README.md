# My Work Environment Scripts

This directory contains utility scripts for quickly setting up new projects with customizable options.

## Scripts

### 1. create-go-project.sh
Creates a new Go project with customizable structure and project types.

**Features:**
- Multiple project types (basic, cli, api, lib, minimal)
- Automatic dependency installation for CLI and API projects
- Go module initialization
- Comprehensive .gitignore
- Makefile for common tasks
- Git repository initialization
- Projects created in ~/Documents/Go_projects/

**Usage:**
```bash
# Interactive mode
go_project

# With project name
go_project myproject

# With specific type
go_project mycli --type cli
go_project myapi --type api
go_project mylib --type lib

# Skip git initialization
go_project myproject --no-git

# Show help
go_project --help
```

**Project Types:**
- `basic` (default): Standard layout with cmd/, pkg/, internal/
- `cli`: CLI application with Cobra framework
- `api`: REST API with Chi router
- `lib`: Go library (no cmd directory)
- `minimal`: Single main.go file

### 2. create-nextjs-project.sh
Creates a new Next.js project with extensive customization options.

**Features:**
- Configurable TypeScript, ESLint, Tailwind CSS, Turbopack
- Choice of package managers (bun, npm, yarn, pnpm)
- App Router or Pages Router
- Enhanced .gitignore
- Git repository initialization
- Projects created in ~/Documents/Next-js/

**Usage:**
```bash
# Interactive mode
next

# With project name
next myproject

# Custom configurations
next myproject --no-turbo --npm
next myproject --pages --no-eslint
next myproject --no-typescript --yarn
next myproject --no-tailwind --no-git

# Show help
next --help
```

**Options:**
- `--no-turbo`: Disable Turbopack
- `--no-eslint`: Disable ESLint
- `--no-tailwind`: Disable Tailwind CSS
- `--pages`: Use Pages Router instead of App Router
- `--npm/--yarn/--pnpm`: Choose package manager (default: bun)
- `--no-typescript`: Use JavaScript instead of TypeScript
- `--no-git`: Skip git initialization

### 3. create-python-project.sh
Creates Python projects using Poetry for modern dependency management.

**Features:**
- Multiple project types (basic, ml, web, data, library, research)
- Poetry-based dependency management and virtual environments
- Python version selection
- Type-specific dependencies and structure
- Comprehensive .gitignore
- Git repository initialization
- Automatic pyproject.toml configuration with tool settings
- Built-in support for black, flake8, mypy, pytest
- Projects created in ~/Documents/Python_projects/

**Prerequisites:**
- Poetry must be installed (see Prerequisites section above)

**Usage:**
```bash
# Interactive mode
python_project

# With project name
python_project myproject

# Specific project types
python_project myml --type ml --python 3.10
python_project myweb --type web
python_project mylib --type library
python_project mydata --type data
python_project myresearch --type research

# Show help
python_project --help
```

**Project Types:**
- `basic` (default): Standard Python project with numpy, pandas, pytest
- `ml`: Machine Learning with TensorFlow/PyTorch, scikit-learn, MLflow
- `web`: Web application with FastAPI, SQLAlchemy, uvicorn
- `data`: Data analysis with pandas, matplotlib, plotly, Jupyter
- `library`: Python package ready for PyPI publishing
- `research`: Research project with scipy, sympy, Jupyter

**Options:**
- `--type TYPE`: Choose project type
- `--python VERSION`: Python version (default: 3.11)
- `--no-git`: Skip git initialization

**Poetry Commands:**
```bash
# Install dependencies
poetry install

# Add dependencies
poetry add numpy pandas
poetry add --group dev pytest black

# Activate environment
poetry shell

# Run commands
poetry run python src/main.py
poetry run pytest

# Build/publish (libraries)
poetry build
poetry publish
```

**Windows Notes:**
- The bash script works in Git Bash or WSL
- Poetry commands work the same across all platforms
- Use forward slashes in Git Bash, backslashes in Windows CMD/PowerShell

### 4. clone-git-project.sh
Clones git repositories into language-specific directories with automatic language detection.

**Features:**
- Automatic language detection based on file extensions and config files
- Support for multiple languages (Python, Go, JavaScript, Rust, Java, C/C++, Ruby, PHP, Swift)
- Git clone options (branch, shallow, recursive)
- Custom naming and language override
- VS Code integration
- Projects organized by language in ~/Documents/[Language]_projects/

**Usage:**
```bash
# Basic clone with auto-detection
clone https://github.com/user/repo.git

# Clone specific branch
clone -b develop https://github.com/user/repo.git

# Shallow clone for faster download
clone --shallow https://github.com/user/repo.git
clone -d 10 https://github.com/user/repo.git  # depth of 10

# Force language and custom name
clone -l rust -n my-rust-app https://github.com/user/repo.git

# Clone and open in VS Code
clone -o https://github.com/user/repo.git

# Clone with submodules
clone -r https://github.com/user/repo.git

# Quiet mode
clone -q https://github.com/user/repo.git

# Force replace existing repository
clone -f https://github.com/user/repo.git

# Combine multiple flags
clone -b main -s -o -l python https://github.com/user/repo.git

# Show help
clone --help
```

**Options:**
- `-b, --branch BRANCH`: Clone a specific branch
- `-s, --shallow`: Shallow clone with depth=1
- `-d, --depth N`: Shallow clone with custom depth
- `-r, --recursive`: Clone submodules recursively
- `-q, --quiet`: Suppress output
- `-f, --force`: Skip confirmation when replacing existing repos
- `-l, --lang LANGUAGE`: Override language detection (python, go, javascript/js, rust, java, c, ruby, php, swift, other)
- `-n, --name NAME`: Use custom directory name
- `-o, --open`: Open in VS Code after cloning

**Language Detection:**
The script detects languages by:
1. Counting file extensions (.py, .go, .js, .rs, etc.)
2. Looking for language-specific files (package.json, requirements.txt, go.mod, Cargo.toml, etc.)
3. Choosing the most prevalent language

**Directory Organization:**
- Python → `~/Documents/Python_projects/`
- Go → `~/Documents/Go_projects/`
- JavaScript/TypeScript → `~/Documents/JavaScript_projects/`
- Rust → `~/Documents/Rust_projects/`
- Java → `~/Documents/Java_projects/`
- C/C++ → `~/Documents/C_projects/`
- Ruby → `~/Documents/Ruby_projects/`
- PHP → `~/Documents/PHP_projects/`
- Swift → `~/Documents/Swift_projects/`
- Others → `~/Documents/Other_projects/`

## Installation

### macOS/Linux

1. Clone or copy the My_workenv directory to your home folder:
```bash
mkdir ~/My_workenv
```

2. Copy the scripts to the directory and make them executable:
```bash
chmod +x ~/My_workenv/create-go-project.sh
chmod +x ~/My_workenv/create-nextjs-project.sh
chmod +x ~/My_workenv/create-python-project.sh
chmod +x ~/My_workenv/clone-git-project.sh
```

3. Add aliases to your shell configuration file (~/.zshrc or ~/.bashrc):
```bash
alias go_project='~/My_workenv/create-go-project.sh'
alias next='~/My_workenv/create-nextjs-project.sh'
alias python_project='~/My_workenv/create-python-project.sh'
alias clone='~/My_workenv/clone-git-project.sh'
```

4. Reload your shell configuration:
```bash
source ~/.zshrc  # or source ~/.bashrc
```

### Windows

For Windows users, you have several options:

#### Option 1: Using Git Bash
1. Install Git for Windows (includes Git Bash)
2. Follow the macOS/Linux instructions above

#### Option 2: Using WSL (Windows Subsystem for Linux)
1. Install WSL2
2. Follow the macOS/Linux instructions above

#### Option 3: PowerShell Scripts
1. Create PowerShell versions of these scripts
2. Add to your PowerShell profile:
```powershell
# In your PowerShell profile
function go_project { & "$HOME\My_workenv\create-go-project.ps1" }
function next { & "$HOME\My_workenv\create-nextjs-project.ps1" }
function python_project { & "$HOME\My_workenv\create-python-project.ps1" }
```

## Prerequisites

### For Go Projects:
- Go 1.21 or higher (`brew install go` on macOS or download from https://golang.org)

### For Next.js Projects:
- Node.js 18+ (https://nodejs.org)
- Package managers (optional):
  - Bun (recommended): `curl -fsSL https://bun.sh/install | bash`
  - Yarn: `npm install -g yarn`
  - PNPM: `npm install -g pnpm`

### For Python Projects:
- Python 3.8 or higher (https://python.org)
- Poetry (required):
  ```bash
  # macOS/Linux:
  curl -sSL https://install.python-poetry.org | python3 -
  
  # Windows (PowerShell):
  (Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | py -
  
  # Windows (Git Bash):
  curl -sSL https://install.python-poetry.org | python -
  ```
  - Download from https://docs.conda.io/en/latest/miniconda.html
- For venv:
  - Python 3.8+ with venv module

## Directory Structure

All projects are organized in dedicated directories:
- Go projects: `~/Documents/Go_projects/`
- Next.js projects: `~/Documents/Next-js/`
- Python projects: `~/Documents/Python_projects/`
- Cloned repositories: Organized by detected language in `~/Documents/[Language]_projects/`

## Advanced Usage Examples

### Go Projects
```bash
# Create a REST API with Chi router
go_project taskapi --type api

# Create a CLI tool with Cobra
go_project devtool --type cli

# Create a Go library
go_project utils --type lib --no-git
```

### Next.js Projects
```bash
# Create a minimal Next.js app without extra features
next simple-app --no-turbo --no-eslint --no-tailwind

# Create a Pages Router app with npm
next legacy-app --pages --npm

# Create a JavaScript project with Yarn
next js-app --no-typescript --yarn
```

### Python Projects
```bash
# Create an ML project with Python 3.10
python_project mlmodel --type ml --python 3.10

# Create a FastAPI web service
python_project webservice --type web

# Create a data analysis project
python_project analysis --type data

# Create a Python library package ready for PyPI
python_project mypackage --type library

# Work with Poetry after project creation
cd ~/Documents/Python_projects/myproject
poetry shell  # Activate environment
poetry add requests  # Add dependency
poetry run pytest  # Run tests
poetry build  # Build package
```

### Clone Projects
```bash
# Clone a Rust project with shallow depth
clone -s https://github.com/rust-lang/rust.git

# Clone a specific branch and open in VS Code
clone -b feature/new-ui -o https://github.com/user/webapp.git

# Clone with custom name to Python projects
clone -l python -n ml-experiment https://github.com/scikit-learn/scikit-learn.git

# Clone quietly with submodules
clone -q -r https://github.com/user/complex-project.git

# Force clone to replace existing
clone -f https://github.com/user/myproject.git
```

## Features Common to All Scripts

1. **Interactive and CLI modes**: Use with or without arguments
2. **Git initialization**: Automatic git repo setup with initial commit
3. **Comprehensive .gitignore**: Language-specific ignore patterns
4. **Project documentation**: Auto-generated README with instructions
5. **Help command**: Use `-h` or `--help` for detailed options

## Customization

You can modify these scripts to:
- Change default settings
- Add new project types
- Modify directory structures
- Add custom boilerplate code
- Include additional tools or frameworks
- Change default package managers or versions

## Contributing

Feel free to fork and modify these scripts for your own needs. Some ideas for extensions:
- Add Docker support with Dockerfile generation
- Include CI/CD configuration files
- Add database setup for web projects
- Include testing frameworks setup
- Add linting and formatting configurations

## License

These scripts are provided as-is for personal use. Feel free to modify and distribute as needed.