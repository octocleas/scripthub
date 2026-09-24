-- Safely clean up previous script instance if running
if getgenv().ScriptHub_Cleanup then
    pcall(getgenv().ScriptHub_Cleanup)
    getgenv().ScriptHub_Cleanup = nil
end

local Players = game:GetService("Players")

-- Configuration
local GITHUB_USER = "octocleas"
local REPO_NAME = "scripthub"
local BRANCH = "main"

local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/%s/scripthub/games/", GITHUB_USER, REPO_NAME, BRANCH)

local SupportedGames = {
    [87606058429594] = "guess the word.lua",
}

local currentPlaceId = game.PlaceId
local scriptName = SupportedGames[currentPlaceId]

if scriptName then
    local formattedFileName = string.gsub(scriptName, " ", "%%20")
    local scriptUrl = BASE_URL .. formattedFileName

    local fetchSuccess, rawCode = pcall(function()
        return game:HttpGet(scriptUrl)
    end)

    if not fetchSuccess or not rawCode or rawCode == "404: Not Found" then
        warn("[ScriptHub] Could not find file at URL: " .. tostring(scriptUrl))
        return
    end

    local compiledFunc, syntaxErr = loadstring(rawCode)
    if not compiledFunc then
        warn("[ScriptHub] Syntax error in " .. scriptName .. ": " .. tostring(syntaxErr))
        return
    end

    task.spawn(compiledFunc)
else
    warn("[ScriptHub] Place ID " .. tostring(currentPlaceId) .. " is not supported.")
end
