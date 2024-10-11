#!/bin/bash

# Makefile for orchestration using PDM

include makefiles/environment.mk

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
	@echo "  make new-repository   - Run Copier to create a new repository"
	@echo "  make clean                   - Remove virtual environment and cache"
	@echo "  make update-pdm              - Update PDM to the latest version"





# Target to create a new repository (accepts template URL and new repo directory as arguments)
new-repository:
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
