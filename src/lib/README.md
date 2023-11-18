Lua libraries depended on by the game. Almost everything is re-exported in `std.lua`, so all you need to do is:

```lua
local std = require "lib.std"
```
