#!/bin/bash

# Default values
PROJECT_TYPE="basic"
PYTHON_VERSION="3.11"
USE_CONDA=true
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
    
    --no-conda          Use venv instead of conda
    --no-git            Skip git initialization
    -h, --help          Show this help message

EXAMPLES:
    python_project myproject                    # Basic project with defaults
    python_project myml --type ml --python 3.10 # ML project with Python 3.10
    python_project mylib --type library --no-conda  # Library with venv

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
        --no-conda)
            USE_CONDA=false
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

# Show selected configuration
echo "Creating Python project with the following configuration:"
echo "  Project name: $PROJECT_NAME"
echo "  Project type: $PROJECT_TYPE"
echo "  Python version: $PYTHON_VERSION"
echo "  Environment: $([ "$USE_CONDA" = true ] && echo "conda" || echo "venv")"
echo "  Git initialization: $([ "$SKIP_GIT" = false ] && echo "Yes" || echo "No")"
echo ""

# Create the directory path
python_dir="$HOME/Documents/Python_projects"
mkdir -p "$python_dir"

# Navigate to the Python projects directory
cd "$python_dir"

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create environment based on choice
if [ "$USE_CONDA" = true ]; then
    echo "Creating conda environment '$PROJECT_NAME'..."
    conda create -n "$PROJECT_NAME" python=$PYTHON_VERSION -y
else
    echo "Creating virtual environment..."
    python$PYTHON_VERSION -m venv venv
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

# Create requirements.txt based on project type
case $PROJECT_TYPE in
    basic)
        cat <<EOF > requirements.txt
# Core dependencies
numpy>=1.24.0
pandas>=2.0.0

# Development dependencies
pytest>=7.0.0
pytest-cov>=4.0.0
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0
ipython>=8.0.0

# Add your project-specific dependencies below
EOF
        ;;
    ml)
        cat <<EOF > requirements.txt
# Core ML dependencies
numpy>=1.24.0
pandas>=2.0.0
scikit-learn>=1.3.0
matplotlib>=3.7.0
seaborn>=0.12.0
jupyter>=1.0.0
jupyterlab>=4.0.0

# Deep Learning (choose one or both)
tensorflow>=2.13.0
# torch>=2.0.0
# torchvision>=0.15.0

# ML utilities
mlflow>=2.0.0
optuna>=3.0.0
xgboost>=1.7.0
lightgbm>=4.0.0

# Development dependencies
pytest>=7.0.0
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0

# Add your project-specific dependencies below
EOF
        ;;
    web)
        cat <<EOF > requirements.txt
# Web framework
fastapi>=0.100.0
uvicorn[standard]>=0.23.0
pydantic>=2.0.0
python-multipart>=0.0.6

# Database
sqlalchemy>=2.0.0
alembic>=1.11.0
asyncpg>=0.28.0  # For PostgreSQL
# pymongo>=4.4.0  # For MongoDB

# API utilities
httpx>=0.24.0
python-jose[cryptography]>=3.3.0
passlib[bcrypt]>=1.7.4
python-dotenv>=1.0.0

# Development dependencies
pytest>=7.0.0
pytest-asyncio>=0.21.0
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0

# Add your project-specific dependencies below
EOF
        ;;
    data)
        cat <<EOF > requirements.txt
# Data analysis dependencies
numpy>=1.24.0
pandas>=2.0.0
matplotlib>=3.7.0
seaborn>=0.12.0
plotly>=5.15.0
scipy>=1.11.0
statsmodels>=0.14.0

# Data processing
openpyxl>=3.1.0
xlrd>=2.0.0
pyarrow>=12.0.0

# Jupyter
jupyter>=1.0.0
jupyterlab>=4.0.0
ipywidgets>=8.0.0

# Development dependencies
pytest>=7.0.0
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0

# Add your project-specific dependencies below
EOF
        ;;
    library)
        cat <<EOF > requirements.txt
# Core dependencies (minimal for a library)
# Add only what your library needs

# Development dependencies
pytest>=7.0.0
pytest-cov>=4.0.0
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0
sphinx>=7.0.0
sphinx-rtd-theme>=1.3.0

# Build tools
build>=0.10.0
twine>=4.0.0
setuptools>=68.0.0
wheel>=0.41.0

# Add your library dependencies below
EOF
        ;;
    research)
        cat <<EOF > requirements.txt
# Scientific computing
numpy>=1.24.0
scipy>=1.11.0
sympy>=1.12
matplotlib>=3.7.0
seaborn>=0.12.0

# Data handling
pandas>=2.0.0
h5py>=3.9.0
netCDF4>=1.6.0

# Jupyter
jupyter>=1.0.0
jupyterlab>=4.0.0
ipywidgets>=8.0.0
notebook>=7.0.0

# Plotting and visualization
plotly>=5.15.0
bokeh>=3.2.0

# Development dependencies
pytest>=7.0.0
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0

# Add your research-specific dependencies below
EOF
        ;;
esac

# Create appropriate additional files based on project type
if [ "$PROJECT_TYPE" = "library" ]; then
    # Create setup.py for library projects
    cat <<EOF > setup.py
from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="$PROJECT_NAME",
    version="0.1.0",
    author="Your Name",
    author_email="your.email@example.com",
    description="A short description of your project",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/$PROJECT_NAME",
    package_dir={"": "src"},
    packages=find_packages(where="src"),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
    python_requires=">=3.8",
    install_requires=[
        # Add your dependencies here
    ],
)
EOF

    # Create pyproject.toml
    cat <<EOF > pyproject.toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$PROJECT_NAME"
version = "0.1.0"
description = "A short description of your project"
readme = "README.md"
requires-python = ">=3.8"
license = {text = "MIT"}
authors = [
    {name = "Your Name", email = "your.email@example.com"},
]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "Topic :: Software Development :: Libraries :: Python Modules",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
]

[tool.setuptools.packages.find]
where = ["src"]

[tool.black]
line-length = 88
target-version = ['py38', 'py39', 'py310', 'py311']

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
EOF
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

if [ "$USE_CONDA" = true ]; then
    cat <<EOF >> README.md
This project uses a conda environment named \`$PROJECT_NAME\`.

To activate the environment:
\`\`\`bash
conda activate $PROJECT_NAME
\`\`\`

To deactivate the environment:
\`\`\`bash
conda deactivate
\`\`\`
EOF
else
    cat <<EOF >> README.md
This project uses a Python virtual environment.

To activate the environment:
\`\`\`bash
# On macOS/Linux:
source venv/bin/activate

# On Windows:
venv\\Scripts\\activate
\`\`\`

To deactivate the environment:
\`\`\`bash
deactivate
\`\`\`
EOF
fi

cat <<EOF >> README.md

### 2. Install Dependencies

After activating the environment, install the required packages:
\`\`\`bash
pip install -r requirements.txt
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
├── requirements.txt  # Project dependencies
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
├── requirements.txt  # Project dependencies
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
├── requirements.txt  # Project dependencies
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
├── requirements.txt  # Project dependencies
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
├── setup.py              # Package setup
├── pyproject.toml        # Build configuration
├── requirements.txt      # Dependencies
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
├── requirements.txt  # Project dependencies
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

To install the library in development mode:
\`\`\`bash
pip install -e .
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

### 6. Managing the Environment

EOF

if [ "$USE_CONDA" = true ]; then
    cat <<EOF >> README.md
To see all packages in the environment:
\`\`\`bash
conda list
\`\`\`

To export the environment:
\`\`\`bash
conda env export > environment.yml
\`\`\`

To remove the environment (when no longer needed):
\`\`\`bash
conda deactivate
conda env remove -n $PROJECT_NAME
\`\`\`
EOF
else
    cat <<EOF >> README.md
To see all packages in the environment:
\`\`\`bash
pip list
\`\`\`

To export the environment:
\`\`\`bash
pip freeze > requirements-lock.txt
\`\`\`

To remove the environment (when no longer needed):
\`\`\`bash
deactivate
rm -rf venv
\`\`\`
EOF
fi

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
echo "  cd $python_dir/$PROJECT_NAME"

if [ "$USE_CONDA" = true ]; then
    echo "  conda activate $PROJECT_NAME"
else
    echo "  source venv/bin/activate  # On macOS/Linux"
    echo "  # OR"
    echo "  venv\\Scripts\\activate   # On Windows"
fi

echo "  pip install -r requirements.txt"

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
        echo "To install in development mode:"
        echo "  pip install -e ."
        ;;
esac