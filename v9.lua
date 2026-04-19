rednet.open("top")

local cruising = false
local targetY = 135

while true do
    local x, y, z = gps.locate(2)

    if y then
        print("Y level:", y)

        -- Phase 1: takeoff
        if not cruising then
            redstone.setAnalogOutput("back", 15)

            if y >= targetY then
                cruising = true
                print("Cruising mode engaged")
            end

        -- Phase 2: cruise control
        else
            if y > 135 then
                redstone.setAnalogOutput("back", 7) -- go down
            elseif y < 130 then
                redstone.setAnalogOutput("back", 8) -- go up
            else
                -- hold gentle balance in middle zone
                redstone.setAnalogOutput("back", 7)
            end
        end

    else
        redstone.setAnalogOutput("back", 0)
        print("GPS lost")
    end

    sleep(0.25)
end
