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
Creates Python projects with different templates and configurations.

**Features:**
- Multiple project types (basic, ml, web, data, library, research)
- Conda or venv environment support
- Python version selection
- Type-specific dependencies and structure
- Comprehensive .gitignore
- Git repository initialization
- Projects created in ~/Documents/Python_projects/

**Usage:**
```bash
# Interactive mode
python_project

# With project name
python_project myproject

# Specific project types
python_project myml --type ml --python 3.10
python_project myweb --type web
python_project mylib --type library --no-conda
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
- `library`: Python package with setuptools, sphinx, build tools
- `research`: Research project with scipy, sympy, Jupyter

**Options:**
- `--type TYPE`: Choose project type
- `--python VERSION`: Python version (default: 3.11)
- `--no-conda`: Use venv instead of conda
- `--no-git`: Skip git initialization

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
```

3. Add aliases to your shell configuration file (~/.zshrc or ~/.bashrc):
```bash
alias go_project='~/My_workenv/create-go-project.sh'
alias next='~/My_workenv/create-nextjs-project.sh'
alias python_project='~/My_workenv/create-python-project.sh'
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
- For conda environments:
  - Miniconda or Anaconda
  - macOS: `brew install --cask miniconda`
  - Download from https://docs.conda.io/en/latest/miniconda.html
- For venv:
  - Python 3.8+ with venv module

## Directory Structure

All projects are organized in dedicated directories:
- Go projects: `~/Documents/Go_projects/`
- Next.js projects: `~/Documents/Next-js/`
- Python projects: `~/Documents/Python_projects/`

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

# Create a FastAPI web service with venv
python_project webservice --type web --no-conda

# Create a data analysis project
python_project analysis --type data

# Create a Python library package
python_project mypackage --type library
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