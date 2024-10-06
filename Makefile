#!/bin/bash

# Makefile for orchestration using PDM

# Define the PDM executable
PDM := pdm

# Default values for template URL and new repository directory
DEFAULT_TEMPLATE_URL := "https://github.com/jetxeberria/galtzagorri.git"
DEFAULT_NEW_REPO_DIR := "$$HOME/repositories/"

# Default target
all: help

# Help target
help:
	@echo "Usage:"
	@echo "  make setup-system            - Install PDM and system-wide setup"
	@echo "  make setup-repo              - Set up the repository environment"
	@echo "  make create-env              - Create and activate the PDM environment"
	@echo "  make create-new-repository   - Run Copier to create a new repository"
	@echo "  make clean                   - Remove virtual environment and cache"
	@echo "  make update-pdm              - Update PDM to the latest version"


# Target to set up the system (run only once on the system)
setup-system: install-venv install-pdm install-git-lfs
	@echo "System setup complete."

install-venv:
	@echo "Installing virtual environment..."
	sudo apt install python3.12-venv

install-pdm:
	@echo "Installing PDM system-wide..."
	curl -sSLO https://pdm-project.org/install-pdm.py
	curl -sSL https://pdm-project.org/install-pdm.py.sha256 | shasum -a 256 -c -
	# Run the installer
	python3 install-pdm.py
	# Remove the installer
	rm install-pdm.py

install-git-lfs:
	@echo "Installing Git LFS..."
	sudo apt install git-lfs
	git lfs install

# Target to update PDM to the latest version (optional)
update-pdm:
	@echo "Updating PDM to the latest version..."
	$(PDM) self update

# Target to set up the repository environment (run each time repo is cloned)
setup-repo: init-project create-env
	@echo "Repository environment is set up."

init-project:
	@echo "Initializing the PDM project..."
	@if [ ! -f "pyproject.toml" ]; then \
		$(PDM) init --non-interactive ; \
	else \
		echo "pyproject.toml already exists. Skipping initialization."; \
	fi

create-env:
	@echo "Creating and activating the PDM environment..."
	$(PDM) install

# Target to update the local environment with new dependencies after pulling changes
update-env:
	@echo "Updating the local environment with new dependencies..."
	$(PDM) update

# Target to create a new repository (accepts template URL and new repo directory as arguments)
create-new-repository:
	echo "Creating a new repository..."
	@if [ -z "$(template_url)" ]; then \
		echo "No template URL provided. Using default: $(DEFAULT_TEMPLATE_URL)"; \
		template_url=$(DEFAULT_TEMPLATE_URL); \
	else \
		echo "Using template URL: $$template_url"; \
	fi;\
	if [ -z "$(new_repo_dir)" ]; then \
		echo "No new repository directory provided. Using default: $(DEFAULT_NEW_REPO_DIR)"; \
		new_repo_dir=$(DEFAULT_NEW_REPO_DIR); \
	else \
		echo "Using new repository directory: $$new_repo_dir"; \
	fi; \
	read -p "Enter the name of the new repository: " new_repo_name; \
	new_repo_dir=$$new_repo_dir/$$new_repo_name; \
	if [ -d "$$new_repo_dir" ]; then \
		echo "Error: The directory '$$new_repo_dir' already exists. Please choose a different name.\n"; \
		exit 1; \
	fi; \
	$(PDM) run copier copy --data project_name="$$new_repo_name" $$template_url $$new_repo_dir;\
	echo "New repository created and set up with PDM using Copier."

# Target to clean up the environment
clean:
	@echo "Cleaning up..."
	rm -rf __pypackages__
	rm -rf __pycache__
	rm -rf .pdm-python

# Default goal
.DEFAULT_GOAL := help
