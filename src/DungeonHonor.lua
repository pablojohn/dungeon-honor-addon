-- Dungeon Honor Addon
-- This addon will add a styled message to the character tooltip in World of Warcraft.

-- Create the main frame for the addon
local DungeonHonor = CreateFrame("Frame")

-- Event registration for when the tooltip is shown
DungeonHonor:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

-- Function to fetch Dungeon Honor score from the lookup table
local function GetDungeonHonorScore(playerName, playerRealm)
    local key = playerName .. "-" .. playerRealm
    print("Looking up this: " .. (key or "nil"))
    return DungeonHonorData[key] or { score = nil, votes = nil } -- Return nil if no data is found
end

-- Function to determine the color based on the score
local function GetColorForScore(score)
    if score >= 95 then
        return 1.0, 0.5, 0.0 -- Legendary
    elseif score >= 85 then
        return 0.64, 0.21, 0.93 -- Epic
    elseif score >= 70 then
        return 0.0, 0.44, 0.87 -- Rare
    elseif score >= 50 then
        return 0.0, 1.0, 0.0 -- Common
    else
        return 0.5, 0.5, 0.5 -- Uncommon
    end
end

-- Function to add a styled message to the tooltip
local function AddStyledMessageToTooltip()
    -- Ensure the tooltip is showing a unit (e.g., a player or NPC)
    if UnitExists("mouseover") and UnitIsPlayer("mouseover") then
        local name, realm = UnitName("mouseover"), GetRealmName()
        print("Name: " .. (name or "nil"))

        local data = GetDungeonHonorScore(name, realm)

        GameTooltip:AddLine(" ", 1, 1, 1) -- Empty line for spacing

        if data.score then
            local r, g, b = GetColorForScore(data.score)
            GameTooltip:AddDoubleLine("Dungeon Honor Score", tostring(data.score), 1, 0.85, 0, r, g, b)
            GameTooltip:AddDoubleLine("Received votes", tostring(data.votes), 1.0, 1.0, 1.0, 1, 1, 1)
        else
            GameTooltip:AddDoubleLine("Dungeon Honor Score:", "Not Found", 1, 0.85, 0, 0.5, 0.5, 0.5)
        end

        GameTooltip:Show()
    end
end

-- Set the script for when the registered event occurs
DungeonHonor:SetScript("OnEvent", function(self, event, ...)
    if event == "UPDATE_MOUSEOVER_UNIT" then
        AddStyledMessageToTooltip()
    end
end)
