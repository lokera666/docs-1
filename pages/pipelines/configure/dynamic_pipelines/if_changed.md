# Using `if_changed`

THe `if_changed` feature can be uses as an agent-applied attribute on command, group, and trigger steps, as well as via CLI.

When used as an agent-applied attribute, it will only be applied by the Buildkite Agent when uploading a pipeline (`buildkite-agent pipeline upload`), since they require direct access to your code or repository to process correctly.

`if_changed` is a [glob pattern](/docs/pipelines/configure/glob-pattern-syntax) that omits the step from a build if it does not match any files changed in the build. For example:`**.go,go.mod,go.sum,fixtures/**`.

From version 3.109.0 of the Buildkite Agent, `if_changed` also supports lists of glob patterns and `include` and `exclude` attributes.

Minimum Buildkite Agent versions:</em> 3.99 (with <code>--apply-if-changed</code> flag), 3.103.0 (enabled by default), 3.109.0 (expanded syntax).

> 🚧
> Agent-applied attributes are not accepted in pipelines set using the Buildkite interface.

When enabled, steps containing an `if_changed` key are evaluated against the git diff. If the `if_changed` glob pattern match no files changed in the build, the step is skipped. Minimum Buildkite Agent version: v3.99 (with --apply-if-changed flag), v3.103.0 (enabled by default) [$BUILDKITE_AGENT_APPLY_IF_CHANGED, $BUILDKITE_AGENT_APPLY_SKIP_IF_UNCHANGED]. Environment variable `$BUILDKITE_AGENT_APPLY_IF_CHANGED`.

Example pipeline, demonstrating various forms of `if_changed`:

```yaml
steps:
  # if_changed can specify a single glob pattern.
  # Note that YAML requires some strings to be quoted.
  - label: "Only run if a .go file anywhere in the repo is changed"
    if_changed: "**.go"

  # Braces {,} let you combine patterns and subpatterns.
  # Note that this syntax is whitespace-sensitive: a space within a
  # pattern is treated as part of the file path to be matched.
  - label: "Only run if go.mod or go.sum are changed"
    if_changed: go.{mod,sum}
    # Wrong: go.{mod, sum}

  # Combining the two previous examples:
  - label: "Run if any Go-related file is changed"
    if_changed: "{**.go,go.{mod,sum}}"

  # A less Go-centric example:
  - label: "Run for any changes within app/ or spec/"
    if_changed: "{app/**,spec/**}"

  # From version 3.109 of the Buildkite Agent, lists of patterns
  # are supported. If any changed file matches any of the patterns,
  # the step is run. This can be a more ergonomic alternative to
  # using braces.
  - label: "Run if any Go-related file is changed"
    if_changed:
      - "**.go"
      - go.{mod,sum}

  - label: "Run for any changes in app/ or spec/"
    if_changed:
      - app/**
      - spec/**

  # From version 3.109 of the Buildkite Agent, `include` and
  # `exclude` are supported attributes. As for `if_changed`, these
  # attributes may contain single patterns or lists of patterns.
  # `exclude` eliminates changed files from causing a step to run.
  # If the `exclude` attribute is present, then the `include` attribute,
  # along with its pattern or list of patterns, is required too.
  - label: "Run for changes in spec/, but not in spec/integration/"
    if_changed:
      include: spec/**
      exclude: spec/integration/**

  - label: "Run for api and internal, but not api/docs or internal .py files"
    if_changed:
      include:
        - api/**
        - internal/**
      exclude:
        - api/docs/**
        - internal/**.py
```
