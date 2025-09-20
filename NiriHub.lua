-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Função para aplicar tag
local function setHeadTag(player, text, color)
    local char = player.Character or player.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")

    -- remove tag antiga
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

-- Função para remover tag
local function removeHeadTag(player)
    local char = player.Character or player.CharacterAdded:Wait()
    local head = char:FindFirstChild("Head")
    if head and head:FindFirstChild("NiriTag") then
        head.NiriTag:Destroy()
    end
end

-- ABA JOGADOR NO PAINEL
local jogadorFrame = Instance.new("Frame")
jogadorFrame.Size = UDim2.new(1, -20, 1, -20)
jogadorFrame.Position = UDim2.new(0, 10, 0, 10)
jogadorFrame.BackgroundTransparency = 1
jogadorFrame.Visible = false -- só aparece quando clicar em "Jogador"
jogadorFrame.Parent = conteudoFrame -- <- substitua pelo frame de conteúdo do seu painel

-- Botão DONO
local donoBtn = Instance.new("TextButton", jogadorFrame)
donoBtn.Size = UDim2.new(0, 180, 0, 40)
donoBtn.Position = UDim2.new(0, 0, 0, 0)
donoBtn.Text = "Colocar DONO"
donoBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
donoBtn.TextColor3 = Color3.new(1,1,1)
donoBtn.MouseButton1Click:Connect(function()
    setHeadTag(LocalPlayer, "DONO", Color3.fromRGB(255, 0, 255))
end)

-- Botão Sub-DONO
local subBtn = Instance.new("TextButton", jogadorFrame)
subBtn.Size = UDim2.new(0, 180, 0, 40)
subBtn.Position = UDim2.new(0, 0, 0, 50)
subBtn.Text = "Colocar Sub-DONO"
subBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 255)
subBtn.TextColor3 = Color3.new(1,1,1)
subBtn.MouseButton1Click:Connect(function()
    setHeadTag(LocalPlayer, "Sub-DONO", Color3.fromRGB(150, 50, 255))
end)

-- Campo + Botão Nome Custom
local textBox = Instance.new("TextBox", jogadorFrame)
textBox.Size = UDim2.new(0, 180, 0, 40)
textBox.Position = UDim2.new(0, 0, 0, 100)
textBox.PlaceholderText = "Digite o nome"
textBox.Text = ""
textBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
textBox.TextColor3 = Color3.new(1,1,1)

local applyBtn = Instance.new("TextButton", jogadorFrame)
applyBtn.Size = UDim2.new(0, 180, 0, 40)
applyBtn.Position = UDim2.new(0, 0, 0, 150)
applyBtn.Text = "Definir Nome"
applyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
applyBtn.TextColor3 = Color3.new(1,1,1)
applyBtn.MouseButton1Click:Connect(function()
    if textBox.Text ~= "" then
        setHeadTag(LocalPlayer, textBox.Text, Color3.fromRGB(255, 255, 0))
    end
end)

-- Botão Remover
local removeBtn = Instance.new("TextButton", jogadorFrame)
removeBtn.Size = UDim2.new(0, 180, 0, 40)
removeBtn.Position = UDim2.new(0, 0, 0, 200)
removeBtn.Text = "Remover Nome"
removeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
removeBtn.TextColor3 = Color3.new(1,1,1)
removeBtn.MouseButton1Click:Connect(function()
    removeHeadTag(LocalPlayer)
end)