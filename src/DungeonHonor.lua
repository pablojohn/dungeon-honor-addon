-- Dungeon Honor Addon
-- This addon will add a styled message to the character tooltip and Premade Group Finder tooltips in World of Warcraft.

-- Create the main frame for the addon
local DungeonHonor = CreateFrame("Frame")

-- Event registration for when the tooltip is shown
DungeonHonor:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

-- Function to fetch Dungeon Honor score from the lookup table
local function GetDungeonHonorScore(name, realm)
    local key = string.lower(name) .. "-" .. string.lower(realm)
    print("Looking up: " .. (key or "nil"))
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

-- Function to fetch Dungeon Honor score and add to tooltip
local function AddDungeonHonorToTooltip(tooltip, resultID)
    if not tooltip or not resultID then return end

    -- Fetch search result or applicant info
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    local applicantInfo = C_LFGList.GetApplicantInfo(resultID)
    local name, realm

    if searchResultInfo and searchResultInfo.leaderName then
        -- Handling for group leader
        if string.find(searchResultInfo.leaderName, "-") then
            name, realm = string.match(searchResultInfo.leaderName, "([^%-]+)%-([^%-]+)")
        else
            name = searchResultInfo.leaderName
            realm = GetRealmName()
        end
    elseif applicantInfo then
        print("applicantapplicant")
        -- Handling for applicant
        for _, memberInfo in ipairs(applicantInfo.memberIDs or {}) do
            local memberName = C_LFGList.GetApplicantMemberInfo(resultID, memberInfo)
            if memberName then
                if string.find(memberName, "-") then
                    name, realm = string.match(memberName, "([^%-]+)%-([^%-]+)")
                else
                    name = memberName
                    realm = GetRealmName()
                end
                break -- Only show the first member
            end
        end
    end

    -- If no name is found, return
    if not name or not realm then return end

    -- Fetch Dungeon Honor score
    local data = GetDungeonHonorScore(name, realm)

    -- Add Dungeon Honor info to the tooltip
    tooltip:AddLine(" ", 1, 1, 1) -- Empty line for spacing

    if data and data.score then
        local r, g, b = GetColorForScore(data.score)
        tooltip:AddDoubleLine("Dungeon Honor Score", tostring(data.score), 1, 0.85, 0, r, g, b)
        tooltip:AddDoubleLine("Received votes", tostring(data.votes), 1.0, 1.0, 1.0, 1, 1, 1)
    else
        tooltip:AddDoubleLine("Dungeon Honor Score:", "Not Found", 1, 0.85, 0, 0.5, 0.5, 0.5)
    end

    tooltip:Show()
end

-- Hook into Premade Group Finder tooltips
local function HookGroupFinderTooltips()
    hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", function(tooltip, resultID)
        -- Ensure resultID is valid
        if tooltip and resultID then
            AddDungeonHonorToTooltip(tooltip, resultID)
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
