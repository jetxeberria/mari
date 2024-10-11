# Makefile file to host common environment targets

include makefiles/environment.mk

PDM := pdm

.PHONY: clean

# Set up the system (run only once on the system)
setup-system: _install-venv _nstall-pdm _install-git-lfs
	@echo "System setup complete."

_install-venv:
	@echo "Installing virtual environment..."
	sudo apt install python3.12-venv

_install-pdm:
	@echo "Installing PDM system-wide..."
	curl -sSLO https://pdm-project.org/install-pdm.py
	curl -sSL https://pdm-project.org/install-pdm.py.sha256 | shasum -a 256 -c -
	# Run the installer
	python3 install-pdm.py
	# Remove the installer
	rm install-pdm.py

_install-git-lfs:
	@echo "Installing Git LFS..."
	sudo apt install git-lfs
	git lfs install

# Update PDM to the latest version (optional)
update-pdm:
	@echo "Updating PDM to the latest version..."
	$(PDM) self update

# Initialize the repository (run only once on the repository)
init-repo: _init-git-repository setup-repo
	@echo "Repository is initialized."

_init-git-repository:
	@echo "Initizalizing the repository..."
	git init

# Set up the repository environment (run each time repo is cloned)
setup-repo: _create-env
	@echo "Repository environment is set up. Activate it with 'source .venv/bin/activate'."

_create-env: _check-no-env
	@echo "Creating and activating the PDM environment..."
	$(PDM) install

_check-no-env:
	@echo "Checking no environment is activated..."
	@if [ -n "$${VIRTUAL_ENV}" ]; then \
		echo "\nError: Environment is already activated!"; \
		echo "Please deactivate the current environment and try again.\n"; \
		exit 1; \
	fi
	@echo "OK"

# Update the repository environment with remote changes (run each time after pulling changes)
update-repo: _check-env-ok _update-template _update-env
	@echo "Repository environment is updated."

_check-env-ok:
	@echo "Checking if the correct environment is activated..."
	@PROJECT_NAME=$$(basename "$$(pwd)"); \
	ENV_NAME=$$(basename "$$(dirname "$${VIRTUAL_ENV}")"); \
	if [ "$$ENV_NAME" != "$$PROJECT_NAME" ]; then \
		echo "\nError: A different environment is activated ($$ENV_NAME) instead of expected ($$PROJECT_NAME)!"; \
		echo "Please deactivate the current environment, activate the correct environment and try again.\n"; \
		exit 1; \
	fi
	@echo "OK"

_update-template:
	@echo "Updating the Copier template..."

_update-env:
	@echo "Updating the local environment with new dependencies..."
	$(PDM) sync

# Targets to update the local environment
add-package: _check-env-ok
	@package_name=$${package_name}; \
	if [ -z "$$package_name" ]; then \
		if [ -z "$1"]; then \

		read -p "Enter package name to add: " package_name; \
		else \
			package_name=$1; \
			fi; \
	fi; \
	$(PDM) add $$package_name
	@echo "Package $$package_name added."

remove-package: _check-env-ok
	@read -p "Enter package name to remove: " package_name; \
	$(PDM) remove $$package_name
	@echo "Package $$package_name removed."

update-package: _check-env-ok
	@read -p "Enter package name to update: " package_name; \
	$(PDM) update $$package_name
	@echo "Package $$package_name updated."

# Target to clean up the environment
clean:
	@echo "Cleaning up..."
	rm -rf __pypackages__
	rm -rf __pycache__
	rm -rf .pdm-python