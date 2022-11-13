
# Simple skill check

### Pretty simple skill check
You'll be able to run a skillcheck for somekind of actions.

### Usage
```lua
exports.fd_skill:skill(difficulty)
```
* `difficulty` - `easy`, `medium`, `hard` or `veryhard`
	1. difficulties can be adjusted, changed or added in `config.lua` file.
	2. You can pass custom difficulty as an object
		- `gap` - gap size for skill;
		- `speedMultiplier` - increase speed of the cursor;
		- `minPosition` - minimum position from top for gap;
		- `isVertical` - defines if skill should be vertical;
		- `isReverted` - defines if cursor should move from other side;
		```lua
		{
			gap = 20,
            speedMultiplier = 1.0,
            minPosition = 50,
            isReversed = false,
            isVertical = false,
		}
		```

### Simple example
```lua
local success = exports.fd_skill:skill('easy')

if not success then
	print('Skillcheck failed')
	return
end
```

### Simple example with custom difficulty
```lua
local success = exports.fd_skill:skill({
	gap = 20,
    speedMultiplier = 1.0,
    minPosition = 50,
    isReversed = false,
    isVertical = false,
})

if not success then
	print('Skillcheck failed')
	return
end
```

### Multi cycle example
```lua
local success = exports.fd_skill:skill('medium', 'medium', 'medium', {
	gap = 20,
    speedMultiplier = 1.0,
    minPosition = 50,
    isReversed = false,
    isVertical = false,
})

if not success then
	print('Skillcheck failed')
	return
end
