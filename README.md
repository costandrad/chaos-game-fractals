# Chaos Game — Fractal Animation (Luxor.jl)

## Overview

This project generates **high‑resolution vertical animations (1080×1920)** of the **Chaos Game** applied to regular polygons, optimized for platforms such as **TikTok, Instagram Reels, and YouTube Shorts**.

Using simple geometric rules and randomness, the Chaos Game reveals striking **fractal attractors**, including the famous **Sierpinski Triangle** (for `n = 3`) and related polygonal fractals for higher *n*.

The animation is rendered **frame‑by‑frame with Luxor.jl**, exported automatically as a **GIF**, and can optionally be converted to a **lossless MP4** using `ffmpeg`.

---

## Key Features

* 🎥 Vertical animation (1080×1920)
* 🧮 Chaos Game for arbitrary regular polygons
* 🎨 HSV color mapping based on polar angle (high contrast on black)
* 🌀 Accumulation of up to **100,000 iterations**
* 🖼️ Automatic **GIF** generation
* 🎞️ Optional **lossless MP4** export via `ffmpeg`
* 📁 Clean, structured output directory per animation

---

## The Chaos Game (Concept)

At each iteration:

1. Start with a regular polygon and an initial point **P**.
2. Choose a polygon vertex **V** at random.
3. Move **P** a fixed fraction ( r ) toward **V**.
4. Repeat the process many times.

Although the rule is simple, the orbit converges to a **fractal attractor**, whose structure depends on the number of polygon sides and the contraction ratio ( r ).

---

## Project Structure

The Julia script `chaos_game_v2.jl` is organized into the following sections:

1. **Header & metadata** — author, repository, description
2. **Imports** — `Luxor`, `Colors`, `Random`, `Printf`
3. **Filesystem utilities** — safe recreation of output directories
4. **Color & geometry utilities** — HSV coloring and optimal contraction ratio
5. **Global animation parameters** — resolution, FPS
6. **Polygon configuration** — number of sides, radius, labels
7. **Chaos Game data generation** — orbit precomputation
8. **Output structure** — `/output/<animation_name>/frames`
9. **Luxor Movie object**
10. **Scene 1** — background and static elements
11. **Scene 2** — Chaos Game evolution
12. **Rendering & export** — GIF, PNG snapshot, optional MP4

---

## Main Utility Functions

### `create_directory(path)`

Recreates a directory safely.

* Removes the directory if it already exists
* Creates a fresh, empty directory

Used to ensure reproducible animation outputs.

---

### `polar_hsv_color(p::Point)`

Generates a bright HSV color based on the **polar angle** of a point.

* Hue is mapped to the angle ( \theta = \arctan(y/x) )
* Produces vivid colors with excellent contrast on black backgrounds

Returns an `HSV` color.

---

### `optimal_contraction_ratio(n::Int)`

Computes an empirically optimal contraction ratio ( r ) for regular *n*-gons.

Different formulas are used depending on `n mod 4`, ensuring well‑formed fractal attractors.

Returns:

* `r ∈ (0, 1)` — fraction of the distance moved toward the chosen vertex

---

## Animation Parameters

### Global Settings

* **Resolution**: `1080 × 1920`
* **Frame rate**: `25 fps`
* **Iterations**: `100_000`
* **Points per frame**: `500`

An introductory sequence explains the Chaos Game rules before the full fractal emerges.

---

## Polygon Configuration

Supported polygons are defined via a dictionary:

* 3  → Triangle (Sierpinski Triangle)
* 4  → Square
* 5  → Pentagon
* 6  → Hexagon
* …
* 12 → Dodecagon
* 20 → Icosagon

To change the polygon, simply edit:

```julia
num_sides = 3
```

The contraction ratio and labels are computed automatically.

---

## Output Structure

For each run, the following directory tree is created:

```text
output/
└── <animation_name>/
    ├── frames/          # individual PNG frames
    ├── <name>.gif       # animated GIF
    ├── <name>.png       # final frame snapshot
    └── <name>.mp4       # optional lossless video
```

The animation name encodes:

* polygon type
* contraction ratio
* total frames
* frame rate

---

## Animation Scenes

### Scene 1 — Background & Geometry

* Black background
* Title: **Chaos Game**
* Polygon outline
* Polygon name and contraction ratio

---

### Scene 2 — Chaos Game Evolution

The animation proceeds through five explanatory stages:

1. Initial point and polygon
2. Random vertex selection
3. Movement toward the vertex
4. Iterative accumulation of points
5. Emergence of the fractal attractor

As the animation progresses, thousands of colored points reveal the fractal structure.

---

## Rendering & Export

The animation is rendered using Luxor’s `animate` function:

* All frames are generated as PNG files
* A **GIF** is created automatically
* The final frame is saved separately as a PNG

### Optional MP4 Export

If `ffmpeg` is installed, a **lossless MP4** is generated:

```bash
ffmpeg -r <fps> -i "%10d.png" -c:v h264 -crf 0 output.mp4
```

* `-crf 0` ensures maximum quality
* Ideal for archival or social‑media uploads

---

## Requirements

* Julia ≥ 1.9
* `Luxor.jl`
* `Colors.jl`
* `ffmpeg` (optional, for MP4 export)

---

## Author

**Igo da Costa Andrade**

GitHub: [https://github.com/costandrad](https://github.com/costandrad)

TikTok: [https://www.tiktok.com/@igoandrade](https://www.tiktok.com/@igoandrade)
---

## License

MIT License

