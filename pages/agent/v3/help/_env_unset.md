<!--
  _____   ____    _   _  ____ _______   ______ _____ _____ _______
 |  __ \ / __ \  | \ | |/ __ \__   __| |  ____|  __ \_   _|__   __|
 | |  | | |  | | |  \| | |  | | | |    | |__  | |  | || |    | |
 | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |
 | |__| | |__| | | |\  | |__| | | |    | |____| |__| || |_   | |
 |_____/ \____/  |_| \_|\____/  |_|    |______|_____/_____|  |_|

This file is auto-generated by scripts/update-agent-help.sh, please update the
agent CLI help in https://github.com/buildkite/agent and run the generation
script.

-->

### Usage

`buildkite-agent env unset [variables]`

### Description

Unsets environment variables in the current job execution environment.
Changes to the job environment variables only apply to subsequent phases of the job.
This command cannot unset Buildkite read-only variables.

To read the new values of variables from within the current phase, use `env get`.

Note that this subcommand is only available from within the job executor with the job-api experiment enabled.

### Examples

Unsetting the variables `LLAMA` and `ALPACA`:

```shell
$ buildkite-agent env unset LLAMA ALPACA
Unset:
- ALPACA
- LLAMA
```

Unsetting the variables `LLAMA` and `ALPACA` with a JSON list supplied over standard input

```shell
$ echo '["LLAMA","ALPACA"]' | \
    buildkite-agent env unset --input-format=json --output-format=quiet -
```

### Options

<!-- vale off -->

<table class="Docs__attribute__table">
<tr id="no-color"><th><code>--no-color </code> <a class="Docs__attribute__link" href="#no-color">#</a></th><td><p>Don't show colors in logging<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_NO_COLOR</code></p></td></tr>
<tr id="debug"><th><code>--debug </code> <a class="Docs__attribute__link" href="#debug">#</a></th><td><p>Enable debug mode. Synonym for `--log-level debug`. Takes precedence over `--log-level`<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_DEBUG</code></p></td></tr>
<tr id="log-level"><th><code>--log-level value</code> <a class="Docs__attribute__link" href="#log-level">#</a></th><td><p>Set the log level for the agent, making logging more or less verbose. Defaults to notice. Allowed values are: debug, info, error, warn, fatal (default: "notice")<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_LOG_LEVEL</code></p></td></tr>
<tr id="experiment"><th><code>--experiment value</code> <a class="Docs__attribute__link" href="#experiment">#</a></th><td><p>Enable experimental features within the buildkite-agent<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_EXPERIMENT</code></p></td></tr>
<tr id="profile"><th><code>--profile value</code> <a class="Docs__attribute__link" href="#profile">#</a></th><td><p>Enable a profiling mode, either cpu, memory, mutex or block<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_PROFILE</code></p></td></tr>
<tr id="input-format"><th><code>--input-format value</code> <a class="Docs__attribute__link" href="#input-format">#</a></th><td><p>Input format: plain or json (default: "plain")<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_ENV_UNSET_INPUT_FORMAT</code></p></td></tr>
<tr id="output-format"><th><code>--output-format value</code> <a class="Docs__attribute__link" href="#output-format">#</a></th><td><p>Output format: quiet (no output), plain, json, or json-pretty (default: "plain")<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_ENV_UNSET_OUTPUT_FORMAT</code></p></td></tr>
</table>

<!-- vale on -->
