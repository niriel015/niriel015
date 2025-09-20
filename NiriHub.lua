-- Niri Hub ⚡ estilo Brutus Hub (menu lateral com páginas e funções básicas)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

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

-- Função pra arrastar painel
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
panel.Size = UDim2.new(0, 700, 0, 450)
panel.Position = UDim2.new(0.15, 0, 0.2, 0)
panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
panel.BackgroundTransparency = 0.3
panel.BorderSizePixel = 0
makeDraggable(panel)

local pc = Instance.new("UICorner", panel)
pc.CornerRadius = UDim.new(0, 12)

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

-- Criar botões
local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 200, 0, 40)
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

-- Funções de páginas
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

local jogPage = createPage("Jogador")
createButton(jogPage, "Velocidade x2", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 32 end
end).Position = UDim2.new(0, 20, 0, 20)
createButton(jogPage, "Pulo Alto", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 100 end
end).Position = UDim2.new(0, 20, 0, 70)
createButton(jogPage, "Resetar", function()
    LocalPlayer:LoadCharacter()
end).Position = UDim2.new(0, 20, 0, 120)

local casasPage = createPage("Casas")
Instance.new("TextLabel", casasPage).Text = "Funções de casas em breve..."

local carrosPage = createPage("Carros")
createButton(carrosPage, "Boost no carro", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.Velocity = char.HumanoidRootPart.Velocity * 5
    end
end).Position = UDim2.new(0, 20, 0, 20)

local trollsPage = createPage("Trolls")
createButton(trollsPage, "Girar sem parar", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        while task.wait(0.1) do
            if not char.Parent then break end
            char.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(30), 0)
        end
    end
end).Position = UDim2.new(0, 20, 0, 20)

local flingsPage = createPage("Flings")
Instance.new("TextLabel", flingsPage).Text = "Funções de fling em breve..."

local audiosPage = createPage("Áudios")
Instance.new("TextLabel", audiosPage).Text = "Funções de áudios em breve..."

local avatarPage = createPage("Avatar")
createButton(avatarPage, "Ficar invisível", function()
    local char = LocalPlayer.Character
    if char then
        for _,v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Transparency = 1
            end
        end
    end
end).Position = UDim2.new(0, 20, 0, 20)

-- Mostrar páginas
local function showPage(name)
    for k,v in pairs(pages) do
        v.Visible = (k == name)
    end
end

-- Botões laterais
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

-- Categorias
local categorias = {"Informações", "Jogador", "Casas", "Carros", "Trolls", "Flings", "Áudios", "Avatar"}
for _, nome in ipairs(categorias) do
    createSidebarButton(nome)
end
showPage("Informações")

-- Bolinha pra abrir/fechar
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

-- Alternar painel <-> bolinha
local aberto = true
local function alternar()
    aberto = not aberto
    panel.Visible = aberto
    ball.Visible = not aberto
end

-- Fechar no canto superior direito
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