---
toc: false
---
<!--
  _____   ____    _   _  ____ _______   ______ _____ _____ _______
  |  __  / __   |  | |/ __ __   __| |  ____|  __ _   _|__   __|
  | |  | | |  | | |  | | |  | | | |    | |__  | |  | || |    | |
  | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |
  | |__| | |__| | | |  | |__| | | |    | |____| |__| || |_   | |
  |_____/ ____/  |_| _|____/  |_|    |______|_____/_____|  |_|
  This file is auto-generated by script/generate_graphql_api_content.sh,
  please build the schema.json by running `rails api:graph:export`
  with https://github.com/buildkite/buildkite/,
  replace the content in data/graphql_data_schema.json
  and run the generation script `./scripts/generate-graphql-api-content.sh`.
-->
<!-- vale off -->
<h1 class="has-pills" data-algolia-exclude>
  SSOProviderSAMLSPType
  <span class="pill pill--object pill--normal-case pill--large"><code>OBJECT</code></span>
</h1>
<!-- vale on -->


<p>Information about Buildkite as a SAML Service Provider</p>


<table class="responsive-table responsive-table--single-column-rows">
  <thead>
    <th>
      <h2 data-algolia-exclude>Fields</h2>
    </th>
  </thead>
  <tbody>
    <tr><td><h3 class="is-small has-pills"><code>issuer</code><a href="/docs/apis/graphql/schemas/scalar/string" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR String"><code>String</code></a></h3><p>The IdP Issuer value for this SSO Provider</p></td></tr><tr><td><h3 class="is-small has-pills"><code>metadata</code><a href="/docs/apis/graphql/schemas/object/ssoprovidersamlmetadatatype" class="pill pill--object pill--normal-case pill--medium" title="Go to OBJECT SSOProviderSAMLMetadataType"><code>SSOProviderSAMLMetadataType</code></a></h3><p>The metadata used to configure this SSO provider if it was provided</p></td></tr><tr><td><h3 class="is-small has-pills"><code>ssoURL</code><a href="/docs/apis/graphql/schemas/scalar/string" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR String"><code>String</code></a></h3><p>The IdP SSO URL for this SSO Provider</p></td></tr>
  </tbody>
</table>