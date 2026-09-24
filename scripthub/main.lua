-- Global Thread Cleanup (Prevents game crashes from stacked loops)
if getgenv().ScriptHub_Cleanup then
    getgenv().ScriptHub_Cleanup()
end

local Players = game:GetService("Players")

-- Configuration
local GITHUB_USER = "octocleas"
local REPO_NAME = "scripthub"
local BRANCH = "main"

-- Direct Raw Path to nested folder
local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/%s/scripthub/games/", GITHUB_USER, REPO_NAME, BRANCH)

local SupportedGames = {
    [87606058429594] = "guess the word.lua",
}

local currentPlaceId = game.PlaceId
local scriptName = SupportedGames[currentPlaceId]

if scriptName then
    local formattedFileName = string.gsub(scriptName, " ", "%%20")
    local scriptUrl = BASE_URL .. formattedFileName

    -- Fetch Raw File
    local fetchSuccess, rawCode = pcall(function()
        return game:HttpGet(scriptUrl)
    end)

    if not fetchSuccess or not rawCode or rawCode == "404: Not Found" then
        warn("[ScriptHub] Could not find file at URL: " .. tostring(scriptUrl))
        return
    end

    -- Compile Luau
    local compiledFunc, syntaxErr = loadstring(rawCode)
    if not compiledFunc then
        warn("[ScriptHub] Syntax error in " .. scriptName .. ": " .. tostring(syntaxErr))
        return
    end

    -- Safely run in separate thread
    task.spawn(compiledFunc)
else
    warn("[ScriptHub] Place ID " .. tostring(currentPlaceId) .. " is not supported.")
end
