# My Work Environment Scripts

This directory contains utility scripts for quickly setting up new projects.

## Scripts

### 1. create-go-project.sh
Creates a new Go project with a standard directory structure.

**Features:**
- Creates organized folder structure (cmd, pkg, internal)
- Initializes Go module
- Creates basic main.go file
- Generates README.md
- Comprehensive .gitignore for Go projects
- Git repository initialization with initial commit
- Projects created in ~/Documents/Go_projects/

**Usage:**
```bash
# Option 1: Interactive
go_project
# Enter project name when prompted

# Option 2: With project name
go_project myproject
```

### 2. create-nextjs-project.sh
Creates a new Next.js project with predefined settings.

**Features:**
- TypeScript enabled
- Tailwind CSS configured
- App Router structure
- ESLint enabled
- Turbopack enabled for faster development
- Bun package manager (faster than npm)
- Enhanced .gitignore with additional entries
- Git repository initialization with initial commit
- Projects created in ~/Documents/Next-js/

**Usage:**
```bash
# Option 1: Interactive
next
# Enter project name when prompted

# Option 2: With project name
next myproject
```

### 3. create-python-project.sh
Creates a new Python project with conda environment and standard structure.

**Features:**
- Creates dedicated conda environment for each project
- Python 3.11 by default
- Standard project structure (src, tests, data, notebooks)
- Pre-configured requirements.txt with common packages
- Comprehensive .gitignore for Python projects
- README with environment activation instructions
- Sample test file with pytest setup
- Git repository initialization with initial commit
- Projects created in ~/Documents/Python_projects/

**Usage:**
```bash
# Option 1: Interactive
python_project
# Enter project name when prompted

# Option 2: With project name
python_project myproject
```

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
- Go installed (`brew install go` on macOS or download from https://golang.org)

### For Next.js Projects:
- Node.js installed (https://nodejs.org)
- Bun installed (optional but recommended): 
  ```bash
  curl -fsSL https://bun.sh/install | bash
  ```
  If Bun is not installed, the script will fall back to npm.

### For Python Projects:
- Miniconda or Anaconda installed
  - macOS: `brew install --cask miniconda`
  - Or download from https://docs.conda.io/en/latest/miniconda.html

## Customization

Feel free to modify these scripts to match your preferences:
- Change default project structures
- Add or remove boilerplate files
- Modify package manager settings
- Add additional setup steps