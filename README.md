## Overview

TurnBasedCombatEngine is a personal software engineering project developed to explore modular game architecture, client-server communication, and extensible combat systems.

Rather than focusing only on gameplay, the project emphasizes clean software design, separation of responsibilities, and maintainable code.

## Features

- Modular combat architecture
- Turn queue management
- Combat session management
- Damage calculation system
- NPC state machine (Finite State Machine)
- Client-server communication
- Event-driven Combat Log
- Quick Time Events (QTE)
- Extensible action system

## Technologies

- Lua
- Roblox Studio
- Rojo
- Git

## Architecture

The project follows a modular architecture where each subsystem has a single responsibility.

Main modules include:

- CombatController
- TurnManager
- CombatSession
- DamageCalculator
- CombatLogger
- ActionExecutor
- NPCManager
- CombatStatsService

This organization reduces coupling between systems and simplifies future extensions.

## Project Structure

```
src/
├── ServerScriptService/
├── ReplicatedStorage/
└── StarterPlayer/
```

## Current Status

The combat engine is currently under active development.

Planned features include:

- Status effects
- Equipment system
- Enemy AI improvements
- Additional combat actions
- UI enhancements

## License

This repository is intended for educational and portfolio purposes.
