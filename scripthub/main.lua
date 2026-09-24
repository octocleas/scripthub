-- ==========================================
--        UNIVERSAL SCRIPT HUB ROUTER        
-- ==========================================

local currentPlaceId = game.PlaceId

-- 1. BASE CONFIGURATION
-- FIXED: This now points straight to your actual repository's games folder
local githubRepo = "https://githubusercontent.com"

-- 2. SECURE LOADING FUNCTION (Prevents the hub from crashing if the internet/GitHub fails)
local function loadGameScript(fileName)
    local url = githubRepo .. fileName
    local success, scriptContent = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and scriptContent then
        local loadedScript, err = loadstring(scriptContent)
        if loadedScript then
            loadedScript() -- Executes the script
        else
            warn("Failed to compile script: " .. tostring(err))
        end
    else
        warn("Failed to fetch script from GitHub URL: " .. url)
    end
end

-- 3. GAME ROUTING LOGIC
if currentPlaceId == 87606058429594 then
    -- Replaces spaces with '%20' so the URL web request works perfectly
    loadGameScript("guess%20the%20word.lua")
    
-- You can add more games in the future by adding elseif blocks like this:
-- elseif currentPlaceId == SECOND_GAME_ID then
--     loadGameScript("another_game.lua")

else
    -- Fallback message if executed in an unsupported place
    warn("Script Hub Error: This game is not supported yet!")
end
