-- Dungeon Honor Addon
-- This addon will add a styled message to the character tooltip and Premade Group Finder tooltips in World of Warcraft.

-- Create the main frame for the addon
local DungeonHonor = CreateFrame("Frame")

-- Event registration for when the tooltip is shown
DungeonHonor:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

-- Function to fetch Dungeon Honor score from the lookup table
local function GetDungeonHonorScore(name, realm)
    local key = string.lower(name) .. "-" .. string.lower(realm)
    -- print("Looking up: " .. (key or "nil"))
    return DungeonHonorData[key] or {
        score = nil,
        votes = nil
    } -- Return nil if no data is found
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

-- Function to add a styled message to the group tooltip
local function AddStyledMessageToGroupTooltip(resultID)
    if not resultID or type(resultID) ~= "number" then return end

    -- Fetch group info
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    if not searchResultInfo then return end

    local leaderName = searchResultInfo.leaderName

    if not leaderName then
        GameTooltip:AddLine(" ", 1, 1, 1) -- Empty line for spacing
        GameTooltip:AddDoubleLine("Dungeon Honor Score:", "Leader Unknown", 1, 0.85, 0, 0.5, 0.5, 0.5)
        GameTooltip:Show()
        return
    end

    -- Handle leaderName with or without realm
    local name, realm
    if string.find(leaderName, "-") then
        name, realm = string.match(leaderName, "([^%-]+)%-([^%-]+)")
    else
        name = leaderName
        realm = GetRealmName()
    end

    -- Fetch Dungeon Honor data for the group leader
    local data = GetDungeonHonorScore(name, realm)

    -- Add Dungeon Honor info to the tooltip
    GameTooltip:AddLine(" ", 1, 1, 1) -- Empty line for spacing

    if data and data.score then
        local r, g, b = GetColorForScore(data.score)
        GameTooltip:AddDoubleLine("Dungeon Honor Score", tostring(data.score), 1, 0.85, 0, r, g, b)
        GameTooltip:AddDoubleLine("Received votes", tostring(data.votes), 1.0, 1.0, 1.0, 1, 1, 1)
    else
        GameTooltip:AddDoubleLine("Dungeon Honor Score:", "Not Found", 1, 0.85, 0, 0.5, 0.5, 0.5)
    end

    GameTooltip:Show()
end

-- Hook into Premade Group Finder tooltips
local function HookGroupFinderTooltips()
    hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", function(tooltip, resultID)
        -- Ensure resultID is valid
        if tooltip and resultID then
            AddStyledMessageToGroupTooltip(resultID)
        end
    end)
end

-- Initialization
DungeonHonor:RegisterEvent("ADDON_LOADED")
DungeonHonor:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "DungeonHonor" then
            HookGroupFinderTooltips()
        end
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        -- Add message to the player tooltip
        if UnitExists("mouseover") and UnitIsPlayer("mouseover") then
            local name, realm = UnitName("mouseover"), GetRealmName()

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
end)
