-- Services
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

-- Configuration
local GITHUB_USER = "octocleas"
local REPO_NAME = "scripthub"
local BRANCH = "main"

-- Path includes the nested 'scripthub' subfolder
local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/%s/scripthub/games/", GITHUB_USER, REPO_NAME, BRANCH)

-- Map Place IDs to script file names inside your 'games' folder
local SupportedGames = {
    [87606058429594] = "guess the word.lua",
}

-- Execution Logic
local currentPlaceId = game.PlaceId
local scriptName = SupportedGames[currentPlaceId]

if scriptName then
    local formattedFileName = string.gsub(scriptName, " ", "%%20")
    local scriptUrl = BASE_URL .. formattedFileName

    local success, err = pcall(function()
        local code = game:HttpGet(scriptUrl)
        
        if code == "404: Not Found" then
            error("HTTP 404 - File not found at: " .. scriptUrl)
        end

        local compiledFunc, syntaxError = loadstring(code)
        if not compiledFunc then
            error("Compile Error: " .. tostring(syntaxError))
        end

        compiledFunc()
    end)

    if not success then
        warn("[ScriptHub] Failed to execute game script: " .. tostring(err))
    end
else
    warn("[ScriptHub] Place ID " .. tostring(currentPlaceId) .. " is not supported.")
end
