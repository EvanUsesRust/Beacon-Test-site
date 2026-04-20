-- ===== SETUP =====
rednet.open("top") -- wired modem
local mon = peripheral.wrap("top")

mon.setTextScale(1.5)

-- ===== STATE =====
local y = 0
local cruising = false
local angle = 0

-- ===== DRAW UI =====
local function draw()
    mon.clear()

    mon.setCursorPos(1,1)
    mon.write("FLIGHT CONTROL")

    mon.setCursorPos(1,3)
    mon.write("Y: " .. math.floor(y))

    mon.setCursorPos(1,4)
    if cruising then
        mon.write("Mode: CRUISE")
    else
        mon.write("Mode: TAKEOFF")
    end

    mon.setCursorPos(1,5)
    mon.write("Rudder: " .. angle)

    -- buttons
    mon.setCursorPos(2,8)
    mon.write("[LEFT]")

    mon.setCursorPos(12,8)
    mon.write("[CENTER]")

    mon.setCursorPos(24,8)
    mon.write("[RIGHT]")
end

-- ===== TOUCH INPUT =====
local function handleTouch()
    while true do
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")

        if yPos == 8 and xPos >= 2 and xPos <= 7 then
            rednet.broadcast("left")

        elseif yPos == 8 and xPos >= 12 and xPos <= 19 then
            rednet.broadcast("center")

        elseif yPos == 8 and xPos >= 24 and xPos <= 31 then
            rednet.broadcast("right")
        end
    end
end

-- ===== RECEIVE STATUS =====
local function receiveStatus()
    while true do
        local id, msg = rednet.receive()

        if type(msg) == "table" then
            y = msg.y or y
            cruising = msg.cruising or false
            angle = msg.angle or angle

            draw()
        end
    end
end

-- ===== START =====
draw()
parallel.waitForAny(handleTouch, receiveStatus)
