import os
from pathlib import Path
import plistlib
import subprocess

home = Path.home()
source = Path(__file__).resolve().parents[1] / "config/rex/git-tabs.lua"
target = home / ".config/rex/git-tabs.lua"
target.parent.mkdir(parents=True, exist_ok=True)
if target.is_symlink():
    target.unlink()
elif target.exists():
    raise SystemExit(f"Refusing to replace {target}")
target.symlink_to(source)

label = "com.bl.rex-git-tabs"
domain = f"gui/{os.getuid()}"
agent = home / f"Library/LaunchAgents/{label}.plist"
agent.parent.mkdir(parents=True, exist_ok=True)
logs = home / "Library/Logs"
logs.mkdir(parents=True, exist_ok=True)
config = {
    "Label": label,
    "ProgramArguments": [
        "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex",
        "--autostart=false", "do", str(target), "--all",
    ],
    "EnvironmentVariables": {"PATH": "/opt/homebrew/bin:/usr/bin:/bin"},
    "RunAtLoad": True,
    "KeepAlive": True,
    "ThrottleInterval": 30,
    "StandardOutPath": str(logs / "rex-git-tabs.log"),
    "StandardErrorPath": str(logs / "rex-git-tabs.log"),
}
subprocess.run(["launchctl", "bootout", f"{domain}/{label}"], capture_output=True)
with agent.open("wb") as output:
    plistlib.dump(config, output)
subprocess.run(["launchctl", "bootstrap", domain, str(agent)], check=True)
print(f"Installed {label}")
