-- ===== CONFIG =====
local targetY = 135

-- rudder sides
local pulseSide = "left"
local dirSide = "right"

-- altitude side
local engineSide = "back"

-- ===== STATE =====
local cruising = false
local currentAngle = 0 -- assume starting centered

-- ===== HELPERS =====
local function pulse()
    redstone.setOutput(pulseSide, true)
    sleep(1)
    redstone.setOutput(pulseSide, false)
    sleep(0.2)
end

local function setRudder(targetAngle)
    if targetAngle == currentAngle then
        return
    end

    local diff = targetAngle - currentAngle
    local steps = math.abs(diff) / 45

    if diff < 0 then
        redstone.setAnalogOutput(dirSide, 15)
    else
        redstone.setAnalogOutput(dirSide, 0)
    end

    for i = 1, steps do
        pulse()
    end

    currentAngle = targetAngle
end

-- ===== ALTITUDE LOOP =====
local function altitudeControl()
    rednet.open("top")

    while true do
        local x, y, z = gps.locate(2)

        if y then
            if not cruising then
                redstone.setAnalogOutput(engineSide, 15)

                if y >= targetY then
                    cruising = true
                end
            else
                if y > 135 then
                    redstone.setAnalogOutput(engineSide, 7)
                elseif y < 130 then
                    redstone.setAnalogOutput(engineSide, 8)
                else
                    redstone.setAnalogOutput(engineSide, 7)
                end
            end
        else
            redstone.setAnalogOutput(engineSide, 0)
        end

        sleep(0.25)
    end
end

-- ===== RUDDER LOOP =====
local function rudderControl()
    while true do
        local input = read()

        if input == "left" then
            setRudder(45)
        elseif input == "center" then
            setRudder(0)
        elseif input == "right" then
            setRudder(-45)
        end
    end
end

-- ===== RUN BOTH =====
parallel.waitForAny(altitudeControl, rudderControl)
