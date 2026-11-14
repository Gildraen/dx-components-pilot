# Consumer Contracts

Validation runs the consumer Taskfile on the GitHub runner. Its default
contract checks that `TASK_REMOTE_TRUSTED_HOSTS` includes `github.com` and
that consumer configuration files exist. The custom `lint` contract checks
the pinned agents and tools through their own `validate` tasks.

Tests run both components' real test suites and the remotely included
`tools:doctor` task. Task exports explicit component homes and the tools
launcher path. The integration workflow runs these contracts outside DX;
the reusable devcontainer workflow runs them inside the consumer container.

Maintenance checks local and remote documentation links after recursively
initializing submodules. Its default caller leaves both inputs unset. Its
custom caller selects this document and the README, excluding the pilot's
GitHub URL.

The manually dispatched negative validation selects `fail`, which exits
with an error, or `missing`, which Task cannot resolve. Both runs must fail;
neither is selected by nominal workflows.

[Pilot](../README.md).
