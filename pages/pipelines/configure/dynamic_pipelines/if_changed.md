# Using `if_changed`

The `if_changed` feature is a [glob pattern](/docs/pipelines/configure/glob-pattern-syntax) that omits the step from a build if it does not match any files changed in the build. For example: `**.go,go.mod,go.sum,fixtures/**`. This feature allows to detect changes in the repository and only build what changed.

> 📘 Notes on agent version requirements
> The minimum Buildkite Agent version required for using `if_changed` is v3.99 (with `--apply-if-changed` flag). Starting with Buildkite Agent version v3.103.0 and newer, this feature is enabled by default. From version 3.109.0 of the Buildkite Agent, `if_changed` also supports lists of glob patterns and `include` and `exclude` attributes.

`if_changed` can be used as an attribute of [command](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes-if-changed), [group](/docs/pipelines/configure/step-types/group-step#agent-applied-attributes-if-changed), [trigger](/docs/pipelines/configure/step-types/trigger-step#agent-applied-attributes-if-changed) steps, or by using the [agent CLI](/docs/agent/v3/cli/reference/pipeline#apply-if-changed) on the [pipeline upload command](/docs/agent/v3/cli/reference/pipeline) of the Buildkite Agent to detect [`if_changed` attribute](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes) usage in your pipeline steps.

> 🚧
> The `if_changed` is an agent-applied attribute, and such attributes are not accepted in pipelines set using the Buildkite interface. When used as an agent-applied attribute, it will only be applied by the Buildkite Agent when uploading a pipeline (`buildkite-agent pipeline upload`), since they require direct access to your code or repository to process correctly.

When enabled, steps containing an `if_changed` key are evaluated against the Git diff. If the `if_changed` glob pattern matches no files changed in the build, the step is skipped.

## Usage examples

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
