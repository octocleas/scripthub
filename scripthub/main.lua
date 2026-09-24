-- Services
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

-- Configuration: Set your GitHub repository details here
local GITHUB_USER = "YourGitHubUsername" -- Replace with your actual GitHub username
local REPO_NAME = "scripthub"
local BRANCH = "main"

local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/%s/games/", GITHUB_USER, REPO_NAME, BRANCH)

-- Map Place IDs to script file names inside your 'games' folder
local SupportedGames = {
    [87606058429594] = "guess the word.lua",
}

-- Rayfield Notification Helper
local function notifyUser(title, content)
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = 5,
        Image = 4483362458
    })
end

-- Execution Logic
local currentPlaceId = game.PlaceId
local scriptName = SupportedGames[currentPlaceId]

if scriptName then
    local formattedFileName = string.gsub(scriptName, " ", "%%20")
    local scriptUrl = BASE_URL .. formattedFileName

    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)

    if not success then
        warn("[ScriptHub] Failed to execute game script: " .. tostring(err))
        notifyUser("Error Loading Script", "Failed to fetch script for this game.")
    end
else
    notifyUser("ScriptHub", "This game is currently not supported.")
end
