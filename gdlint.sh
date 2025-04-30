#!/bin/bash
# Simplified GDLint Tool for Godot projects

VENV_DIR=".gdlint-venv"

# Activate or create the virtual environment
activate_venv() {
    if [ ! -d "$VENV_DIR" ]; then
        echo "Setting up GDLint environment..."
        python3 -m venv "$VENV_DIR" || { echo "Failed to create virtualenv"; exit 1; }
    fi
    "$VENV_DIR/bin/pip" install --upgrade pip
    "$VENV_DIR/bin/pip" install "gdtoolkit==4.*" || {
        echo "Failed to install gdtoolkit. Please check your Python environment."
        exit 1
    }
    # Fixed source command to use . instead for better compatibility
    . "$VENV_DIR/bin/activate"
}

# Run linter on GDScript files
run_lint() {
    # Added check if .gdlint-ignore exists
    if [ -f .gdlint-ignore ]; then
        find . -name "*.gd" | grep -v -f .gdlint-ignore 2>/dev/null | xargs -r "$VENV_DIR/bin/gdlint"
    else
        find . -name "*.gd" | xargs -r "$VENV_DIR/bin/gdlint"
    fi
}

# Create Git pre-commit hook
create_hook() {
    if [ -d .git ]; then
        if [ -f .git/hooks/pre-commit ]; then
            echo "Warning: .git/hooks/pre-commit already exists. It will be overwritten."
        fi

        mkdir -p .git/hooks
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep "\.gd$")
[ -z "$STAGED_FILES" ] && exit 0

# Use full path to avoid activation issues
GDLINT="$(pwd)/.gdlint-venv/bin/gdlint"

if [ ! -x "$GDLINT" ]; then
    echo "GDLint not found. Run ./gdlint-tool.sh setup first"
    exit 1
fi

if [ -f .gdlint-ignore ]; then
    echo "$STAGED_FILES" | grep -v -f .gdlint-ignore | xargs -r "$GDLINT"
else
    echo "$STAGED_FILES" | xargs -r "$GDLINT"
fi

if [ $? -ne 0 ]; then
    echo "GDLint failed. Fix issues before committing."
    exit 1
fi
exit 0
EOF
        chmod +x .git/hooks/pre-commit
        echo "Git pre-commit hook installed"
    else
        echo "No Git repository found. Initialize Git first with 'git init'"
    fi
}

# Delete the virtual environment
delete_venv() {
    if [ -d "$VENV_DIR" ]; then
        echo "Deleting GDLint virtual environment..."
        rm -rf "$VENV_DIR"
        echo "Virtual environment removed."
    else
        echo "No virtual environment found at $VENV_DIR"
    fi
}

case "$1" in
    "setup")
        activate_venv
        echo "GDLint setup complete!"
        ;;
    "check")
        activate_venv
        run_lint
        ;;
    "hook")
        activate_venv
        create_hook
        ;;
    "cleanup")
        delete_venv
        ;;
    *)
        echo "GDLint Tool. Usage: ./gdlint-tool.sh [setup|check|hook|cleanup]"
        echo "  setup   - Install GDLint in a local environment"
        echo "  check   - Run GDLint on all GDScript files"
        echo "  hook    - Set up a Git pre-commit hook"
        echo "  cleanup - Delete the local GDLint virtual environment"
        ;;
esac