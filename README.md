# toolshed

An opinionated developer productivity toolkit for macOS, focused on development environment setup, reproducibility, and automation.

This repo contains scripts and configuration files to bootstrap Python, Node.js, Docker, and Homebrew environments, making it easy to set up a new laptop or keep your dev tools in sync.

# Motivation

Relying on the default versions of python and node can lead to a lot of dependency down the road. What happens when you (inevitably) need to update something and next thing your local tool starts giving "not found" errors? Uggghh.

My solution was to create a toolshed and whenever I create a new iterm session, source whichever ENV I need (python or node) and i'll always have a consistent starting point. Tool versions are defined as ENV's for future upgrades, but the script always remains the same.

## Features

Everyday Usage:

- **Automated Python Environment**

  - Script: [`setup_python_env.sh`](setup_python_env.sh)
  - Install Python via `pyenv` will create and activate a virtual environment.
  - Install global Python tools from [`global-tools/requirements.txt`](global-tools/requirements.txt)

- **Automated Node.js Environment**

  - Install Node.js via `nvm`
  - Install global npm tools from [`global-tools/node-tools.json`](global-tools/node-tools.json)
  - Script: [`setup-node-env.sh`](setup-node-env.sh)

- **New Laptop Bootstrap**

  - Install Homebrew, all packages, and Zsh plugins in one go
  - Script: [`new-laptop-setup/setup.py`](new-laptop-setup/setup.py)

- **Homebrew Sync & Restore**

  - Scripts: [`new-laptop-setup/brew_sync.py`](new-laptop-setup/brew_sync.py),
  - Export installed formulas, casks, and taps to JSON
  - Generate a `Brewfile` for easy restoration
  - Install all packages from a `Brewfile`

  - This will read and install any packages in [`new-laptop-setup/Brewfile`](new-laptop-setup/Brewfile),
  - A list of all the packages installed will be returned for documentation (.gitignored) [`new-laptop-setup/brew_packages.json`](new-laptop-setup/brew_packages.json)

- **Docker Cleanup**
  - Aggressively remove all Docker containers, images, volumes, networks, and caches. As the name implies, this is the "I want to start over... everything must go". USE WITH CAUTION!
  - Script: [`docker/destroy-everything.sh`](docker/destroy-everything.sh)

---

## Quick Start

### 0. Clone the toolshed Repo

In another repo, add the toolshed as a folder (NOT a subrepo)

```bash
git clone git@github.com:jrbrowning/toolshed.git
```

Now add `toolshed` to your .gitignore file

```bash
echo -e "\n# toolshed - developer tool repo\ntoolshed/" >> .gitignore
```

You are ready to go! The following configurations are avaialble.

### 1. Homebrew

```sh
cd new-laptop-setup
python3 brew_sync.py         # Export or restore Homebrew packages
python3 setup.py             # Install Homebrew, Brewfile, and Zsh plugins
```

### 2. Python

```sh
bash setup_python_env.sh     # Installs Python, creates venv, installs global tools
```

### 3. Node.js

```sh
bash setup-node-env.sh       # Installs Node, NVM, and global npm tools
```

### 4. Docker Cleanup

```sh
bash docker/destroy-everything.sh
```

---

## Directory Structure

```
toolshed/
├── docker/
│   └── destroy-everything.sh
├── global-tools/
│   ├── node-tools.json
│   └── requirements.txt
├── new-laptop-setup/
│   ├── Brewfile
│   ├── brew_packages.json
│   ├── brew_sync.py
│   └── setup.py
├── setup_python_env.sh
├── setup-node-env.sh
└── .gitignore
```

---

## Requirements

- macOS
- Homebrew
- Python 3.8+
- Node.js (via NVM)
- Docker (for cleanup script)

---

## License

MIT

---
