# DX components pilot

This repository consumes the shared agents, tools and reusable CI workflows
without installing the DX Feature or runtime.

Before working, read `$DX_AGENTS_HOME/AGENTS.md` when `DX_AGENTS_HOME` is
nonempty. Otherwise read `.devcontainer/components/agents/AGENTS.md` relative
to this repository. Load that document once and follow its shared rules and
resource selection procedure. Report an unavailable bootstrap instead of
silently skipping it.

Run `task validate`, `task lint` and `task test` with
`TASK_REMOTE_TRUSTED_HOSTS=github.com`. The `fail` task is intentional;
`missing` is deliberately undefined. Neither belongs in nominal CI.

[Consumer contracts](docs/contracts.md).
