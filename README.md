# 🦔 Hedgehog's Farm

**A cozy farming simulation game developed with Godot Engine 4.5**

> Play the game in your browser here: **(https://greenteakettle.itch.io/hedgehogs-farm)**

<img width="821" height="456" alt="Снимок экрана 2026-01-24 194452" src="https://github.com/user-attachments/assets/cfcc505c-fcd0-4401-ad9e-a9351d2fd5b9" />
<img width="821" height="456" alt="Снимок экрана 2026-01-24 192216" src="https://github.com/user-attachments/assets/7c0da5ac-8444-42af-bcef-74a583446fd7" />
<img width="821" height="456" alt="Снимок экрана 2026-01-24 194752" src="https://github.com/user-attachments/assets/611fe815-b831-492e-81d4-c18fb9e0ba1c" />



## 📖 About the Project
This project was created as a portfolio piece to demonstrate game development skills using Godot 4 and GDScript. The goal was to build a complete game loop featuring farming mechanics, inventory management, and world exploration.
I developed all the game logic, UI systems, and level design personally.

## ✨ Key Features & Technical Implementation

* **Farming System:**
    * TileMap interaction.
    * Crop growth cycle logic (Seed -> Growing -> Harvest).
* **Inventory System:**
    * Custom resource-based inventory.
    * UI for selecting seeds and tools.
* **Save/Load System:**
    * Serialization of game state (player position, inventory, crop stages, world objects) using JSON.
    * Persistent world data (cleared fog, unlocked areas).
* **Game Mechanics:**
    * "Fog of War" mechanic: Unlocking new areas by paying resources.
    * One-shot triggers and dialog systems.
    * Finite State Machine (FSM) for player states.

## 🛠️ Tech Stack
* **Engine:** Godot 4.5 (Compatibility Mode for Web)
* **Language:** GDScript
* **Graphics:** 2D Pixel Art

## 📦 How to Run the Code
1.  Clone this repository.
2.  Import the `project.godot` file into Godot Engine 4.x.
3.  Press **F5** to run the project in the editor.


## 🎨 Credits & Assets

While the code and level design are my own, this game uses free assets from talented creators:

**Art / Graphics:**
Sprout Lands by Cup Nooble & Pixel Art Hedgehog by dustdfg

**Music / SFX:**
Sound effects from Freesound.org
* 
**Fonts:**
pixelFont by Cup Nooble & ByteBounce by HipFonts

---

## 📄 License & Rights
**Code:** The source code in this repository is for educational and portfolio purposes.
**Assets:** All graphical and audio assets belong to their respective authors and are used under their specific licenses (CC0/CC-BY). Please do not extract assets from this project for commercial use.
