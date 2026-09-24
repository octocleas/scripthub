local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Target parent for executor GUIs
local guiParent
if gethui then
    guiParent = gethui()
elseif CoreGui then
    guiParent = CoreGui
else
    guiParent = player:WaitForChild("PlayerGui")
end

-- Destroy previous UI instance if re-executed
local existingGui = guiParent:FindFirstChild("PromptWatcherGui")
if existingGui then
    existingGui:Destroy()
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PromptWatcherGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

-- Main Frame container (holds Status and Toggle)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 95)
mainFrame.Position = UDim2.new(0.5, -160, 0.05, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 45)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statusLabel.BackgroundTransparency = 0.2
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 15
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.Text = "game not started"
statusLabel.Active = true
statusLabel.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

local statusStroke = Instance.new("UIStroke")
statusStroke.Color = Color3.fromRGB(80, 80, 80)
statusStroke.Thickness = 1.5
statusStroke.Parent = statusLabel

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 0, 42)
toggleButton.Position = UDim2.new(0, 0, 0, 50)
toggleButton.BackgroundColor3 = Color3.fromRGB(160, 45, 45) -- Default OFF (Red)
toggleButton.BackgroundTransparency = 0.2
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 15
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Text = "Touch Chest: OFF"
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(80, 80, 80)
toggleStroke.Thickness = 1.5
toggleStroke.Parent = toggleButton

--------------------------------------------------------------------
-- 1. DRAGGABLE GUI LOGIC
--------------------------------------------------------------------
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

statusLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

statusLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

--------------------------------------------------------------------
-- 2. TOGGLE STATE CONTROLLER
--------------------------------------------------------------------
local touchInterestEnabled = false

toggleButton.MouseButton1Click:Connect(function()
    touchInterestEnabled = not touchInterestEnabled

    if touchInterestEnabled then
        toggleButton.Text = "Touch Chest: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(45, 160, 60) -- Green
    else
        toggleButton.Text = "Touch Chest: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(160, 45, 45) -- Red
    end
end)

--------------------------------------------------------------------
-- 3. PROMPT WATCHER SECTION
--------------------------------------------------------------------
local function getPromptLabel()
    local character = player.Character
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
    while screenGui and screenGui.Parent do
        local promptLabel = getPromptLabel()

        if promptLabel and promptLabel.Text ~= "" then
            statusLabel.Text = promptLabel.Text
        else
            statusLabel.Text = "game not started"
        end

        task.wait(0.1)
    end
end)

--------------------------------------------------------------------
-- 4. REWARD CHEST TOUCH INTEREST SECTION (DIRECT WORKSPACE PATH)
--------------------------------------------------------------------
task.spawn(function()
    while screenGui and screenGui.Parent do
        if touchInterestEnabled then
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")

            if hrp and firetouchinterest then
                -- Workspace -> Obbies -> Impossible Obby -> Reward Chest
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
