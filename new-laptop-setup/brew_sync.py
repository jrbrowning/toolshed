import json
import subprocess
from pathlib import Path
from typing import List


class BrewSync:
    """
    Handles Homebrew package listing, JSON export, and Brewfile generation.
    Also syncs NVM (Node Version Manager) environment.

    Uncomment the example usage at the bottom to run the script.
    """

    def __init__(self, json_path: str = "brew_packages.json", brewfile_path: str = "Brewfile"):
        self.json_path = Path(json_path).resolve()
        self.brewfile_path = Path(brewfile_path).resolve()

    def _run_command(self, command: List[str]) -> List[str]:
        """Run a shell command and return the output as a list of lines."""
        try:
            result = subprocess.run(command, capture_output=True, text=True, check=True)
            return result.stdout.strip().split("\n")
        except subprocess.CalledProcessError as e:
            print(f"Error running command: {command} - {e}")
            return []

    def export_brew_packages(self):
        """Extracts installed Homebrew packages and saves them as JSON."""
        formulas = self._run_command(["brew", "list", "--formula"])
        casks = self._run_command(["brew", "list", "--cask"])
        taps = self._run_command(["brew", "tap"])

        brew_data = {"formulas": formulas, "casks": casks, "taps": taps}

        with open(self.json_path, "w") as f:
            json.dump(brew_data, f, indent=4)

        print(f"Exported Homebrew packages to {self.json_path}")

    def generate_brewfile(self):
        """Reads the JSON file and writes a Brewfile for easy restoration."""
        if not self.json_path.exists():
            print(f"Error: {self.json_path} not found. Run `export_brew_packages` first.")
            return

        with open(self.json_path, "r") as f:
            brew_data = json.load(f)

        brewfile_lines: List[str] = []

        for tap in brew_data.get("taps", []):
            brewfile_lines.append(f'tap "{tap}"')

        for formula in brew_data.get("formulas", []):
            brewfile_lines.append(f'brew "{formula}"')

        for cask in brew_data.get("casks", []):
            brewfile_lines.append(f'cask "{cask}"')

        with open(self.brewfile_path, "w") as f:
            f.write("\n".join(brewfile_lines) + "\n")

        print(f"Generated Brewfile at {self.brewfile_path}")

    def install_from_brewfile(self):
        """Installs packages from the Brewfile on a new machine.
        brew bundle is idempotent — rerunning it will not break anything. It only installs what’s missing.
        """
        if not self.brewfile_path.exists():
            print(f"Error: {self.brewfile_path} not found. Run `generate_brewfile` first.")
            return

        subprocess.run(["brew", "bundle", "--file", str(self.brewfile_path)])

        print("Installed packages from Brewfile.")

    def export_nvm_environment(self, nvm_json_path: str = "nvm_environment.json"):
        """Exports the current NVM version and global NPM packages."""
        nvm_version = self._run_command(["nvm", "current"])[0]
        global_npm_packages = self._run_command(["npm", "list", "-g", "--depth=0", "--json"])

        try:
            npm_data = json.loads("\n".join(global_npm_packages))
            packages = list(npm_data.get("dependencies", {}).keys())
        except json.JSONDecodeError:
            packages = []

        nvm_data: dict[str, object] = {"nvm_version": nvm_version, "global_npm_packages": packages}

        with open(nvm_json_path, "w") as f:
            json.dump(nvm_data, f, indent=4)

        print(f"Exported NVM environment to {nvm_json_path}")

    def import_nvm_environment(self, nvm_json_path: str = "nvm_environment.json"):
        """Restores the NVM version and global NPM packages on a new machine."""
        if not Path(nvm_json_path).exists():
            print(f"Error: {nvm_json_path} not found. Run `export_nvm_environment` first.")
            return

        with open(nvm_json_path, "r") as f:
            nvm_data = json.load(f)

        nvm_version = nvm_data.get("nvm_version")
        global_npm_packages = nvm_data.get("global_npm_packages", [])

        subprocess.run(["nvm", "install", nvm_version])
        subprocess.run(["nvm", "use", nvm_version])

        if global_npm_packages:
            subprocess.run(["npm", "install", "-g"] + global_npm_packages)

        print(f"Restored NVM environment with version {nvm_version} and global packages.")


# Example Usage
if __name__ == "__main__":
    brew_sync = BrewSync()

    # Step 1: Export Homebrew packages
    # brew_sync.export_brew_packages()

    # Step 2: Generate Brewfile
    # brew_sync.generate_brewfile()

    # Step 3: Install from Brewfile (on a new machine)
    brew_sync.install_from_brewfile()

    # Step 4: Export NVM environment
    # brew_sync.export_nvm_environment()

    # Step 5: Import NVM environment (on a new machine)
    # brew_sync.import_nvm_environment()
