import os
import subprocess
from pathlib import Path

# Define paths
HOME = Path.home()
DEV_SETUP_DIR = HOME / "../../con"
BREWFILE_PATH = Path("./Brewfile")  # Reads from the current directory
ITERM_THEMES_DIR = DEV_SETUP_DIR / "iterm2-themes"
ITERM_DRACULA_THEME = ITERM_THEMES_DIR / "iterm" / "Dracula.itermcolors"

# Ensure setup directory exists
DEV_SETUP_DIR.mkdir(parents=True, exist_ok=True)

def run_command(command, description=""):
    """Run a shell command and print status."""
    print(f"🔧 {description}...")
    result = subprocess.run(command, shell=True, text=True, capture_output=True)
    if result.returncode == 0:
        print(f"✅ {description} completed successfully.")
    else:
        print(f"❌ Error: {result.stderr}")


def install_homebrew():
    """Install Homebrew if not already installed."""
    if not Path("/opt/homebrew/bin/brew").exists():
        print("🍺 Installing Homebrew...")
        run_command(
            '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
            "Homebrew installation",
        )
        run_command('echo \'eval "$(/opt/homebrew/bin/brew shellenv)"\' >> ~/.zshrc')
        run_command('eval "$(/opt/homebrew/bin/brew shellenv)"')
    else:
        print("✅ Homebrew is already installed.")


def install_brewfile():
    """Install packages from Brewfile."""
    if BREWFILE_PATH.exists():
        print(f"📦 Installing packages from {BREWFILE_PATH}...")
        run_command(f"brew bundle --file={BREWFILE_PATH}", "Brewfile installation")
    else:
        print(f"❌ Brewfile not found at {BREWFILE_PATH}! Make sure it exists.")


def install_dracula_theme():
    """Install Dracula theme for iTerm2 only if not already installed."""
    if not ITERM_THEMES_DIR.exists():
        print("🎨 Installing Dracula theme for iTerm2...")
        ITERM_THEMES_DIR.mkdir(parents=True, exist_ok=True)
        run_command(
            f"git clone https://github.com/dracula/iterm.git {ITERM_THEMES_DIR}",
            "Downloading Dracula theme",
        )
    else:
        print("✅ Dracula theme is already installed.")

    print("\n📌 **To apply the Dracula theme in iTerm2, follow these steps:**")
    print("1️⃣ Open **iTerm2** → Preferences (`Cmd + ,`)")
    print("2️⃣ Go to **Profiles** → **Colors**")
    print(f"3️⃣ Click **Load Presets...** → **Import** and select:")
    print(f"   `{ITERM_DRACULA_THEME}`")
    print("4️⃣ Click **Load Presets...** again and choose **Dracula**.")
    print("✅ Your terminal is now dark & optimized! 🌙\n")


def install_zsh_plugins():
    """Install Zsh syntax highlighting and autosuggestions only if missing."""
    installed_plugins = subprocess.run("brew list", shell=True, text=True, capture_output=True)
    
    if "zsh-syntax-highlighting" not in installed_plugins.stdout:
        run_command("brew install zsh-syntax-highlighting", "Installing zsh-syntax-highlighting")
    else:
        print("✅ zsh-syntax-highlighting is already installed.")

    if "zsh-autosuggestions" not in installed_plugins.stdout:
        run_command("brew install zsh-autosuggestions", "Installing zsh-autosuggestions")
    else:
        print("✅ zsh-autosuggestions is already installed.")


if __name__ == "__main__":
    print("🚀 Starting macOS Developer Setup...")

    install_homebrew()
    install_brewfile()
    install_dracula_theme()
    install_zsh_plugins()

    print("🎉 Setup complete! Restart your terminal to apply changes.")
