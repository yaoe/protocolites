# プロトコライト // PROTOCOLITE ASCII ART PROTOCOL

## 📜 Philosophy

**PROTOCOLITE** is a generative ASCII art protocol that creates living digital creatures through a family-based DNA inheritance system. Inspired by minimalist pixel art aesthetics and Japanese design principles, PROTOCOLITE generates unique creatures (プロトコライト) that breed, mutate, and evolve across generations.

### Core Principles

1. **Inheritance Over Randomness**: Children inherit 80-100% of their parent's traits, creating visible family lineages
2. **Controlled Mutation**: 20% mutation rate allows for evolution while maintaining family identity
3. **Minimalist Aesthetics**: Clean, monospace ASCII art inspired by early pixel art and Japanese design
4. **Deterministic Generation**: Seed-based generation ensures reproducibility
5. **Visual DNA**: Every trait is visible in the creature's appearance
6. **Family Unity**: Color families maintain distinct identities across generations

---

## 🎨 The Creature Anatomy

Every PROTOCOLITE creature consists of the following elements:

### Essential Components (Always Present)

```
        ✦               ← Antenna (1-4 antennas)
        │
    ╔═══════╗          ← Hat (optional)
    ▓▓▓▓▓▓▓▓▓          ← Body (various shapes)
    ▓ ● ● ▓ ~          ← Eyes (ALWAYS BIG) + Cigarette (optional)
    ▓  ─  ▓            ← Mouth (optional)
    ▓▓▓▓▓▓▓▓▓
  ───▓▓▓▓▓───          ← Arms (1-4 pairs, ALWAYS present)
    ▓▓▓▓▓
     │ │               ← Legs (1-4 legs, ALWAYS present)
```

### Size Specifications

- **Spreaders (Parents)**: 24×24 character grid
- **Children (Offspring)**: 16×16 character grid

---

## 🧬 DNA System

### DNA Structure

Each creature carries a DNA signature that controls its appearance:

```
DNA = [BODY_TYPE] + [BODY_CHAR] + [EYE_CHAR] + [ARM_STYLE] + [LEG_STYLE] + [ANTENNA_TIP] + [HAT_TYPE] + [CIGARETTE]
```

### DNA Code Format

Example: `[sq-█-●-blo-blo-✦-top]`

- `sq` = Square body type
- `█` = Solid body fill character
- `●` = Round eyes
- `blo` = Block arm style
- `blo` = Block leg style
- `✦` = Star antenna tip
- `top` = Top hat

---

## 🎯 Attributes & Inheritance

### 1. Body Type (100% Inherited)

The fundamental shape of the creature. **NEVER mutates in children.**

**Spreader Options:**
- `square` — Blocky, geometric body
- `round` — Circular, organic body
- `invader` — Space Invader-style stepped body
- `mushroom` — Wide top, narrow stem
- `ghost` — Pac-Man ghost shape with wavy bottom
- `diamond` — Diamond/rhombus shape

**Children Options:**
- `square` — Blocky, geometric body
- `round` — Circular, organic body
- `diamond` — Diamond/rhombus shape
- `mushroom` — Simplified mushroom for small size

**Inheritance:** 100% — Child always inherits parent's exact body type

---

### 2. Body Fill Character (80% Inherited)

The ASCII character used to fill the body mass.

**Options:**
- `█` — Solid block (full density)
- `▓` — Dark shade (high density)
- `▒` — Medium shade (medium density)
- `░` — Light shade (low density)

**Inheritance:** 80% inherit, 20% mutate to another fill character

**Visual Impact:** Creates texture and visual weight differences between family members

---

### 3. Eye Character (80% Inherited)

The character representing the eyes. **Eyes are ALWAYS present and prominent.**

**Options:**
- `●` — Solid circle (intense stare)
- `◉` — Circle with dot (focused look)
- `◎` — Double circle (wide-eyed)
- `○` — Hollow circle (blank stare)

**Inheritance:** 80% inherit, 20% mutate

**Important:** All creatures have BIG, visible eyes — this is a core aesthetic principle

---

### 4. Eye Size (80% Inherited)

**NEW in Version V** — Determines the scale of the eye structures.

**Options:**
- `normal` — Standard eye size (70% probability)
- `mega` — Extra large eyes (30% probability)

**Inheritance:** 80% inherit parent's eye size, 20% mutate

**Visual Impact:** MEGA eyes create more expressive, character-rich creatures

---

### 5. Arm Style (100% Inherited)

Visual style of the arm appendages.

**Options:**
- `block` — Solid block arms: `█`
- `line` — Line arms: `─`

**Inheritance:** 100% — Never mutates

**Count:** Spreaders have 1-4 pairs of arms, children have 1-4 pairs (randomized but always present)

---

### 6. Leg Style (100% Inherited)

Visual style of the leg appendages.

**Options:**
- `block` — Solid block legs: `█`
- `line` — Line legs: `│`

**Inheritance:** 100% — Never mutates

**Count:** 1-4 legs (randomized but always present and connected to body)

---

### 7. Antenna Tip (80% Inherited)

The character at the tip of antenna appendages.

**Options:**
- `●` — Solid dot
- `◉` — Circle with dot
- `○` — Hollow circle
- `◎` — Double circle
- `✦` — Four-point star
- `✧` — Hollow star
- `★` — Solid star

**Inheritance:** 80% inherit, 20% mutate

**Count:** 1-4 antennas (always present, extending from body top)

---

### 8. Hat (80% Inherited if Parent Has Hat)

**NEW in Version V** — Decorative headwear.

**Options:**
- `none` — No hat (most common for spreaders)
- `top` — Top hat: `▀▀▀` with stem
- `flat` — Flat cap: `═══`
- `double` — Double layer: `▀▀▀` over `▄▄▄`
- `fancy` — Fancy hat: `╔═══╗`

**Inheritance Logic:**
- If parent has hat: 80% child inherits same hat, 20% gets different hat or none
- If parent has no hat: 15% chance child gets random hat

**Visual Impact:** Adds personality and distinguishes family lines

---

### 9. Cigarette (Random - Not Inherited)

**NEW in Version V** — Rare accessory.

**Options:**
- `none` — No cigarette (90%)
- `yes` — Cigarette with smoke: `~∙` or `≈∙` or `∼∙` (10%)

**Inheritance:** NOT inherited — Each creature has independent 10% chance

**Position:** Near mouth area, extends to side

---

### 10. Mouth (Optional)

Simple line mouth, randomly generated.

**Options:**
- `─` — Single line
- `──` — Double line
- `───` — Triple line
- None (30% chance)

**Inheritance:** Not inherited, randomly generated each time

---

## 🌈 Color Families

PROTOCOLITE creatures belong to one of six color families. **Color is 100% inherited** — all children match their parent's family color.

### The Six Families

| Family | Japanese | Hex Color | Meaning |
|--------|----------|-----------|---------|
| **RED** | 赤 (Aka) | `#cc0000` | Passion, energy, fire |
| **GREEN** | 緑 (Midori) | `#008800` | Nature, growth, harmony |
| **BLUE** | 青 (Ao) | `#0044cc` | Sky, water, tranquility |
| **YELLOW** | 黄 (Ki) | `#cc9900` | Light, gold, warmth |
| **PURPLE** | 紫 (Murasaki) | `#8800cc` | Royalty, mystery, spirit |
| **CYAN** | 水 (Mizu) | `#0088aa` | Ice, clarity, technology |

### Color Inheritance

```
RED Spreader → RED Children (always)
  ↓
  No cross-family breeding
  ↓
Family lineage remains pure
```

---

## 👨‍👩‍👧‍👦 Generational Flow

### Spreader → Children Relationship

```
┌─────────────────────┐
│   SPREADER          │
│   [Parent DNA]      │
│   24×24 grid        │
│   Color: RED        │
└──────────┬──────────┘
           │
           │ Breeds (Click)
           │
           ▼
    ┌──────┴──────┬──────────┐
    │             │          │
┌───▼────┐   ┌───▼────┐  ┌──▼─────┐
│ CHILD1 │   │ CHILD2 │  │ CHILD3 │
│  16×16 │   │  16×16 │  │  16×16 │
│RED +DNA│   │RED +DNA│  │RED +DNA│
└────────┘   └────────┘  └────────┘
  80-100%      80-100%     80-100%
  Inherited    Inherited   Inherited
  20% Mutated  20% Mutated 20% Mutated
```

### Breeding Mechanics

1. **Click a Spreader** → Generates 3 children
2. Each child receives:
   - **100% inheritance**: Body type, arm style, leg style, family color
   - **80% inheritance**: Body char, eye char, eye size, antenna tip, hat (if parent has one)
   - **Random**: Cigarette (10% chance), mouth style
3. Children are 16×16 (smaller than parent's 24×24)
4. Children display parent ID for traceability

---

## 📊 Visual DNA Indicators

### In the Interface

**Spreader Cards:**
- Display full DNA trait badges (neutral white background)
- Show: Body, Fill, Eyes, Arms, Legs, Hat, Cigarette
- Hover over spreader → children get yellow border highlight

**Child Cards:**
- Display DNA trait badges with inheritance indicators:
  - 🟢 **Green background** = Trait inherited from parent
  - 🔴 **Red background** = Trait mutated from parent
- Show parent ID link: `↑ [parent-id]`
- Hover over child → parent gets black border + yellow highlight

### Zoom Modal View

Click any creature to see:
- Enlarged ASCII art (20px font)
- Complete DNA breakdown
- Inheritance status for each trait (children only)
- Full creature ID and seed information

---

## 🔬 Technical Specifications

### Seed-Based Generation

```javascript
seed = (timestamp + counter) × 99991 + random × 10000000 + counter × 314159
```

Each creature has a unique seed ensuring:
- Reproducibility: Same seed = same creature
- Uniqueness: Different seeds = different creatures
- Trackability: Seeds stored for data export

### Grid System

**Spreader (24×24):**
```
Body: 6 units wide, 8 units tall
Eyes: 3×3 character blocks
Antennas: 1-2 characters tall
Arms: 2-6 characters extending
Legs: 2-3 characters extending
```

**Children (16×16):**
```
Body: 3 units wide, 4 units tall
Eyes: 2×2 character blocks
Antennas: 1 character tall
Arms: 1-3 characters extending
Legs: 1-2 characters extending
```

---

## 💾 Data Export Format

```json
{
  "protocol": "ASCII_PROTOCOLITE_V",
  "version": "5.0",
  "timestamp": "2025-10-08T...",
  "families": {
    "red": {
      "spreaders": [
        {
          "id": "abc123",
          "seed": 123456789,
          "ascii": "...",
          "dna": {
            "bodyType": "square",
            "bodyChar": "█",
            "eyeChar": "●",
            "eyeSize": "mega",
            "armStyle": "block",
            "legStyle": "line",
            "antennaTip": "✦",
            "hatType": "top",
            "hasCigarette": false
          },
          "traits": { ... }
        }
      ],
      "children": [
        {
          "id": "def456",
          "parentId": "abc123",
          "seed": 987654321,
          "ascii": "...",
          "dna": { ... },
          "traits": { ... }
        }
      ]
    }
  }
}
```

---

## 🎮 Usage Guide

### Creating a Family Line

1. **Select a Family Color** (RED, GREEN, BLUE, YELLOW, PURPLE, CYAN)
2. **Generate Spreader** — Creates a unique parent creature
3. **Breed** — Click spreader to create 3 children
4. **Observe Inheritance** — Compare parent DNA to children DNA
5. **Zoom Details** — Click creatures to see enlarged view
6. **Export Data** — Save your family lineage as JSON

### Reading DNA

**Example Spreader:**
```
ID: a3x9k2
DNA: [square-█-●-block-line-✦-top]

Body: square      [100% will pass to children]
Fill: █           [80% will pass to children]
Eyes: ●           [80% will pass to children]
Arms: block       [100% will pass to children]
Legs: line        [100% will pass to children]
Antenna: ✦        [80% will pass to children]
Hat: top          [80% will pass to children]
```

**Child from Above:**
```
ID: b7m4p1
Parent: ↑ a3x9k2
DNA: [square-█-◉-block-line-✦-top]

Body: square  ✓   [INHERITED - Green]
Fill: █       ✓   [INHERITED - Green]
Eyes: ◉       ✗   [MUTATED - Red]    ← Changed from ●
Arms: block   ✓   [INHERITED - Green]
Legs: line    ✓   [INHERITED - Green]
Antenna: ✦    ✓   [INHERITED - Green]
Hat: top      ✓   [INHERITED - Green]
```

---

## 🌟 Aesthetic Guidelines

### Design Philosophy

PROTOCOLITE creatures follow these aesthetic principles:

1. **Always Cute, Never Scary** — Big eyes, simple forms, friendly appearance
2. **Minimalist Clarity** — Clean shapes, readable at small sizes
3. **Japanese Influence** — Pixel art aesthetics, monospace harmony
4. **Consistent Structure** — Eyes always present, limbs always connected
5. **Personality Through Variation** — Small mutations create character

### Visual Hierarchy

```
EYES (Most Important)
  ↓
Body Shape & Fill
  ↓
Limbs & Antennas
  ↓
Accessories (Hat, Cigarette)
  ↓
Mouth (Least Important)
```

---

## 📈 Evolution Patterns

### Observing Family Lines

Over generations, families develop:
- **Stable traits**: Body types remain consistent
- **Drift traits**: Eye characters slowly shift
- **Rare traits**: Hats and cigarettes come and go
- **Visual identity**: Each family maintains recognizable appearance

### Mutation Hotspots

Most likely to mutate:
1. Eye character (20% per generation)
2. Body fill character (20% per generation)
3. Antenna tip (20% per generation)
4. Hat type if parent has hat (20% per generation)

Never mutates:
1. Body type (locked)
2. Arm style (locked)
3. Leg style (locked)
4. Family color (locked)

---

## 🎯 Future Considerations

Potential extensions to the protocol:

- **Multi-generational breeding**: Children become spreaders
- **Cross-family hybrids**: Mixing color families
- **Trait dominance**: Recessive/dominant gene modeling
- **Environmental factors**: Mutations based on context
- **Animation**: Breathing, blinking, movement
- **Sound**: Each creature generates a tone based on DNA
- **3D rendering**: Convert ASCII to voxel models

---

## 📝 Credits

**PROTOCOLITE ASCII ART PROTOCOL**
- Concept: Generative ASCII creature breeding
- Aesthetic: Minimalist pixel art / Japanese design
- Technology: Seed-based deterministic generation
- Philosophy: Inheritance over randomness

---

## ⚖️ License

Protocol specification: Open
Generated creatures: Unique to each instance
Code implementation: As per repository license

---

**プロトコライト // PROTOCOLITE V**

*Creating digital life, one ASCII character at a time.*

---
