# lex-cognitive-origami

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Paper folding metaphor for conceptual compression and transformation. Figures start at full size and are folded along axes; each fold compresses the figure and adds a crease. Folds have types (valley, mountain, reverse, squash, petal) that affect the transformation differently. A maximum of 12 folds per figure enforces meaningful compression limits. Beauty score reflects the cumulative artistry of the fold sequence.

## Gem Info

- **Gem name**: `lex-cognitive-origami`
- **Module**: `Legion::Extensions::CognitiveOrigami`
- **Version**: `0.1.0`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_origami/
  version.rb
  client.rb
  helpers/
    constants.rb
    crease.rb
    figure.rb
  runners/
    cognitive_origami.rb
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `FOLD_TYPES` | `%i[valley mountain reverse squash petal]` | Valid fold type values |
| `MAX_FOLDS` | `12` | Maximum folds per figure |
| `MAX_FIGURES` | `100` | Per-engine figure capacity |
| `COMPLEXITY_LABELS` | range hash (0–12 range) | From `:flat` to `:masterwork` |
| `CREASE_DECAY` | `0.01` | Per-cycle sharpness reduction for creases |

## Helpers

### `Helpers::Crease`
Individual fold record. Has `id`, `fold_type`, `axis`, `depth`, and `sharpness` (0.0–1.0).

- `soften!(rate)` — reduces sharpness by `CREASE_DECAY`
- `sharp?` — sharpness above a threshold
- `faded?` — sharpness below a minimum threshold

### `Helpers::Figure`
A conceptual entity being folded. Has `id`, `name`, `content`, `folds` (array of `Crease`), `base_size`, and `beauty_score`.

- `fold!(fold_type:, axis:, depth:, sharpness:)` — enforces `MAX_FOLDS`; creates `Crease`, reduces compressed_size, increments beauty_score
- `unfold!` — removes the last fold (restores some size, reduces beauty)
- `fully_unfolded?` — no folds remain
- `complexity` — fold count (0–12)
- `compressed_size` — `BASE_SIZE - fold_count * 0.07` (each fold compresses by 7%)
- `compression_ratio` — `1.0 - (compressed_size / BASE_SIZE)`
- `crease_pattern` — array of crease hashes
- `beauty_score` — accumulates per fold, decreases on unfold

## Runners

Module: `Runners::CognitiveOrigami`

| Runner Method | Description |
|---|---|
| `create(name:, content:)` | Create a new figure |
| `fold(figure_id:, fold_type:, axis:, depth:, sharpness:)` | Apply a fold to a figure |
| `unfold(figure_id:)` | Remove the last fold |
| `list_figures` | All figures with status |
| `origami_status` | Aggregate stats |

All runners return `{success: true/false, ...}` hashes.

## Integration Points

- Models information compression: each fold reduces the cognitive footprint of a concept
- `lex-memory`: highly compressed figures (many folds) require reconstruction before use — parallel to latent memory traces requiring retrieval effort
- `lex-dream` consolidation phase: folding during consolidation = schema compression; unfolding = trace expansion during recall
- `complexity_label` can be used to gate action complexity: highly folded concepts may require unfolding before acting

## Development Notes

- `Client` instantiates `@origami_engine = Helpers::OrigamiEngine.new`
- `MAX_FOLDS = 12` is enforced in `fold!`; attempts beyond this return `{success: false, error: :max_folds_reached}`
- `BASE_SIZE = 1.0` (implicit); each fold reduces by `0.07`; at 12 folds: `compressed_size = 1.0 - 0.84 = 0.16`
- `beauty_score` is per-figure cumulative — it grows with each fold and drops when unfolding, incentivizing forward progress
- Crease `sharpness` softens via `CREASE_DECAY = 0.01` per cycle — old folds fade, requiring re-folding to stay crisp
