-- ===== CONFIG =====
local targetY = 135

local pulseSide = "left"
local dirSide = "right"
local engineSide = "back"

-- ===== SETUP =====
rednet.open("top") -- wired modem

-- ===== STATE =====
local cruising = false
local currentAngle = 0

-- ===== HELPERS =====
local function pulse()
    redstone.setOutput(pulseSide, true)
    sleep(1)
    redstone.setOutput(pulseSide, false)
    sleep(0.2)
end

local function setRudder(targetAngle)
    if targetAngle == currentAngle then return end

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

-- ===== NETWORK LOOP =====
local function networkControl()
    while true do
        local id, msg = rednet.receive()

        if msg == "left" then
            setRudder(45)
        elseif msg == "center" then
            setRudder(0)
        elseif msg == "right" then
            setRudder(-45)
        end
    end
end

-- ===== STATUS SENDER =====
local function sendStatus()
    while true do
        local x, y, z = gps.locate(1)

        local data = {
            y = y or 0,
            cruising = cruising,
            angle = currentAngle
        }

        rednet.broadcast(data)
        sleep(0.5)
    end
end

-- ===== RUN =====
parallel.waitForAny(altitudeControl, networkControl, sendStatus)
