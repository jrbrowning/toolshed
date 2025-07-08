# toolshed

An opinionated developer productivity toolkit for macOS, focused on development environment setup, reproducibility, and automation.

This repo contains scripts and configuration files to bootstrap your environments, making it easy to set up a new laptop or keep your dev tools in sync.

# Motivation

I got a new laptop and wanted to start with a fresh env install. Then I realized, I really still want _a few things_ from my old setup.

Also, relying on the default versions of Python and Node on your machine can lead to a lot of dependency down the road. What happens when you (inevitably) need to update something and next thing your local tool starts giving "not found" errors? Ugh.

My solution was to create a toolshed and whenever I get a new laptop (or create a new iTerm session), I can source whichever ENV script I need (new laptop, Python or Node) and I'll always have a consistent starting point. Tool versions are defined as ENVs and config files for future upgrades, but the script always remains the same.

# Features

**Brewfile**: Portable Homebrew Configuration

This file defines my macOS toolchain setup:

- 🔧 System tools (htop, jq, tree) for system inspection
- 💻 Language environments (nvm, pyenv, rust, go) for dev stack
- 🔄 Shell enhancements (fzf, ripgrep, bat, zsh-autosuggestions, oh-my-zsh) for speed and developer ergonomics
- 🧪 Local databases (Postgres, Redis, SQLite) for backend development
- ☁️ DevOps & Cloud (kubectl, terraform, supabase) for cloud integration
- 🪟 UI utilities (iterm2, rectangle) for a UI setup
- 📂 Cloud storage (Dropbox, GCP SDK) for syncing
- 🤖 AI tools (ChatGPT, Claude) for local desktop integration
- 📌 Using this file ensures full parity across machines with a single commands:

## 🚀 Usage Summary

This toolkit supports two primary workflows:

[🆕 New Laptop Setup](#new-laptop-setup)

- One-command bootstrap for Homebrew, CLI tools, and Zsh plugins
- Restore or sync packages using a generated Brewfile

[🛠️ Daily Environment Consistency](#daily-use-setup)

- Setup Python with pyenv and install global tools
- Setup Node.js via nvm and install global npm packages
- Free up space from Docker usage (esp. for local AI dev)

## New laptop Setup

Got a new Laptop? As your machine won't have any base tools (homebrew, git, etc), this is where I begin. This script ensures a **repeatable, fast, and minimal-hassle** setup for macOS machines:

- **Consistency** – Using a Brewfile and plugin list guarantees you get the same dev environment every time.
- **Speed** – No need to remember dozens of CLI tools, databases, or apps — it's all here.
- **Zsh-first Shell Setup** – Syntax highlighting and autosuggestions are configured out of the box for productivity.
- **NVM + Node** – Maintain Node versions consistently across machines and teams.
- **Idempotent** – Homebrew’s bundle install won’t reinstall anything unnecessarily.
- **Extendable** – Add or remove tools in one place. Easy to version control.

### Homebrew & Zsch

0. Clone this repository on your existing machine.

```bash
git clone git@github.com:jrbrowning/toolshed.git
cd new-laptop-setup
```

1. Copy the `new-laptop-setup` folder to any folder to your `iCloud Drive`. This will be accessible on your new machine

```bash
cp -R new-laptop-setup ~/Library/Mobile\ Documents/com~apple~CloudDocs/
```

2. Run the script.

```bash
cd new-laptop-setup
python3 setup.py             # Install Homebrew, packages in the Brewfile, and Zsh plugins
```

3. (optional): Added some new packages in your Brewfile and want to "sync" again?

```bash
python3 brew_sync.py         # Export or restore Homebrew packages
```

## Daily use Setup

Now that the machine is setup with the base tools, we can clone the repo anytime we need access to the toolshed.

### Clone the toolshed Repo

In another repo I want to have access to the toolshed (I add this to every repo I work with), add the toolshed as a folder (NOT a subrepo)

```bash
cd <whatever repo you want to add the toolshed too>
git clone git@github.com:jrbrowning/toolshed.git
```

Now add `toolshed` to your .gitignore file

```bash
echo -e "\n# toolshed - developer tool repo\ntoolshed/" >> .gitignore
```

You are ready to go! The following configurations are avaialble.

### Python

```bash
./setup_python_env.sh     # Installs Python, creates venv, installs global tools
```

### Node.js

```bash
./setup-node-env.sh       # Installs Node, NVM, and global npm tools
```

### Docker Cleanup

- Aggressively remove all Docker containers, images, volumes, networks, and caches. As the name implies, this is the "I want to start over... everything must go". USE WITH CAUTION!
- Script: [`docker/destroy-everything.sh`](docker/destroy-everything.sh)

---

## Directory Structure

```
toolshed/
├── setup_python_env.sh
├── setup-node-env.sh
└── .gitignore
├── global-tools/
│   ├── node-tools.json ## This is a JSON format for installing any global npm tools you.
│   └── requirements.txt ## This is where you add any python ENV specific tools you want.
├── new-laptop-setup/
│   ├── Brewfile
│   ├── brew_sync.py
│   └── setup.py
├── docker/
│   └── destroy-everything.sh. ## Read disclaimer first at the top of the script before using.   It does what the name implies.   It's for when you want to REALLY start over with your local docker.
```

---

## Disclaimer

This project is provided as is under the MIT License. While every effort has been made to ensure these scripts are safe and effective, the author assumes no responsibility for errors, omissions, or changes in tool behavior due to upstream updates or compromised internet sources. Use at your own discretion — but realistically, I used this to set up my machine and use it daily.
