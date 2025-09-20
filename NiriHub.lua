-- Niri Hub ⚡ completão estilo Brutus Hub (com nomes na cabeça)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Limpar se já existir
if _G.NiriHub and type(_G.NiriHub.cleanup) == "function" then
    pcall(_G.NiriHub.cleanup)
    task.wait(0.05)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NiriHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local holder = { conns = {} }
_G.NiriHub = { gui = screenGui, holder = holder }
local function keepConn(c) if c then table.insert(holder.conns, c) end end

-- Função pra arrastar
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Painel principal
local panel = Instance.new("Frame", screenGui)
panel.Size = UDim2.new(0, 700, 0, 450)
panel.Position = UDim2.new(0.15, 0, 0.2, 0)
panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
panel.BackgroundTransparency = 0.3
panel.BorderSizePixel = 0
makeDraggable(panel)

local pc = Instance.new("UICorner", panel)
pc.CornerRadius = UDim.new(0, 12)

-- Borda RGB
local stroke = Instance.new("UIStroke", panel)
stroke.Thickness = 4
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.LineJoinMode = Enum.LineJoinMode.Round

local hue = 0
keepConn(RunService.RenderStepped:Connect(function(dt)
    hue = (hue + dt * 0.25) % 1
    stroke.Color = Color3.fromHSV(hue, 1, 1)
end))

-- Título
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "⚡ Niri Hub ⚡"
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextColor3 = Color3.fromRGB(255, 255, 255)

local hue2 = 0
keepConn(RunService.RenderStepped:Connect(function(dt)
    hue2 = (hue2 + dt * 0.3) % 1
    title.TextColor3 = Color3.fromHSV(hue2, 1, 1)
end))

-- Menu lateral
local sidebar = Instance.new("Frame", panel)
sidebar.Size = UDim2.new(0, 160, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sidebar.BackgroundTransparency = 0.2
local sc = Instance.new("UICorner", sidebar)
sc.CornerRadius = UDim.new(0, 8)

local list = Instance.new("UIListLayout", sidebar)
list.Padding = UDim.new(0, 8)
list.FillDirection = Enum.FillDirection.Vertical
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.VerticalAlignment = Enum.VerticalAlignment.Top

-- Área de conteúdo
local content = Instance.new("Frame", panel)
content.Size = UDim2.new(1, -180, 1, -50)
content.Position = UDim2.new(0, 170, 0, 50)
content.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
content.BackgroundTransparency = 0.1
local cc = Instance.new("UICorner", content)
cc.CornerRadius = UDim.new(0, 8)

-- Páginas
local pages = {}
local function createPage(name)
    local page = Instance.new("Frame", content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    pages[name] = page
    return page
end

-- Criar botão de ação
local function createButton(parent, text, callback, posY)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    local bc = Instance.new("UICorner", btn)
    bc.CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

----------------------------------------------------------------
-- Funções para nome na cabeça
local function setHeadTag(player, text, color)
    local char = player.Character or player.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")

    if head:FindFirstChild("NiriTag") then
        head.NiriTag:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NiriTag"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local textLabel = Instance.new("TextLabel", billboard)
    textLabel.Size = UDim2.new(1,0,1,0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0.2
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextScaled = true
end

local function removeHeadTag(player)
    local char = player.Character or player.CharacterAdded:Wait()
    local head = char:FindFirstChild("Head")
    if head and head:FindFirstChild("NiriTag") then
        head.NiriTag:Destroy()
    end
end
----------------------------------------------------------------

-- Página Jogador
local jogPage = createPage("Jogador")
createButton(jogPage, "Velocidade x2", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 32 end
end, 20)

createButton(jogPage, "Pulo Alto", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 100 end
end, 70)

createButton(jogPage, "Resetar", function()
    LocalPlayer:LoadCharacter()
end, 120)

createButton(jogPage, "DONO", function()
    setHeadTag(LocalPlayer, "DONO", Color3.fromRGB(255, 0, 255))
end, 180)

createButton(jogPage, "Sub-DONO", function()
    setHeadTag(LocalPlayer, "Sub-DONO", Color3.fromRGB(150, 50, 255))
end, 230)

-- Caixa de texto + botão Definir Nome
local textBox = Instance.new("TextBox", jogPage)
textBox.Size = UDim2.new(0, 200, 0, 40)
textBox.Position = UDim2.new(0, 20, 0, 280)
textBox.PlaceholderText = "Digite o nome..."
textBox.Text = ""
textBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
textBox.TextColor3 = Color3.new(1,1,1)

local applyBtn = createButton(jogPage, "Definir Nome", function()
    if textBox.Text ~= "" then
        setHeadTag(LocalPlayer, textBox.Text, Color3.fromRGB(255, 255, 0))
    end
end, 330)

createButton(jogPage, "Remover Nome", function()
    removeHeadTag(LocalPlayer)
end, 380)

----------------------------------------------------------------
-- Outras páginas só de exemplo
local infoPage = createPage("Informações")
local infoLabel = Instance.new("TextLabel", infoPage)
infoLabel.Size = UDim2.new(1, -20, 1, -20)
infoLabel.Position = UDim2.new(0, 10, 0, 10)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 20
infoLabel.TextWrapped = true
infoLabel.Text = "Servidor: "..game.JobId.."\nExecutor: Delta\nJogo: "..game.Name

-- Mostrar páginas
local function showPage(name)
    for k,v in pairs(pages) do
        v.Visible = (k == name)
    end
end

-- Botões do menu lateral
local function createSidebarButton(name)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(0, 140, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    local bc = Instance.new("UICorner", btn)
    bc.CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        showPage(name)
    end)
    return btn
end

local categorias = {"Informações", "Jogador"}
for _, nome in ipairs(categorias) do
    createSidebarButton(nome)
end
showPage("Informações")

-- Bolinha abrir/fechar
local ball = Instance.new("TextButton", screenGui)
ball.Size = UDim2.new(0, 60, 0, 60)
ball.Position = UDim2.new(0.05, 0, 0.7, 0)
ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ball.BackgroundTransparency = 0.5
ball.Text = "⚡"
ball.TextSize = 28
ball.Font = Enum.Font.GothamBold
ball.Visible = false
makeDraggable(ball)

local bc2 = Instance.new("UICorner", ball)
bc2.CornerRadius = UDim.new(1, 0)

local ballStroke = Instance.new("UIStroke", ball)
ballStroke.Thickness = 3
ballStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ballStroke.LineJoinMode = Enum.LineJoinMode.Round

local hue3 = 0
keepConn(RunService.RenderStepped:Connect(function(dt)
    hue3 = (hue3 + dt * 0.25) % 1
    ballStroke.Color = Color3.fromHSV(hue3, 1, 1)
end))

local aberto = true
local function alternar()
    aberto = not aberto
    panel.Visible = aberto
    ball.Visible = not aberto
end

local fechar = Instance.new("TextButton", panel)
fechar.Size = UDim2.new(0, 30, 0, 30)
fechar.Position = UDim2.new(1, -40, 0, 5)
fechar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
fechar.TextColor3 = Color3.fromRGB(255, 255, 255)
fechar.Text = "X"
fechar.Font = Enum.Font.GothamBold
fechar.TextSize = 16
local fc = Instance.new("UICorner", fechar)
fc.CornerRadius = UDim.new(0, 6)

fechar.MouseButton1Click:Connect(alternar)
ball.MouseButton1Click:Connect(alternar)

-- Cleanup
_G.NiriHub.cleanup = function()
    for _, c in ipairs(holder.conns) do
        pcall(function() c:Disconnect() end)
    end
    screenGui:Destroy()
end