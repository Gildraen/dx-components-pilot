# DX components pilot

Real consumer of `Gildraen/dx-agents`, `Gildraen/dx-tools` and
`Gildraen/ci-workflows`. Its Dev Container installs Go Task 3.53.1 only;
no DX Feature or runtime is installed.

[Agent bootstrap](AGENTS.md). [Consumer contracts](docs/contracts.md).
[Submodule sources](.gitmodules).
[Repository](https://github.com/Gildraen/dx-components-pilot).

## Components

The candidate consumption version of the shared components is `v0.1.0-rc.1`,
a prerelease, not a stable release. Agents and tools are Git submodules under
`.devcontainer/components/`. Selecting a version tag resolves a commit, which
the parent repository records as a gitlink. The Dev Container initializes the
recorded commits with
`git submodule update --init --recursive` before creation.

`DX_AGENTS_HOME` selects the shared agent bootstrap. `DX_TOOLS_HOME` selects
the tools checkout. The tools `bin/` directory is on the container's remote
`PATH`; `task tools:mcp:github -- [server options...]` calls its launcher.
Running the MCP server requires Docker and a reachable daemon; the pilot
does not install Docker. Component tests use a fake Docker CLI.

The Taskfile includes the tools helper through Task 3.53.1's native HTTP reader
at `https://github.com/Gildraen/dx-tools/raw/v0.1.0-rc.1/taskfiles/base.yml`.
The include keeps `github.com` as the trusted entrypoint and selects a fixed
version tag.

Renovate extends `github>Gildraen/renovate-config#v0.1.0-rc.1`.
The preset tag must be published for Renovate to resolve it. Native submodule
updates are disabled so that branch updates cannot replace the selected
versions. Update the gitlinks explicitly when selecting new component tags.
The versioned HTTP Task include is managed separately by the preset.

## Local Checks

To select the candidate submodule versions, initialize the checkouts, select
the tags, then record the resolved gitlinks in the parent repository:

```sh
git submodule update --init --recursive
git -C .devcontainer/components/agents checkout --detach v0.1.0-rc.1
git -C .devcontainer/components/tools checkout --detach v0.1.0-rc.1
git add .devcontainer/components/agents .devcontainer/components/tools
```

To validate the recorded checkouts:

```sh
git submodule update --init --recursive
export TASK_REMOTE_TRUSTED_HOSTS=github.com
env -u DX_HOME task validate
env -u DX_HOME task lint
env -u DX_HOME task test
```

`validate` checks the trust environment and consumer files. `lint` initializes
the submodules and runs their validation contracts. `test` runs both real
component suites and the remotely included tools doctor with an explicit
`DX_TOOLS_HOME` pointing to the tools submodule.

## GitHub Execution

The three caller workflows and component integration run on pushes to
`feat/component-extraction` and support manual dispatch. All reusable calls
pin `Gildraen/ci-workflows` to
`v0.1.0-rc.1`. No workflow targets `main`.

Validation exercises the default task and a custom `task-name: lint`.
Devcontainer testing runs `task test` inside the consumer container.
Maintenance exercises both default inputs and custom paths with an exclusion
for this repository's GitHub URL. Component integration checks out submodules
and runs `validate` and `test` on the runner without DX.

After publishing the branch, inspect the nominal runs:

```sh
gh run list --repo Gildraen/dx-components-pilot --branch feat/component-extraction --event push
gh run view RUN_ID --repo Gildraen/dx-components-pilot --log-failed
gh run watch RUN_ID --repo Gildraen/dx-components-pilot --exit-status
```

Manual dispatch requires the workflow to exist on the repository's default
branch. Its current value is visible with:

```sh
gh repo view Gildraen/dx-components-pilot --json defaultBranchRef
```

Once dispatch is available, each negative run below is expected to fail.
The separate negative workflow has no push trigger and cannot make nominal
push CI red.

```sh
gh workflow run negative-validate.yml --repo Gildraen/dx-components-pilot --ref feat/component-extraction -f task-name=fail
gh workflow run negative-validate.yml --repo Gildraen/dx-components-pilot --ref feat/component-extraction -f task-name=missing
gh run list --repo Gildraen/dx-components-pilot --workflow negative-validate.yml --branch feat/component-extraction
```
