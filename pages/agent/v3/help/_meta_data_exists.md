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

`buildkite-agent meta-data exists <key> [options...]`

### Description

The command exits with a status of 0 if the key has been set, or it will
exit with a status of 100 if the key doesn&#39;t exist.

### Example

```shell
$ buildkite-agent meta-data exists "foo"
```

### Options

<!-- vale off -->

<table class="Docs__attribute__table">
<tr id="no-color"><th><code>--no-color </code> <a class="Docs__attribute__link" href="#no-color">#</a></th><td><p>Don't show colors in logging<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_NO_COLOR</code></p></td></tr>
<tr id="debug"><th><code>--debug </code> <a class="Docs__attribute__link" href="#debug">#</a></th><td><p>Enable debug mode. Synonym for `--log-level debug`. Takes precedence over `--log-level`<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_DEBUG</code></p></td></tr>
<tr id="log-level"><th><code>--log-level value</code> <a class="Docs__attribute__link" href="#log-level">#</a></th><td><p>Set the log level for the agent, making logging more or less verbose. Defaults to notice. Allowed values are: debug, info, error, warn, fatal (default: "notice")<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_LOG_LEVEL</code></p></td></tr>
<tr id="experiment"><th><code>--experiment value</code> <a class="Docs__attribute__link" href="#experiment">#</a></th><td><p>Enable experimental features within the buildkite-agent<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_EXPERIMENT</code></p></td></tr>
<tr id="profile"><th><code>--profile value</code> <a class="Docs__attribute__link" href="#profile">#</a></th><td><p>Enable a profiling mode, either cpu, memory, mutex or block<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_PROFILE</code></p></td></tr>
<tr id="agent-access-token"><th><code>--agent-access-token value</code> <a class="Docs__attribute__link" href="#agent-access-token">#</a></th><td><p>The access token used to identify the agent<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_ACCESS_TOKEN</code></p></td></tr>
<tr id="endpoint"><th><code>--endpoint value</code> <a class="Docs__attribute__link" href="#endpoint">#</a></th><td><p>The Agent API endpoint (default: "<code>https://agent.buildkite.com/v3</code>")<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_ENDPOINT</code></p></td></tr>
<tr id="no-http2"><th><code>--no-http2 </code> <a class="Docs__attribute__link" href="#no-http2">#</a></th><td><p>Disable HTTP2 when communicating with the Agent API.<br /><strong>Environment variable</strong>: <code>$BUILDKITE_NO_HTTP2</code></p></td></tr>
<tr id="debug-http"><th><code>--debug-http </code> <a class="Docs__attribute__link" href="#debug-http">#</a></th><td><p>Enable HTTP debug mode, which dumps all request and response bodies to the log<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_DEBUG_HTTP</code></p></td></tr>
<tr id="trace-http"><th><code>--trace-http </code> <a class="Docs__attribute__link" href="#trace-http">#</a></th><td><p>Enable HTTP trace mode, which logs timings for each HTTP request. Timings are logged at the debug level unless a request fails at the network level in which case they are logged at the error level<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_TRACE_HTTP</code></p></td></tr>
<tr id="job"><th><code>--job value</code> <a class="Docs__attribute__link" href="#job">#</a></th><td><p>Which job's build should the meta-data be checked for<br /><strong>Environment variable</strong>: <code>$BUILDKITE_JOB_ID</code></p></td></tr>
<tr id="build"><th><code>--build value</code> <a class="Docs__attribute__link" href="#build">#</a></th><td><p>Which build should the meta-data be retrieved from. --build will take precedence over --job<br /><strong>Environment variable</strong>: <code>$BUILDKITE_METADATA_BUILD_ID</code></p></td></tr>
</table>

<!-- vale on -->
