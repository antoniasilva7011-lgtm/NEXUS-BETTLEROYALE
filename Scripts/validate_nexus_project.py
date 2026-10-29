"""Static checks for the NEXUS Unreal project files.

This script does not compile Unreal or generate an APK. Run with Python 3.
"""
import json
from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
errors = []

project_path = root / "NEXUSBattleRoyale.uproject"
if not project_path.is_file():
    errors.append("Missing NEXUSBattleRoyale.uproject")
else:
    try:
        project = json.loads(project_path.read_text(encoding="utf-8"))
        if project.get("EngineAssociation") != "5.6":
            errors.append("Expected EngineAssociation 5.6")
        if not any(m.get("Name") == "NEXUSBattleRoyale" for m in project.get("Modules", [])):
            errors.append("Runtime module NEXUSBattleRoyale is missing")
    except (json.JSONDecodeError, OSError) as exc:
        errors.append(f"Invalid project descriptor: {exc}")

required_files = [
    "Source/NEXUSBattleRoyale/NEXUSBattleRoyale.Build.cs",
    "Source/NEXUSBattleRoyale/Private/NEXUSBattleRoyale.cpp",
    "Source/NEXUSBattleRoyale/Public/NEXUSPreLobbyCharacter.h",
    "Source/NEXUSBattleRoyale/Private/NEXUSPreLobbyCharacter.cpp",
    "Source/NEXUSBattleRoyale/Public/NEXUSGameModeBase.h",
    "Source/NEXUSBattleRoyale/Private/NEXUSGameModeBase.cpp",
    "Config/DefaultEngine.ini",
    "Config/DefaultInput.ini",
    "Scripts/CreateNexusPreLobby.py",
    ".github/workflows/build-android.yml",
]
for rel in required_files:
    if not (root / rel).is_file():
        errors.append(f"Missing required file: {rel}")

cpp = root / "Source/NEXUSBattleRoyale/Private/NEXUSPreLobbyCharacter.cpp"
if cpp.is_file():
    source = cpp.read_text(encoding="utf-8")
    for symbol in ("MoveForward", "MoveRight", "TurnAtRate", "LookUpAtRate", "Jump"):
        if symbol not in source:
            errors.append(f"Character source does not reference expected input: {symbol}")

if errors:
    print("NEXUS static validation FAILED:")
    for error in errors:
        print(f" - {error}")
    sys.exit(1)

print(f"NEXUS static validation passed ({len(required_files)} required files checked).")
print("Note: this does not compile Unreal Engine or create an Android APK.")
