# lex-cognitive-origami

Paper folding metaphor for conceptual compression in LegionIO cognitive agents. Figures are folded along axes, each fold compressing the figure and adding a crease. Up to 12 folds per figure. Beauty score accumulates with each fold.

## What It Does

- Five fold types: `valley`, `mountain`, `reverse`, `squash`, `petal`
- Each fold reduces compressed size by ~7% and increases beauty score
- Maximum 12 folds per figure (masterwork complexity)
- Unfold removes the last fold (reversible)
- Creases have sharpness that softens over time (CREASE_DECAY = 0.01/cycle)
- Track compression ratio, crease pattern, and complexity labels

## Usage

```ruby
# Create a figure
result = runner.create(name: 'microservices_concept',
                        content: 'decompose by bounded context with async events')
figure_id = result[:figure][:id]

# Apply folds
runner.fold(figure_id: figure_id, fold_type: :valley, axis: 'domain_boundary',
             depth: 0.5, sharpness: 0.9)
runner.fold(figure_id: figure_id, fold_type: :mountain, axis: 'service_contract',
             depth: 0.3, sharpness: 0.8)

# Check compression
runner.list_figures
# => { success: true, figures: [{ complexity: 2, compressed_size: 0.86,
#                                  compression_ratio: 0.14, beauty_score: 1.7, ... }] }

# Unfold (undo last fold)
runner.unfold(figure_id: figure_id)

# Status
runner.origami_status
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
