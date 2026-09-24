local running = true
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("[ScriptHub Debug] 1. Loading Rayfield UI...")

-- Safely load Rayfield UI
local Rayfield
local successLoad, errLoad = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not successLoad or not Rayfield then
    warn("[ScriptHub Error] Failed to load Rayfield UI: " .. tostring(errLoad))
    return
end

print("[ScriptHub Debug] 2. Rayfield loaded. Creating Window...")

-- Cleanup Handle
getgenv().ScriptHub_Cleanup = function()
    running = false
    pcall(function()
        if Rayfield then
            Rayfield:Destroy()
        end
    end)
end

-- Create Main Window
local Window = Rayfield:CreateWindow({
    Name = "Guess The Word Utility",
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "Prompt & Reward Helper",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

print("[ScriptHub Debug] 3. Window created. Setting up elements...")

-- Main Controls Tab
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

-- Settings Tab
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

print("[ScriptHub Debug] 4. Setup complete. Starting background loops...")

--------------------------------------------------------------------
-- 1. PROMPT WATCHER THREAD (FREEZE-SAFE)
--------------------------------------------------------------------
local lastStatusText = ""

local function getPromptLabelText()
    local character = LocalPlayer.Character
    if not character then return "game not started" end

    local head = character:FindFirstChild("Head")
    if not head then return "game not started" end

    for _, child in ipairs(head:GetChildren()) do
        if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
            local lbl = child:FindFirstChild("PromptLabel")
            if lbl and (lbl:IsA("TextLabel") or lbl:IsA("TextBox")) and lbl.Text ~= "" then
                return lbl.Text
            end
        end
    end

    return "game not started"
end

task.spawn(function()
    while running do
        local currentText = getPromptLabelText()

        -- ONLY update UI when the text actually changes
        if currentText ~= lastStatusText then
            lastStatusText = currentText
            pcall(function()
                StatusParagraph:Set({
                    Title = "Prompt Status",
                    Content = currentText
                })
            end)
        end

        task.wait(0.5)
    end
end)

--------------------------------------------------------------------
-- 2. REWARD CHEST TOUCH THREAD (CACHED SEARCH)
--------------------------------------------------------------------
local cachedChestPart = nil

local function getChestPart()
    -- Reuse cached part if still valid in workspace
    if cachedChestPart and cachedChestPart:IsDescendantOf(workspace) then
        return cachedChestPart
    end

    local obbies = workspace:FindFirstChild("Obbies")
    local impObby = obbies and obbies:FindFirstChild("Impossible Obby")
    local chest = impObby and impObby:FindFirstChild("Reward Chest")

    if chest then
        for _, desc in ipairs(chest:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Name == "Part" and desc:FindFirstChildOfClass("TouchTransmitter") then
                cachedChestPart = desc
                return desc
            end
        end
    end

    return nil
end

task.spawn(function()
    while running do
        if touchInterestEnabled then
            pcall(function()
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")

                if hrp and firetouchinterest then
                    local chestPart = getChestPart()
                    if chestPart then
                        firetouchinterest(hrp, chestPart, 0)
                        task.wait(0.1)
                        firetouchinterest(hrp, chestPart, 1)
                    end
                end
            end)
        end
        task.wait(1.5)
    end
end)

print("[ScriptHub Debug] Script fully loaded and running smoothly!")
