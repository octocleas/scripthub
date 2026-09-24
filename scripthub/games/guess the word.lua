local running = true
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load Rayfield UI Library safely
local Rayfield
local successLoad, errLoad = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not successLoad or not Rayfield then
    warn("[ScriptHub] Failed to load Rayfield library.")
    return
end

-- Cleanup function definition
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
            getgenv().ScriptHub_Cleanup = nil
        end
    end,
})

-- Non-recursive safe prompt label search
local function getPromptLabel()
    local character = LocalPlayer.Character
    if not character then return nil end

    local head = character:FindFirstChild("Head")
    if not head then return nil end

    -- Direct check under BillboardGuis without deep recursive searching
    for _, child in ipairs(head:GetChildren()) do
        if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
            local lbl = child:FindFirstChild("PromptLabel")
            if lbl and (lbl:IsA("TextLabel") or lbl:IsA("TextBox")) then
                return lbl
            end
        end
    end

    return nil
end

-- 1. Prompt Watcher Thread
task.spawn(function()
    while running do
        pcall(function()
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
        end)
        task.wait(0.25)
    end
end)

-- 2. Touch Interest Thread
task.spawn(function()
    while running do
        if touchInterestEnabled then
            pcall(function()
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
            end)
        end
        task.wait(1)
    end
end)
