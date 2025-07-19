#!/bin/bash

# Check if project name is provided as argument
if [ $# -eq 1 ]; then
    project_name="$1"
else
    # Prompt for the project name
    echo "Enter the Python project name:"
    read project_name
fi

# Create the directory path
python_dir="$HOME/Documents/Python_projects"
mkdir -p "$python_dir"

# Navigate to the Python projects directory
cd "$python_dir"

# Create project directory
mkdir -p "$project_name"
cd "$project_name"

# Create conda environment with the same name as the project
echo "Creating conda environment '$project_name'..."
conda create -n "$project_name" python=3.11 -y

# Create project structure
mkdir -p src tests data notebooks

# Create main.py
cat <<EOF > src/main.py
#!/usr/bin/env python3
"""
$project_name - Main module
"""

def main():
    """Main function"""
    print("Hello from $project_name!")


if __name__ == "__main__":
    main()
EOF

# Create __init__.py
touch src/__init__.py
touch tests/__init__.py

# Create requirements.txt
cat <<EOF > requirements.txt
# Core dependencies
numpy>=1.24.0
pandas>=2.0.0

# Development dependencies
pytest>=7.0.0
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0

# Add your project-specific dependencies below
EOF

# Create .gitignore
cat <<EOF > .gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

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

# PyInstaller
*.manifest
*.spec

# Unit test / coverage reports
htmlcov/
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Jupyter Notebook
.ipynb_checkpoints

# pyenv
.python-version

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# IDE
.idea/
.vscode/
*.swp
*.swo

# Data files
data/
*.csv
*.xlsx
*.json
*.db
*.sqlite

# Model files
*.pkl
*.h5
*.pt
*.pth
*.onnx

# Logs
*.log
logs/

# OS files
.DS_Store
Thumbs.db
EOF

# Create README.md with environment activation instructions
cat <<EOF > README.md
# $project_name

## Setup Instructions

### 1. Activate the Conda Environment

This project uses a conda environment named \`$project_name\`.

To activate the environment:
\`\`\`bash
conda activate $project_name
\`\`\`

To deactivate the environment:
\`\`\`bash
conda deactivate
\`\`\`

### 2. Install Dependencies

After activating the environment, install the required packages:
\`\`\`bash
pip install -r requirements.txt
\`\`\`

### 3. Project Structure

\`\`\`
$project_name/
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
\`\`\`

### 4. Running the Project

\`\`\`bash
python src/main.py
\`\`\`

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
conda env remove -n $project_name
\`\`\`
EOF

# Create a sample test file
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
    assert "Hello from $project_name!" in captured.out
EOF

# Initialize git repository
git init
git add .
git commit -m "Initial commit: $project_name Python project setup"

echo "Python project '$project_name' created successfully at $python_dir/$project_name"
echo ""
echo "To start working on your project:"
echo "  cd $python_dir/$project_name"
echo "  conda activate $project_name"
echo "  pip install -r requirements.txt"