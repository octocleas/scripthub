-- Kill previous execution threads if re-ran
if getgenv().ScriptHub_Cleanup then
    getgenv().ScriptHub_Cleanup()
end

local running = true
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Global Cleanup Function
getgenv().ScriptHub_Cleanup = function()
    running = false
    pcall(function()
        if Rayfield then
            Rayfield:Destroy()
        end
    end)
end

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Guess The Word Utility",
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "Prompt & Reward Helper",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- UI Setup
local MainTab = Window:CreateTab("Main Controls", 4483362458)
MainTab:CreateSection("Game Status")

local StatusParagraph = MainTab:CreateParagraph({
    Title = "Prompt Status",
    Content = "game not started"
})

MainTab:CreateSection("Automation")

local touchInterestEnabled = false

MainTab:CreateToggle({
    Name = "Touch Chest Loop",
    CurrentValue = false,
    Flag = "TouchChestState",
    Callback = function(Value)
        touchInterestEnabled = Value
    end,
})

local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("Lifecycle")
SettingsTab:CreateButton({
    Name = "Unload UI",
    Callback = function()
        if getgenv().ScriptHub_Cleanup then
            getgenv().ScriptHub_Cleanup()
        end
    end,
})

-- 1. Prompt Watcher Thread
local function getPromptLabel()
    local character = LocalPlayer.Character
    local head = character and character:FindFirstChild("Head")
    if not head then return nil end

    local promptLabel = head:FindFirstChild("PromptLabel", true)
    if promptLabel and (promptLabel:IsA("TextLabel") or promptLabel:IsA("TextBox")) then
        return promptLabel
    end
    return nil
end

task.spawn(function()
    while running do
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
        task.wait(0.2)
    end
end)

-- 2. Touch Interest Thread
task.spawn(function()
    while running do
        if touchInterestEnabled then
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")

            if hrp and firetouchinterest then
                local obbies = workspace:FindFirstChild("Obbies")
                local impObby = obbies and obbies:FindFirstChild("Impossible Obby")
                local chest = impObby and impObby:FindFirstChild("Reward Chest")

                if chest then
                    for _, desc in ipairs(chest:GetDescendants()) do
                        if not running or not touchInterestEnabled then break end
                        if desc:IsA("BasePart") and desc.Name == "Part" and desc:FindFirstChildOfClass("TouchTransmitter") then
                            firetouchinterest(hrp, desc, 0)
                            task.wait(0.05)
                            firetouchinterest(hrp, desc, 1)
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end)
