# DX components pilot

Real consumer of `Gildraen/dx-agents`, `Gildraen/dx-tools` and
`Gildraen/ci-workflows`. Its Dev Container installs Go Task 3.53.1 only;
no DX Feature or runtime is installed.

[Agent bootstrap](AGENTS.md). [Consumer contracts](docs/contracts.md).
[Submodule sources](.gitmodules).
[Repository](https://github.com/Gildraen/dx-components-pilot).

## Components

Git submodules pin agents to `b65f27291bff63349fb221c38241350514275de9`
and tools to `935bd0b6e03438a218cc7afec9fd5786b79a8c14` under
`.devcontainer/components/`. The Dev Container initializes them with
`git submodule update --init --recursive` before creation.

`DX_AGENTS_HOME` selects the shared agent bootstrap. `DX_TOOLS_HOME` selects
the tools checkout. The tools `bin/` directory is on the container's remote
`PATH`; `task tools:mcp:github -- [server options...]` calls its launcher.
Running the MCP server requires Docker and a reachable daemon; the pilot
does not install Docker. Component tests use a fake Docker CLI.

The Taskfile includes the tools helper through Task's native HTTP reader at
the same tools SHA. Task 3.53.1's Git reader forces `depth=1`, so its
`https://github.com/Gildraen/dx-tools.git//taskfiles/base.yml?ref=<SHA>` form
cannot clone a commit SHA. The HTTP include keeps `github.com` as the
trusted entrypoint and does not use a floating ref.

Renovate extends `github>Gildraen/renovate-config#feat/component-extraction`
and explicitly enables its native `git-submodules` manager. The preset
branch must be published for Renovate to resolve it. The HTTP Task include
is independently pinned; it is not managed by the native submodule manager.

## Local Checks

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
`ee36dca8e6a5b2c40a652fcd438e4e6451c9e108`. No workflow targets `main`.

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
