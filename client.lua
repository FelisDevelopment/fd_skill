local listening = false

local function cleaup()
    listening = false
end

local function doSkill(gapSize, speedMultiplier, isVertical, isReversed, minPosition)
    local p = promise:new()
    local ped = PlayerPedId()
    local randomKey = getRandomKey(Config.keys)

    -- Dirty dirty hacks
    local colors = json.decode(json.encode(Config.colors))
    local baseWidth, baseHeight = convertSize(128.0, 128.0)
    local baseX, baseY = 0.5, 0.695

    -- Skill stuff
    local _, skillHeight = convertSize(0, gapSize or 15)
    local minPosition, maxPosition = minPosition or math.random(40, 60),
        math.floor((baseWidth - skillHeight) * 1000.0)

    if isVertical then
        local maxPosition = math.floor(maxPosition)

        if minPosition > maxPosition then
            minPosition = math.floor(minPosition - (math.floor(maxPosition) / 2))
        end

        if minPosition <= 0 then
            minPosition = 10
        end
    end

    local skillPosition = isVertical and (math.random(minPosition, math.floor(maxPosition)) / 1000.0) -
        (baseWidth / 2) or math.random(minPosition, math.floor((baseHeight - skillHeight) * 1000.0)) / 1000.0 -
        baseHeight / 2

    -- Cursor stuff
    local screenX, screenY = GetActiveScreenResolution()
    local cursorSize = isVertical and 1.0 / screenY or 3.0 / screenX
    local cursorPosition = isVertical and 0.0 + baseX - (baseWidth / 2) or 0.0 + (baseY - (baseHeight / 2))
    local cursorMovement = 0.0

    if isReversed then
        cursorPosition = isVertical and 0.0 + baseX + (baseWidth / 2) or 0.0 + baseY + (baseHeight / 2)
        skillPosition = skillPosition * -1
    end

    listening = true
    local moveCursor = true

    local gapStart = (baseY + skillPosition) - (skillHeight / 2.0)
    local gapEnd = (baseY + skillPosition + skillHeight) - (skillHeight / 2.0)

    if isVertical then
        gapStart = (baseX + skillPosition) - (skillHeight / 2.0)
        gapEnd = (baseX + skillPosition + skillHeight) - (skillHeight / 2.0)
    end

    -- Draw thread
    Citizen.CreateThread(function()
        while listening do
            DisableAllControlActions(0)

            SetScriptGfxDrawOrder(7)

            SetTextColour(table.unpack(colors.text))
            SetTextScale(0.0, 1.25)
            SetTextDropshadow(10, 0, 0, 0, 255)
            SetTextOutline()
            SetTextFont(4)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentSubstringPlayerName(randomKey)
            EndTextCommandDisplayText(baseX, baseY - (baseHeight / 3))

            DrawRect(
                baseX,
                baseY,
                baseWidth,
                baseHeight,
                table.unpack(colors.bg)
            )

            SetScriptGfxDrawOrder(9)

            --Draw skill indicator
            DrawRect(
                isVertical and baseX + skillPosition or baseX,
                isVertical and baseY or baseY + skillPosition,
                isVertical and skillHeight or baseWidth,
                isVertical and baseHeight or skillHeight,
                table.unpack(colors.skill.base)
            )

            SetScriptGfxDrawOrder(8)

            -- Cursor
            DrawRect(
                isVertical and cursorPosition + cursorMovement - (cursorSize / 2) or baseX,
                isVertical and baseY or cursorPosition + cursorMovement - (cursorSize / 2),
                isVertical and cursorSize or baseWidth,
                isVertical and baseHeight or cursorSize,
                table.unpack(colors.cursor)
            )

            SetScriptGfxDrawOrder(1)

            Wait(0)
        end
    end)

    -- Cursor thread
    local timer = GetGameTimer()
    local tick = 0
    Citizen.CreateThread(function()
        while moveCursor do
            local delta = GetGameTimer() - timer
            timer = GetGameTimer()

            tick = moveCursor and tick + (delta * ((speedMultiplier or 1) / 100) * (isReversed and -1 or 1)) or tick
            cursorMovement = tick / 1000.0

            if (cursorMovement >= baseHeight and not isVertical) or (cursorMovement >= baseWidth and isVertical) or
                (cursorMovement * -1 >= baseHeight and isReversed) or
                (cursorMovement * -1 >= baseWidth and isReversed and isVertical) then
                moveCursor = false
                colors.skill.base = colors.skill.failed

                Wait(250)
                cleaup()
                p:resolve(false)
            end

            if moveCursor and IsDisabledControlJustReleased(0, 200) then
                cleaup()
                p:resolve(false)
            end

            if IsPedRagdoll(ped) then
                cleaup()
                p:resolve(false)
            end

            Wait(0)
        end
    end)

    -- Keys thread
    Citizen.CreateThread(function()
        while listening and moveCursor do
            for key, data in pairs(Config.keys) do
                if IsDisabledControlJustReleased(0, data.keyCode) or IsControlJustReleased(0, data.keyCode) then
                    local currentPosition = cursorPosition + cursorMovement - (cursorSize / 2)

                    if key == randomKey and currentPosition >= gapStart and
                        currentPosition <= gapEnd then
                        moveCursor = false
                        colors.skill.base = colors.skill.success

                        Wait(250)
                        cleaup()
                        p:resolve(true)
                    else
                        moveCursor = false
                        colors.skill.base = colors.skill.failed

                        Wait(250)
                        cleaup()
                        p:resolve(false)
                    end
                end
            end
            Wait(0)
        end
    end)

    return p
end

local function doSkillFromString(difficulty)
    difficulty = Config.difficulties[difficulty]

    if not difficulty then
        print('Invalid difficulty. Please check your config.')
        return false
    end

    return Citizen.Await(
        doSkill(
            difficulty.gap or 20,
            difficulty.speedMultiplier or 1.0,
            difficulty.isVertical or false,
            difficulty.isReversed or false,
            difficulty.minPosition or 10
        )
    )
end

function skill(difficulty)
    if type(difficulty) == 'string' then
        return doSkillFromString(difficulty)
    end

    if type(difficulty) == 'table' then
        for _, data in pairs(difficulty) do
            Wait(0)
            if type(data) == 'string' then
                if not doSkillFromString(data) then
                    return false
                end
            end

            if type(data) == 'table' then
                local success = Citizen.Await(
                    doSkill(
                        data.gap or 20,
                        data.speedMultiplier or 1.0,
                        data.isVertical or false,
                        data.isReversed or false,
                        data.minPosition or 10
                    )
                )

                if not success then
                    return false
                end
            end
        end

        return true
    end
end

exports('skill', skill)
