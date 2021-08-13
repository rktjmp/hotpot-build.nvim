# THIS IS EXPERIMENTAL

The repo may disappear, force push, rm -rf /, anything.

Use at own risk.

# hotpot-build.nvim

## What

Hotpot friend to build plugins for you.

## How

`:HotpotBuild`

or

`:lua require("hotpot.api.build").build()`

By default `build` will compile any `fnl` folder into `lua`.

Optionally:

Create `hotpotfile.fnl`, export `build` function. `hotpotfile.fnl` code has
access to `compile-file`, `compile-dir`.

See https://github.com/rktjmp/hotpot.nvim/issues/18
