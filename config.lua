Config = {
    colors = {
        bg = { 30, 41, 59, 200 },
        text = { 255, 255, 255, 255 },
        skill = {
            base = { 255, 255, 255, 180 },
            success = { 34, 197, 94, 255 },
            failed = { 248, 113, 113, 255 }
        },
        cursor = { 255, 0, 0, 255 },
    },
    -- Keys
    keys = {
        ['Q'] = {
            keyCode = 44
        },
        ['W'] = {
            keyCode = 32
        },
        ['E'] = {
            keyCode = 38
        },
        ['R'] = {
            keyCode = 45
        }
    },
    -- Predefined difficulties
    difficulties = {
        easy = {
            gap = 20,
            speedMultiplier = 1.0,
            minPosition = 50,
            isReversed = false,
            isVertical = false,
        },
        medium = {
            gap = 20,
            speedMultiplier = 4.0,
            minPosition = 50,
            isReversed = false,
            isVertical = true,
        },
        hard = {
            gap = 18,
            speedMultiplier = 6.0,
            minPosition = 50,
            isReversed = true,
            isVertical = false,
        },
        veryhard = {
            gap = 15,
            speedMultiplier = 7.0,
            minPosition = 50,
            isReversed = true,
            isVertical = true,
        }
    }
}
