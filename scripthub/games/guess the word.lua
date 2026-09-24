-- ====================================================================
-- Rayfield UI Adapter for Guess the Word
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create Main Window
local Window = Rayfield:CreateWindow({
    Name = "Guess The Word Utility",
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "Prompt & Reward Helper",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false
})

-- ====================================================================
-- TAB: Main Automation
-- ====================================================================
local MainTab = Window:CreateTab("Main Controls", 4483362458)

MainTab:CreateSection("Game Status")

-- Dynamic Status Display (Replaces StatusLabel)
local StatusParagraph = MainTab:CreateParagraph({
    Title = "Prompt Status",
    Content = "game not started"
})

MainTab:CreateSection("Automation")

local touchInterestEnabled = false

-- Toggle for Chest Automation
local ChestToggle = MainTab:CreateToggle({
    Name = "Touch Chest Loop",
    CurrentValue = false,
    Flag = "TouchChestState",
    Callback = function(Value)
        touchInterestEnabled = Value
    end,
})

-- ====================================================================
-- TAB: Settings & Clean Unload
-- ====================================================================
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateSection("Lifecycle")

SettingsTab:CreateButton({
    Name = "Unload UI",
    Callback = function()
        touchInterestEnabled = false
        Rayfield:Destroy()
    end,
})

-- ====================================================================
-- 1. PROMPT WATCHER THREAD
-- ====================================================================
local function getPromptLabel()
    local character = LocalPlayer.Character
    if not character then return nil end

    local head = character:FindFirstChild("Head")
    if not head then return nil end

    local promptLabel = head:FindFirstChild("PromptLabel", true)
    if promptLabel and (promptLabel:IsA("TextLabel") or promptLabel:IsA("TextBox")) then
        return promptLabel
    end
    return nil
end

task.spawn(function()
    while true do
        local promptLabel = getPromptLabel()

        if promptLabel and promptLabel.Text ~= "" then
            StatusParagraph:Set({
                Title = "Prompt Status",
                Content = promptLabel.Text
            })
        else
            StatusParagraph:Set({
                Title = "Prompt Status",
                Content = "game not started"
            })
        end

        task.wait(0.1)
    end
end)

-- ====================================================================
-- 2. REWARD CHEST TOUCH INTEREST THREAD
-- ====================================================================
task.spawn(function()
    while true do
        if touchInterestEnabled then
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")

            if hrp and firetouchinterest then
                local obbies = workspace:FindFirstChild("Obbies")
                if obbies then
                    local impObby = obbies:FindFirstChild("Impossible Obby")
                    if impObby then
                        local chest = impObby:FindFirstChild("Reward Chest")
                        if chest then
                            for _, desc in ipairs(chest:GetDescendants()) do
                                if desc:IsA("BasePart") and desc.Name == "Part" and desc:FindFirstChildOfClass("TouchTransmitter") then
                                    firetouchinterest(hrp, desc, 0)
                                    task.wait(0.05)
                                    firetouchinterest(hrp, desc, 1)
                                end
                            end
                        end
                    end
                end
            end
        end

        task.wait(1)
    end
end)
