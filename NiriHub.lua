-- Niri Hub ⚡ (Painel translúcido com borda RGB, título RGB, arrastável e botão de fechar/abrir com bolinha flutuante)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Limpa se já estiver rodando
if _G.NiriHub and type(_G.NiriHub.cleanup) == "function" then
    pcall(function() _G.NiriHub.cleanup() end)
    task.wait(0.05)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NiriHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local holder = { conns = {} }
_G.NiriHub = { gui = screenGui, holder = holder }
local function keepConn(c) if c then table.insert(holder.conns, c) end end

-- Função para arrastar
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Painel principal
local panel = Instance.new("Frame", screenGui)
panel.Size = UDim2.new(0, 600, 0, 400)
panel.Position = UDim2.new(0.2, 0, 0.2, 0)
panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
panel.BackgroundTransparency = 0.3
panel.BorderSizePixel = 0

local pc = Instance.new("UICorner", panel)
pc.CornerRadius = UDim.new(0, 15)

-- Borda RGB no painel
local stroke = Instance.new("UIStroke", panel)
stroke.Thickness = 4
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.LineJoinMode = Enum.LineJoinMode.Round

local hue = 0
keepConn(RunService.RenderStepped:Connect(function(dt)
    hue = (hue + dt * 0.25) % 1
    stroke.Color = Color3.fromHSV(hue, 1, 1)
end))

-- Título RGB
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "⚡ Niri Hub ⚡"
title.Font = Enum.Font.GothamBold
title.TextSize = 30
title.TextColor3 = Color3.fromRGB(255, 255, 255)

local hue2 = 0
keepConn(RunService.RenderStepped:Connect(function(dt)
    hue2 = (hue2 + dt * 0.3) % 1
    title.TextColor3 = Color3.fromHSV(hue2, 1, 1)
end))

-- Botão de fechar painel
local toggleBtn = Instance.new("TextButton", panel)
toggleBtn.Size = UDim2.new(0, 120, 0, 40)
toggleBtn.Position = UDim2.new(0.5, -60, 1, -50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "Fechar"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 20
local bc = Instance.new("UICorner", toggleBtn)
bc.CornerRadius = UDim.new(0, 8)

-- Bolinha flutuante (quando painel fechado)
local ball = Instance.new("TextButton", screenGui)
ball.Size = UDim2.new(0, 60, 0, 60)
ball.Position = UDim2.new(0.05, 0, 0.7, 0)
ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ball.BackgroundTransparency = 0.5
ball.Text = "⚡"
ball.TextSize = 28
ball.Font = Enum.Font.GothamBold
ball.Visible = false
local bc2 = Instance.new("UICorner", ball)
bc2.CornerRadius = UDim.new(1, 0)

-- Borda RGB na bolinha
local ballStroke = Instance.new("UIStroke", ball)
ballStroke.Thickness = 3
ballStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ballStroke.LineJoinMode = Enum.LineJoinMode.Round

local hue3 = 0
keepConn(RunService.RenderStepped:Connect(function(dt)
    hue3 = (hue3 + dt * 0.25) % 1
    ballStroke.Color = Color3.fromHSV(hue3, 1, 1)
end))

-- Alternar painel <-> bolinha
local aberto = true
local function alternar()
    aberto = not aberto
    panel.Visible = aberto
    ball.Visible = not aberto
end

toggleBtn.MouseButton1Click:Connect(alternar)
ball.MouseButton1Click:Connect(alternar)

-- Ativar arrastar
makeDraggable(panel)
makeDraggable(ball)

-- Cleanup se rodar de novo
_G.NiriHub.cleanup = function()
    for _, c in ipairs(holder.conns) do
        pcall(function() c:Disconnect() end)
    end
    screenGui:Destroy()
end