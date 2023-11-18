project atlas:

 - `conf.lua` - configuration script executed by Love before game boot
 - `main.lua` - entry point executed by Love
 - `src/`
    - `engine/` - core engine code. relatively game-agnostic
    - `game/` - game code
        - `entry.lua` - the actual entry point, called immediately by `main.lua`
    - `lib/` - lua library dependencies
        - `forked/` - external libraries modified for the game
        - `local/` - local libraries created for the game
        - `vendored/` - external libraries copied straight into the repo
        - `std.lua` - standard module that re-exports the majority of dependencies
