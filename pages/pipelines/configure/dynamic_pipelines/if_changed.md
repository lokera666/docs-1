# Using `if_changed`

The `if_changed` feature is a [glob pattern](/docs/pipelines/configure/glob-pattern-syntax) that omits the step from a build if it does not match any files changed in the build. For example: `**.go,go.mod,go.sum,fixtures/**`. This feature allows to detect changes in the repository and only build what changed.

> 📘 Notes on agent version requirements
> The minimum Buildkite Agent version required for using `if_changed` is v3.99 (with `--apply-if-changed` flag). Starting with Buildkite Agent version v3.103.0 and newer, this feature is enabled by default. From version 3.109.0 of the Buildkite Agent, `if_changed` also supports lists of glob patterns and `include` and `exclude` attributes.

`if_changed` can be used as an attribute of [command](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes-if-changed), [group](/docs/pipelines/configure/step-types/group-step#agent-applied-attributes-if-changed), [trigger](/docs/pipelines/configure/step-types/trigger-step#agent-applied-attributes-if-changed) steps, or by using the [agent CLI](/docs/agent/v3/cli/reference/pipeline#apply-if-changed) on the [pipeline upload command](/docs/agent/v3/cli/reference/pipeline) of the Buildkite Agent to detect [`if_changed` attribute](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes) usage in your pipeline steps.

> 🚧
> The `if_changed` is an agent-applied attribute, and such attributes are not accepted in pipelines set using the Buildkite interface. When used as an agent-applied attribute, it will only be applied by the Buildkite Agent when uploading a pipeline (`buildkite-agent pipeline upload`), since they require direct access to your code or repository to process correctly.

When enabled, steps containing an `if_changed` key are evaluated against the Git diff. If the `if_changed` glob pattern matches no files changed in the build, the step is skipped.

## Monorepo workflows

The `if_changed` feature is particularly useful for monorepo workflows, providing built-in change detection without requiring the monorepo-diff plugin. This can eliminate an extra pipeline generation cycle ("spawn a job to spawn more jobs") and simplify your pipeline configuration.

For example, in a monorepo with multiple services:

```yaml
steps:
  - label: "Frontend tests"
    command: "npm test"
    if_changed: "frontend/**"

  - label: "Backend tests"
    command: "go test ./..."
    if_changed:
      - "backend/**"
      - "go.{mod,sum}"

  - label: "Documentation build"
    command: "make docs"
    if_changed: "docs/**"
```

For more details on monorepo strategies, see [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos).

## How change detection works

The `if_changed` feature compares files against a base reference to determine what has changed:

- Default behavior - compares against `origin/main` (conceptually `git diff --merge-base origin/main`)
- Pull request builds - automatically uses the `BUILDKITE_PULL_REQUEST_BASE_BRANCH` environment variable
- Custom comparison base - override using environment variables:
    * `BUILDKITE_GIT_DIFF_BASE`: Explicitly set the comparison base
    * `BUILDKITE_PULL_REQUEST_BASE_BRANCH`: Set the PR base branch

Example with a custom comparison base:

```yaml
steps:
  - label: "Run if backend changed"
    command: "make test-backend"
    if_changed: "backend/**"
    env:
      BUILDKITE_GIT_DIFF_BASE: "origin/develop"
```

## What happens when steps are skipped

When the `if_changed` pattern doesn't match any changed files, the step is [skipped](/docs/pipelines/configure/dependencies#how-skipped-steps-affect-dependencies) (not removed). In the Buildkite Pipelines interface:

- Such step appears in your build with a "skipped" status
- The step's dependencies and dependents are handled appropriately
- Build annotations and metadata are still accessible
- The overall build continues to the next steps

This is similar to using a `skip` [attribute](/docs/pipelines/configure/step-types/command-step#command-step-attributes), but the decision is made dynamically based on file changes rather than being pre-determined.

## Glob pattern reference

The `if_changed` feature uses the [zzglob](https://github.com/DrJosh9000/zzglob) pattern syntax, which is similar to standard glob patterns but with some differences. For complete pattern syntax details, see [Glob pattern syntax](/docs/pipelines/configure/glob-pattern-syntax).

The key pattern features are:

- `**` matches any number of directories
- `*` matches any characters within a single path segment
- `?` matches a single character
- `{option1,option2}` matches either option (brace expansion)
- Character classes like `[abc]` or `[0-9]`

## Usage examples

These are some examples that demonstrate various forms of the `if_changed` feature.

> 🚧 Common mistake with dynamic pipelines
> When using dynamic pipelines, the `if_changed` attribute must be placed in the YAML file that uploaded during the `buildkite-agent pipeline upload` command, NOT in the step that performs the upload. This is necessary because the agent must have access to your repository when it processes the `if_changed` attribute during the `buildkite-agent pipeline upload` command.

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

Starting with Buildkite Agent version 3.109, lists of patterns are supported. If any changed file matches any of the patterns, the step runs. This provides a more readable alternative to brace expansion.

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

Starting with Buildkite Agent version 3.109, `include` and `exclude` attributes are supported. The `exclude` attribute eliminates matching files from causing a step to run. When using `exclude`, the `include` attribute is required.

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

### Conditional pipeline triggers

You can use `if_changed` on trigger steps to conditionally trigger downstream pipelines:

```yaml
steps:
  - label: "Trigger deployment pipeline"
    trigger: "deploy-production"
    if_changed:
      - "src/**"
      - "Dockerfile"
      - "deployment/**"
    build:
      message: "Deploy changes from ${BUILDKITE_BRANCH}"
      commit: "${BUILDKITE_COMMIT}"
      branch: "${BUILDKITE_BRANCH}"
```

## Advanced use cases for if_changed

Starting with Buildkite Agent version 3.109.0, you can provide a custom list of changed files instead of relying on Git diff. This is useful when:

- Working with shallow clones where Git history is limited
- Using external monorepo tools (for example, [Bazel](/docs/pipelines/tutorials/bazel)) that have their own change detection
- Integrating with CI systems that already compute changed files upstream
- Working with non-git repositories

Use the `--changed-files-path` flag or `BUILDKITE_CHANGED_FILES_PATH` environment variable:

```bash
# Generate changed files list (example with custom tooling)
echo "src/main.go
pkg/feature/handler.go
README.md" > changed-files.txt

# Upload pipeline with custom changed files
buildkite-agent pipeline upload --changed-files-path changed-files.txt
```

Or using the environment variable:

```yaml
steps:
  - label: "\:pipeline\: Upload dynamic steps"
    command: |
      # Your custom change detection
      nx affected:apps --plain > changed-files.txt
      buildkite-agent pipeline upload
    env:
      BUILDKITE_CHANGED_FILES_PATH: "changed-files.txt"
```

The file format is a newline-separated list of file paths relative to the repository root.

## Troubleshooting

In this section, you can find some of the issues that you might run into when using the `if_changed` feature and how to solve them.

### Step still runs when it shouldn't

1. **Check your agent version**: Ensure you're running agent v3.103.0+ (or using `--apply-if-changed` flag with v3.99+).
1. **Verify pattern placement**: Make sure `if_changed` is in the correct YAML file (see the dynamic pipelines note above).
1. **Test your glob pattern**: The pattern is matched against file paths relative to your repository root.
1. **Check the comparison base**: By default, files are compared against `origin/main`. Set `BUILDKITE_GIT_DIFF_BASE` if you need a different base.

### Pattern doesn't match expected files

1. **Use the correct syntax**: The pattern uses non-bash glob or regex syntax.
1. **Mind the whitespace**: In brace expansions like `{mod,sum}`, spaces are treated as part of the pattern.
1. **Quote special characters**: In YAML, patterns starting with `*` or other special characters must be quoted.
1. **Test locally**: You can test patterns using `git diff --name-only origin/main` to see which files changed.

### Agent shows "skipped" for all steps

This can happen if:

- The comparison base branch doesn't exist in your repository.
- You're working with a shallow clone that doesn't have the base branch.
- No files actually changed in the build.

Consider using `--changed-files-path` for shallow clone scenarios.
