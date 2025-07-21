#!/bin/bash

# Detect OS for cross-platform compatibility
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    IS_WINDOWS=true
else
    IS_WINDOWS=false
fi

# Default values
PROJECT_TYPE="basic"
PYTHON_VERSION="3.11"
SKIP_GIT=false
PROJECT_NAME=""

# Function to display help
show_help() {
    cat << EOF
Usage: python_project [PROJECT_NAME] [OPTIONS]

Create a new Python project with customizable settings and templates.

OPTIONS:
    --type TYPE         Project type (default: basic)
                        Available types:
                        - basic: Basic Python project
                        - ml: Machine Learning project
                        - web: Web application project
                        - data: Data analysis project
                        - library: Python library/package
                        - research: Research/scientific project
    
    --python VERSION    Python version (default: 3.11)
                        Examples: 3.10, 3.11, 3.12
    
    --no-git            Skip git initialization
    -h, --help          Show this help message

EXAMPLES:
    python_project myproject                    # Basic project with defaults
    python_project myml --type ml --python 3.10 # ML project with Python 3.10
    python_project mylib --type library         # Library project

Project types include different dependencies and structures:
- basic: numpy, pandas, pytest, black, flake8, mypy
- ml: scikit-learn, tensorflow, pytorch, jupyter, matplotlib
- web: fastapi/flask, uvicorn, requests, sqlalchemy
- data: pandas, numpy, matplotlib, seaborn, jupyter, plotly
- library: setuptools, build, twine, pytest, sphinx
- research: jupyter, matplotlib, scipy, sympy, seaborn
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
        --python)
            PYTHON_VERSION="$2"
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
    basic|ml|web|data|library|research)
        ;;
    *)
        echo "Invalid project type: $PROJECT_TYPE"
        echo "Valid types: basic, ml, web, data, library, research"
        exit 1
        ;;
esac

# If no project name provided, prompt for it
if [ -z "$PROJECT_NAME" ]; then
    echo "Enter the Python project name:"
    read PROJECT_NAME
fi

# Check if Poetry is installed
if ! command -v poetry &> /dev/null; then
    echo "Error: Poetry is not installed."
    echo "Please install Poetry by running:"
    if [ "$IS_WINDOWS" = true ]; then
        echo "  (Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | py -"
        echo "  OR"
        echo "  curl -sSL https://install.python-poetry.org | python -"
    else
        echo "  curl -sSL https://install.python-poetry.org | python3 -"
    fi
    echo "Or visit: https://python-poetry.org/docs/#installation"
    exit 1
fi

# Show selected configuration
echo "Creating Python project with the following configuration:"
echo "  Project name: $PROJECT_NAME"
echo "  Project type: $PROJECT_TYPE"
echo "  Python version: $PYTHON_VERSION"
echo "  Package manager: Poetry"
echo "  Git initialization: $([ "$SKIP_GIT" = false ] && echo "Yes" || echo "No")"
echo ""

# Create the directory path
if [ "$IS_WINDOWS" = true ]; then
    # Windows path
    python_dir="$USERPROFILE/Documents/Python_projects"
    # Convert Windows path for use in bash
    python_dir=$(cygpath -u "$python_dir" 2>/dev/null || echo "$python_dir")
else
    # Unix-like systems
    python_dir="$HOME/Documents/Python_projects"
fi
mkdir -p "$python_dir"

# Navigate to the Python projects directory
cd "$python_dir"

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize Poetry project
echo "Initializing Poetry project..."
poetry init --no-interaction --name "$PROJECT_NAME" --python "^$PYTHON_VERSION"

# Configure Poetry to create virtual environment in project directory (optional)
# poetry config virtualenvs.in-project true

# Install Python version if needed and create virtual environment
echo "Setting up Python $PYTHON_VERSION environment..."
if [ "$IS_WINDOWS" = true ]; then
    # Try python launcher first, then python.exe
    if command -v py &> /dev/null; then
        poetry env use py -$PYTHON_VERSION
    else
        poetry env use python$PYTHON_VERSION
    fi
else
    poetry env use python$PYTHON_VERSION
fi

# Create project structure based on type
case $PROJECT_TYPE in
    basic)
        mkdir -p src tests data notebooks
        ;;
    ml)
        mkdir -p src tests data notebooks models experiments
        ;;
    web)
        mkdir -p src tests static templates api
        ;;
    data)
        mkdir -p src tests data notebooks reports visualizations
        ;;
    library)
        mkdir -p src/$PROJECT_NAME tests docs examples
        ;;
    research)
        mkdir -p src tests data notebooks papers figures results
        ;;
esac

# Create main.py or appropriate entry point
case $PROJECT_TYPE in
    web)
        cat <<EOF > src/main.py
#!/usr/bin/env python3
"""
$PROJECT_NAME - Web Application
"""
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI(title="$PROJECT_NAME")


@app.get("/")
async def root():
    """Root endpoint"""
    return JSONResponse({"message": "Welcome to $PROJECT_NAME API"})


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return JSONResponse({"status": "healthy"})


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF
        ;;
    library)
        mkdir -p src/$PROJECT_NAME
        cat <<EOF > src/$PROJECT_NAME/__init__.py
"""
$PROJECT_NAME - A Python library
"""

__version__ = "0.1.0"
__author__ = "Your Name"
__email__ = "your.email@example.com"

from .$PROJECT_NAME import *
EOF
        cat <<EOF > src/$PROJECT_NAME/$PROJECT_NAME.py
"""
Main module for $PROJECT_NAME
"""


def hello():
    """Example function"""
    return "Hello from $PROJECT_NAME!"
EOF
        ;;
    *)
        cat <<EOF > src/main.py
#!/usr/bin/env python3
"""
$PROJECT_NAME - Main module
"""


def main():
    """Main function"""
    print("Hello from $PROJECT_NAME!")


if __name__ == "__main__":
    main()
EOF
        ;;
esac

# Create __init__.py files
touch src/__init__.py 2>/dev/null
touch tests/__init__.py

# Add dependencies based on project type using Poetry
case $PROJECT_TYPE in
    basic)
        echo "Adding basic project dependencies..."
        # Core dependencies
        poetry add numpy pandas
        # Development dependencies
        poetry add --group dev pytest pytest-cov black flake8 mypy ipython
        ;;
    ml)
        echo "Adding ML project dependencies..."
        # Core ML dependencies
        poetry add numpy pandas scikit-learn matplotlib seaborn jupyter jupyterlab
        # ML utilities
        poetry add mlflow optuna xgboost lightgbm
        # Deep Learning - TensorFlow by default (can be changed to PyTorch)
        poetry add tensorflow
        # Development dependencies
        poetry add --group dev pytest black flake8 mypy
        ;;
    web)
        echo "Adding web project dependencies..."
        # Web framework
        poetry add fastapi "uvicorn[standard]" pydantic python-multipart
        # Database
        poetry add sqlalchemy alembic asyncpg
        # API utilities
        poetry add httpx "python-jose[cryptography]" "passlib[bcrypt]" python-dotenv
        # Development dependencies
        poetry add --group dev pytest pytest-asyncio black flake8 mypy
        ;;
    data)
        echo "Adding data analysis project dependencies..."
        # Data analysis dependencies
        poetry add numpy pandas matplotlib seaborn plotly scipy statsmodels
        # Data processing
        poetry add openpyxl xlrd pyarrow
        # Jupyter
        poetry add jupyter jupyterlab ipywidgets
        # Development dependencies
        poetry add --group dev pytest black flake8 mypy
        ;;
    library)
        echo "Adding library project dependencies..."
        # Development dependencies only (libraries should have minimal runtime deps)
        poetry add --group dev pytest pytest-cov black flake8 mypy sphinx sphinx-rtd-theme
        # Build tools are handled by Poetry itself
        ;;
    research)
        echo "Adding research project dependencies..."
        # Scientific computing
        poetry add numpy scipy sympy matplotlib seaborn
        # Data handling
        poetry add pandas h5py netCDF4
        # Jupyter
        poetry add jupyter jupyterlab ipywidgets notebook
        # Plotting and visualization
        poetry add plotly bokeh
        # Development dependencies
        poetry add --group dev pytest black flake8 mypy
        ;;
esac

# Update pyproject.toml with additional configurations
echo "Configuring pyproject.toml..."

# Add common tool configurations
cat <<EOF >> pyproject.toml

[tool.black]
line-length = 88
target-version = ['py38', 'py39', 'py310', 'py311', 'py312']

[tool.mypy]
python_version = "$PYTHON_VERSION"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_classes = "Test*"
python_functions = "test_*"

[tool.coverage.run]
source = ["src"]
omit = ["*/tests/*", "*/test_*.py"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
]
EOF

# Add library-specific configurations
if [ "$PROJECT_TYPE" = "library" ]; then
    # Update pyproject.toml for library projects
    poetry config repositories.testpypi https://test.pypi.org/legacy/
    
    # Add package configuration
    cat <<EOF > temp_pyproject.toml
[tool.poetry]
name = "$PROJECT_NAME"
version = "0.1.0"
description = "A short description of your project"
authors = ["Your Name <your.email@example.com>"]
readme = "README.md"
license = "MIT"
homepage = "https://github.com/yourusername/$PROJECT_NAME"
repository = "https://github.com/yourusername/$PROJECT_NAME"
keywords = ["python", "library"]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "Topic :: Software Development :: Libraries :: Python Modules",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
packages = [{include = "$PROJECT_NAME", from = "src"}]

[tool.poetry.dependencies]
python = "^$PYTHON_VERSION"

[tool.poetry.group.dev.dependencies]
EOF
    
    # Merge with existing pyproject.toml
    mv pyproject.toml pyproject_old.toml
    cat temp_pyproject.toml > pyproject.toml
    grep -A 1000 "\[tool.poetry.group.dev.dependencies\]" pyproject_old.toml | tail -n +2 >> pyproject.toml
    cat pyproject_old.toml | grep -A 1000 "\[tool.black\]" >> pyproject.toml
    rm temp_pyproject.toml pyproject_old.toml
fi

# Create .gitignore
cat <<EOF > .gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*\$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
target/

# Jupyter Notebook
.ipynb_checkpoints

# pyenv
.python-version

# celery beat schedule file
celerybeat-schedule

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# IDE
.idea/
.vscode/
*.swp
*.swo

# Data files (customize based on your needs)
data/
*.csv
*.xlsx
*.json
*.db
*.sqlite
*.h5
*.hdf5
*.parquet

# Model files
models/
*.pkl
*.pickle
*.h5
*.pt
*.pth
*.onnx
*.pb
*.tflite

# Logs
logs/
*.log

# OS files
.DS_Store
Thumbs.db

# Project specific
EOF

# Add project-type specific gitignore entries
case $PROJECT_TYPE in
    ml)
        cat <<EOF >> .gitignore

# ML specific
mlruns/
experiments/
checkpoints/
*.ckpt
tensorboard/
EOF
        ;;
    research)
        cat <<EOF >> .gitignore

# Research specific
papers/*.pdf
figures/*.png
figures/*.jpg
figures/*.svg
results/*.csv
results/*.json
EOF
        ;;
esac

# Create README.md with environment activation instructions
cat <<EOF > README.md
# $PROJECT_NAME

## Project Type: $PROJECT_TYPE

## Setup Instructions

### 1. Activate the Environment

EOF

cat <<EOF >> README.md
This project uses Poetry for dependency management.

To activate the Poetry shell (virtual environment):
\`\`\`bash
poetry shell
\`\`\`

Alternatively, you can run commands within the Poetry environment:
\`\`\`bash
poetry run python src/main.py
poetry run pytest
\`\`\`

On Windows, you can also use:
\`\`\`powershell
poetry run python src\\main.py
poetry run pytest
\`\`\`

To deactivate the Poetry shell:
\`\`\`bash
exit
\`\`\`
EOF

cat <<EOF >> README.md

### 2. Install Dependencies

Poetry manages dependencies automatically. To install all dependencies:
\`\`\`bash
poetry install
\`\`\`

To add new dependencies:
\`\`\`bash
# Add a runtime dependency
poetry add package-name

# Add a development dependency
poetry add --group dev package-name
\`\`\`

### 3. Project Structure

\`\`\`
$PROJECT_NAME/
EOF

# Add project-specific structure to README
case $PROJECT_TYPE in
    basic)
        cat <<EOF >> README.md
├── src/              # Source code
│   ├── __init__.py
│   └── main.py
├── tests/            # Test files
│   └── __init__.py
├── data/             # Data files (gitignored)
├── notebooks/        # Jupyter notebooks
├── pyproject.toml    # Project configuration and dependencies
├── README.md         # This file
└── .gitignore       # Git ignore rules
EOF
        ;;
    ml)
        cat <<EOF >> README.md
├── src/              # Source code
│   ├── __init__.py
│   └── main.py
├── tests/            # Test files
│   └── __init__.py
├── data/             # Data files (gitignored)
├── notebooks/        # Jupyter notebooks
├── models/           # Saved models (gitignored)
├── experiments/      # Experiment tracking
├── pyproject.toml    # Project configuration and dependencies
├── README.md         # This file
└── .gitignore       # Git ignore rules
EOF
        ;;
    web)
        cat <<EOF >> README.md
├── src/              # Source code
│   ├── __init__.py
│   └── main.py       # FastAPI application
├── api/              # API endpoints
├── tests/            # Test files
├── static/           # Static files
├── templates/        # HTML templates
├── pyproject.toml    # Project configuration and dependencies
├── README.md         # This file
└── .gitignore       # Git ignore rules
EOF
        ;;
    data)
        cat <<EOF >> README.md
├── src/              # Source code
│   ├── __init__.py
│   └── main.py
├── tests/            # Test files
├── data/             # Data files (gitignored)
├── notebooks/        # Jupyter notebooks
├── reports/          # Generated reports
├── visualizations/   # Generated plots
├── pyproject.toml    # Project configuration and dependencies
├── README.md         # This file
└── .gitignore       # Git ignore rules
EOF
        ;;
    library)
        cat <<EOF >> README.md
├── src/
│   └── $PROJECT_NAME/     # Library code
│       ├── __init__.py
│       └── $PROJECT_NAME.py
├── tests/                 # Test files
├── docs/                  # Documentation
├── examples/              # Example usage
├── pyproject.toml        # Project configuration and dependencies
├── README.md             # This file
└── .gitignore           # Git ignore rules
EOF
        ;;
    research)
        cat <<EOF >> README.md
├── src/              # Source code
│   ├── __init__.py
│   └── main.py
├── tests/            # Test files
├── data/             # Data files (gitignored)
├── notebooks/        # Jupyter notebooks
├── papers/           # Research papers
├── figures/          # Generated figures
├── results/          # Experiment results
├── pyproject.toml    # Project configuration and dependencies
├── README.md         # This file
└── .gitignore       # Git ignore rules
EOF
        ;;
esac

cat <<EOF >> README.md
\`\`\`

### 4. Running the Project

EOF

# Add project-specific running instructions
case $PROJECT_TYPE in
    web)
        cat <<EOF >> README.md
To run the web application:
\`\`\`bash
# Development server
python src/main.py

# Or with uvicorn directly
uvicorn src.main:app --reload
\`\`\`

The API will be available at http://localhost:8000
API documentation: http://localhost:8000/docs
EOF
        ;;
    library)
        cat <<EOF >> README.md
To use the library:
\`\`\`python
from $PROJECT_NAME import hello

result = hello()
print(result)
\`\`\`

The library is automatically installed in development mode by Poetry.

To build the library:
\`\`\`bash
poetry build
\`\`\`

To publish to PyPI:
\`\`\`bash
poetry publish
\`\`\`
EOF
        ;;
    *)
        cat <<EOF >> README.md
\`\`\`bash
python src/main.py
\`\`\`
EOF
        ;;
esac

cat <<EOF >> README.md

### 5. Development

To run tests:
\`\`\`bash
pytest tests/
\`\`\`

To format code:
\`\`\`bash
black src/ tests/
\`\`\`

To check code style:
\`\`\`bash
flake8 src/ tests/
\`\`\`

To check types:
\`\`\`bash
mypy src/
\`\`\`

### 6. Managing Dependencies with Poetry

\`\`\`bash
# Show all installed packages
poetry show

# Show dependency tree
poetry show --tree

# Update dependencies
poetry update

# Export dependencies to requirements.txt (if needed)
poetry export -f requirements.txt -o requirements.txt

# Build the project
poetry build

# Publish to PyPI (for library projects)
poetry publish
\`\`\`

### 7. Poetry Virtual Environment

\`\`\`bash
# Show info about the virtual environment
poetry env info

# List all virtual environments
poetry env list

# Remove the virtual environment
poetry env remove python$PYTHON_VERSION
\`\`\`
EOF

# Create a sample test file
case $PROJECT_TYPE in
    library)
        cat <<EOF > tests/test_$PROJECT_NAME.py
"""Tests for $PROJECT_NAME module"""
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from $PROJECT_NAME import hello


def test_hello():
    """Test hello function"""
    assert hello() == "Hello from $PROJECT_NAME!"
EOF
        ;;
    web)
        cat <<EOF > tests/test_main.py
"""Tests for FastAPI application"""
from fastapi.testclient import TestClient
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from main import app

client = TestClient(app)


def test_root():
    """Test root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to $PROJECT_NAME API"}


def test_health():
    """Test health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}
EOF
        ;;
    *)
        cat <<EOF > tests/test_main.py
"""Tests for main module"""
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from main import main


def test_main(capsys):
    """Test main function"""
    main()
    captured = capsys.readouterr()
    assert "Hello from $PROJECT_NAME!" in captured.out
EOF
        ;;
esac

# Initialize git repository if not skipped
if [ "$SKIP_GIT" = false ]; then
    git init
    git add .
    git commit -m "Initial commit: $PROJECT_NAME Python project (type: $PROJECT_TYPE)"
fi

echo ""
echo "Python project '$PROJECT_NAME' created successfully at $python_dir/$PROJECT_NAME"
echo "Project type: $PROJECT_TYPE"
echo ""
echo "To start working on your project:"
if [ "$IS_WINDOWS" = true ]; then
    # Convert back to Windows path for display
    win_path=$(cygpath -w "$python_dir/$PROJECT_NAME" 2>/dev/null || echo "$python_dir/$PROJECT_NAME")
    echo "  cd $win_path"
else
    echo "  cd $python_dir/$PROJECT_NAME"
fi
echo "  poetry shell  # Activate the virtual environment"
echo "  # OR"
echo "  poetry install  # Install dependencies without activating shell"

# Add project-type specific instructions
case $PROJECT_TYPE in
    web)
        echo ""
        echo "To run the web application:"
        echo "  python src/main.py"
        ;;
    ml)
        echo ""
        echo "To start Jupyter Lab:"
        echo "  jupyter lab"
        ;;
    library)
        echo ""
        echo "To build the library:"
        echo "  poetry build"
        echo "To publish to PyPI:"
        echo "  poetry publish"
        ;;
esac