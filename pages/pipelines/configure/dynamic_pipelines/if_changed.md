# Using `if_changed`

The `if_changed` feature is a [glob pattern](/docs/pipelines/configure/glob-pattern-syntax) that omits the step from a build if it does not match any files changed in the build. For example: `**.go,go.mod,go.sum,fixtures/**`. This feature allows to detect changes in the repository and only build what changed.

> 📘 Notes on agent version requirements
> The minimum Buildkite Agent version required for using `if_changed` is v3.99 (with `--apply-if-changed` flag). Starting with Buildkite Agent version v3.103.0 and newer, this feature is enabled by default. From version 3.109.0 of the Buildkite Agent, `if_changed` also supports lists of glob patterns and `include` and `exclude` attributes.

`if_changed` can be used as an attribute of [command](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes-if-changed), [group](/docs/pipelines/configure/step-types/group-step#agent-applied-attributes-if-changed), [trigger](/docs/pipelines/configure/step-types/trigger-step#agent-applied-attributes-if-changed) steps, or by using the [agent CLI](/docs/agent/v3/cli/reference/pipeline#apply-if-changed) on the [pipeline upload command](/docs/agent/v3/cli/reference/pipeline) of the Buildkite Agent to detect [`if_changed` attribute](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes) usage in your pipeline steps.

> 🚧
> The `if_changed` is an agent-applied attribute, and such attributes are not accepted in pipelines set using the Buildkite interface. When used as an agent-applied attribute, it will only be applied by the Buildkite Agent when uploading a pipeline (`buildkite-agent pipeline upload`), since they require direct access to your code or repository to process correctly.

When enabled, steps containing an `if_changed` key are evaluated against the Git diff. If the `if_changed` glob pattern matches no files changed in the build, the step is skipped.

## Usage examples

These are some examples that demonstrate various forms of `if_changed`.

### Single glob pattern

The simplest form of `if_changed` uses a single glob pattern to match files. This step only runs if any `.go` file anywhere in the repository changes:

```yaml
steps:
  - label: "Only run if a .go file anywhere in the repo is changed"
    if_changed: "**.go"
```

> 📘
> YAML requires some strings containing special characters to be quoted.

### Brace expansion for multiple patterns

Braces `{,}` let you combine patterns and subpatterns within a single string. This step only runs if `go.mod` or `go.sum` changes:

```yaml
steps:
  - label: "Only run if go.mod or go.sum are changed"
    if_changed: go.{mod,sum}
```

> 🚧
> This syntax is whitespace-sensitive. A space within a pattern is treated as part of the file path to be matched. For example, `go.{mod, sum}` would not work as expected.

You can combine recursive patterns with brace expansion. This step runs if any Go-related file changes:

```yaml
steps:
  - label: "Run if any Go-related file is changed"
    if_changed: "{**.go,go.{mod,sum}}"
```

This step runs for any changes within the `app/` or `spec/` directories:

```yaml
steps:
  - label: "Run for any changes within app/ or spec/"
    if_changed: "{app/**,spec/**}"
```

### Pattern lists

Starting from version 3.109 of the Buildkite Agent, lists of patterns are supported. If any changed file matches any of the patterns, the step runs. This provides a more readable alternative to brace expansion.

This step runs if any Go-related file changes:

```yaml
steps:
  - label: "Run if any Go-related file is changed"
    if_changed:
      - "**.go"
      - go.{mod,sum}
```

This step runs for any changes in the `app/` or `spec/` directories:

```yaml
steps:
  - label: "Run for any changes in app/ or spec/"
    if_changed:
      - app/**
      - spec/**
```

### Include and exclude attributes

Starting from version 3.109 of the Buildkite Agent, `include` and `exclude` attributes are supported. The `exclude` attribute eliminates matching files from causing a step to run. When using `exclude`, the `include` attribute is required.

This step runs for changes in `spec/`, but not for changes in `spec/integration/`:

```yaml
steps:
  - label: "Run for changes in spec/, but not in spec/integration/"
    if_changed:
      include: spec/**
      exclude: spec/integration/**
```

Both `include` and `exclude` can use pattern lists. This step runs for changes in `api/` or `internal/`, but excludes `api/docs/` and any `.py` files in `internal/`:

```yaml
steps:
  - label: "Run for api and internal, but not api/docs or internal .py files"
    if_changed:
      include:
        - api/**
        - internal/**
      exclude:
        - api/docs/**
        - internal/**.py
```
