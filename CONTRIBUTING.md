# Contributing to BGLR AI

This repository stores curated **BGLR examples** used to train an AI agent to write, run, and interpret [BGLR](https://github.com/gdlc/BGLR-R) code. To keep the training data consistent and machine-readable, every example must follow the structure and schema described below.

## Repository layout

```
README.md              # Index of all examples (see the Examples table)
CONTRIBUTING.md        # This file
agent/
  glossary.json        # concept name -> plain-language definition
  ontology.json        # model name -> structured metadata (concepts, prerequisites, ...)
  model_index.csv      # flat index of all models for quick lookup
data/
  <dataset>/
    <dataset>.txt        # raw data (header row, space/tab separated)
    description.json     # dataset metadata
examples/
  <exampleName>/
    <exampleName>.md     # the worked example (prose + runnable R code)
    metadata.json        # structured metadata for the example
utils/
  utils.r              # shared helper functions (e.g. coef.BGLR)
```

## Adding a new example

1. Create a folder `examples/<exampleName>/` (use lowerCamelCase, e.g. `fixedEffects`).
2. Add `<exampleName>.md` with the worked example (see **Example markdown** below).
3. Add `metadata.json` following the **Metadata schema** below.
4. Register the example in:
   - the Examples table in [README.md](README.md),
   - [agent/ontology.json](agent/ontology.json),
   - [agent/model_index.csv](agent/model_index.csv).
5. If the example uses a new dataset, add it under `data/<dataset>/` with a `description.json`.
6. Reuse concept names already defined in [agent/glossary.json](agent/glossary.json); add new terms there rather than inventing synonyms.
7. Run the validation steps below before opening a pull request.

## Example markdown (`<exampleName>.md`)

- Start with a level-1 title (`# ...`).
- Include a short **Key concepts** section listing the concepts covered (matching glossary terms).
- Provide runnable R code in fenced ```` ```r ```` blocks. Code should run top-to-bottom without manual edits.
- Load data from the canonical raw URL so examples are self-contained, e.g.
  `https://raw.githubusercontent.com/QuantGen/BGLR_AI/refs/heads/main/data/<dataset>/<file>`.
- Source shared helpers from
  `https://raw.githubusercontent.com/QuantGen/BGLR_AI/refs/heads/main/utils/utils.r`.
- Use `$b` / `$SD.b` for fixed-effect coefficient estimates and SDs (BGLR field names).
- End with a back-link: `[← Back to examples](https://github.com/QuantGen/BGLR_AI)`.

## Metadata schema (`metadata.json`)

Every example's `metadata.json` must be valid JSON with the following fields (use `null` when not applicable):

| Field | Type | Description |
|-------|------|-------------|
| `model_name` | string | Unique PascalCase model name (matches ontology key + `Model` where appropriate). |
| `category` | string | High-level family, e.g. `regression`. |
| `subtype` | string | Specific type, e.g. `intercept`, `fixed`. |
| `description` | string | One-sentence summary of the model. |
| `inputs` | string[] | Expected inputs, e.g. `["phenotype_vector"]`. |
| `outputs` | string[] | Produced outputs, e.g. `["intercept", "residual_variance"]`. |
| `hyperparameters` | object | Map of hyperparameter name → description (e.g. `nIter`, `burnIn`). `{}` if none. |
| `dependencies` | string[] | R packages required, e.g. `["BGLR"]`. |
| `difficulty` | string | `beginner`, `intermediate`, or `advanced`. |
| `tags` | string[] | Free-form search tags. |
| `concepts` | string[] | Concept names, each defined in `agent/glossary.json`. |
| `data` | string \| null | Workspace-relative path to the dataset, or `null` if simulated/none. |
| `source` | string \| null | Upstream source URL the example is adapted from, or `null`. |
| `path` | string | Workspace-relative path to the example markdown file. |

### Example

```json
{
  "model_name": "InterceptOnlyModel",
  "category": "regression",
  "subtype": "intercept",
  "description": "Gaussian regression model with no predictors, estimating only the intercept and the residual variance.",
  "inputs": ["phenotype_vector"],
  "outputs": ["intercept", "residual_variance"],
  "hyperparameters": {
    "nIter": "Number of MCMC iterations",
    "burnIn": "Number of burn-in iterations"
  },
  "dependencies": ["BGLR"],
  "difficulty": "beginner",
  "tags": ["intercept", "baseline model", "regression", "variance estimation"],
  "concepts": [
    "Intercept",
    "Posterior means and posterior SD",
    "CoefficientEstimation"
  ],
  "data": null,
  "source": null,
  "path": "examples/interceptOnly/interceptOnly.md"
}
```

## Ontology entry (`agent/ontology.json`)

Add one top-level key per model. Fields:

- `category`, `subtype` — mirror the metadata.
- `prerequisites` — background knowledge required (PascalCase).
- `concepts` — same concept names used in the example's metadata and glossary.
- `related_models` — other models the reader may explore next.
- `inputs`, `outputs` — PascalCase versions of the metadata inputs/outputs.
- `use_cases` — short phrases describing when to use the model.

## Dataset description (`data/<dataset>/description.json`)

Include at least: `dataset_name`, `file_name`, `source`, `description`, `variables` (name → description), `format` (`type`, `delimiter`, `header`, `notes`), `use_cases`, and `notes`.

## Status values (README table)

- `TBR` — To Be Reviewed (draft written, pending review).
- `TBD` — To Be Developed (planned, not yet written).
- `Done` — reviewed and finalized.

## Validation

Before submitting, verify JSON validity and R syntax:

```bash
# Validate all JSON files
for f in agent/*.json examples/*/metadata.json data/*/description.json; do
  python3 -c "import json,sys; json.load(open('$f')); print('OK', '$f')"
done

# Check R helper syntax (requires R)
Rscript -e 'invisible(parse("utils/utils.r")); cat("utils.r OK\n")'
```

All checks must pass with no errors.
