-- Niri Hub ⚡ — Versão FINAL (Completo, otimizado e seguro: ações somente locais)
-- Cole inteiro no executor. Tudo client-side; NÃO manipula outros jogadores.

-- ====== CONFIG / SERVICES ======
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- ====== CLEANUP if re-run ======
if _G.NiriHub and type(_G.NiriHub.cleanup) == "function" then
    pcall(function() _G.NiriHub.cleanup() end)
    task.wait(0.05)
end

-- container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NiriHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- global holder for cleanup
local holder = { conns = {} }
_G.NiriHub = { gui = screenGui, holder = holder }

local function keepConn(c)
    if c then table.insert(holder.conns, c) end
end
local function disconnectAll()
    for _,c in ipairs(holder.conns) do
        pcall(function() c:Disconnect() end)
    end
    holder.conns = {}
end

-- safe helpers
local function clamp(n,a,b) return math.max(a, math.min(b, n)) end
local function safeWaitForChild(parent, name, timeout)
    timeout = timeout or 5
    local t0 = time()
    while time() - t0 < timeout do
        local v = parent:FindFirstChild(name)
        if v then return v end
        task.wait(0.03)
    end
    return parent:FindFirstChild(name)
end

local function findPlayerByName(query)
    if not query or query == "" then return nil end
    local q = query:lower()
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(q) or (p.DisplayName and p.DisplayName:lower():find(q)) then
            return p
        end
    end
    return nil
end

-- ====== UI BUILD ======
local root = Instance.new("Frame", screenGui)
root.Name = "Root"
root.Size = UDim2.new(0, 920, 0, 560)
root.Position = UDim2.new(0.06,0,0.06,0)
root.BackgroundColor3 = Color3.fromRGB(23,23,27)
root.BorderSizePixel = 0
root.ClipsDescendants = true
local rc = Instance.new("UICorner", root); rc.CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke", root); stroke.Color = Color3.fromRGB(40,40,45); stroke.Transparency = 0.75
root.Active = true
root.Visible = true

-- top bar
local topBar = Instance.new("Frame", root)
topBar.Size = UDim2.new(1,0,0,60)
topBar.Position = UDim2.new(0,0,0,0)
topBar.BackgroundColor3 = Color3.fromRGB(34,34,40)
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -320, 1, 0); title.Position = UDim2.new(0,20,0,0)
title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize = 20
title.Text = "⚡  Niri Hub"; title.TextColor3 = Color3.fromRGB(245,245,245); title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0,44,0,36); closeBtn.Position = UDim2.new(1, -64, 0, 12)
closeBtn.Text = "—"; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 22
closeBtn.BackgroundColor3 = Color3.fromRGB(170,60,60); closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)

local expandBtn = Instance.new("TextButton", topBar)
expandBtn.Size = UDim2.new(0,36,0,36); expandBtn.Position = UDim2.new(1, -108, 0, 12)
expandBtn.Text = "🔼"; expandBtn.Font = Enum.Font.GothamBold; expandBtn.TextSize = 20
expandBtn.BackgroundColor3 = Color3.fromRGB(90,44,150); expandBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", expandBtn).CornerRadius = UDim.new(0,8)

-- scale slider
local scaleContainer = Instance.new("Frame", topBar)
scaleContainer.Size = UDim2.new(0,180,0,32); scaleContainer.Position = UDim2.new(1, -320, 0, 14); scaleContainer.BackgroundTransparency = 1
local scaleLabel = Instance.new("TextLabel", scaleContainer)
scaleLabel.Size = UDim2.new(0,44,1,0); scaleLabel.Position = UDim2.new(0,0,0,0)
scaleLabel.BackgroundTransparency = 1; scaleLabel.Font = Enum.Font.Gotham; scaleLabel.TextSize = 14; scaleLabel.Text = "Tamanho"; scaleLabel.TextColor3 = Color3.fromRGB(220,220,220)
local sliderBar = Instance.new("Frame", scaleContainer); sliderBar.Size = UDim2.new(0,110,0,8); sliderBar.Position = UDim2.new(0,56,0,12); sliderBar.BackgroundColor3 = Color3.fromRGB(60,60,66)
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0,6)
local thumb = Instance.new("Frame", sliderBar); thumb.Size = UDim2.new(0,16,1,0); thumb.Position = UDim2.new(0.8,-8,0,0); thumb.BackgroundColor3 = Color3.fromRGB(200,200,200)
Instance.new("UICorner", thumb).CornerRadius = UDim.new(0,6)

-- left menu
local menu = Instance.new("Frame", root)
menu.Size = UDim2.new(0, 220, 1, -84); menu.Position = UDim2.new(0, 16, 0, 68)
menu.BackgroundColor3 = Color3.fromRGB(18,18,22)
Instance.new("UICorner", menu).CornerRadius = UDim.new(0,10)
local logo = Instance.new("TextLabel", menu)
logo.Size = UDim2.new(1, -28, 0, 48); logo.Position = UDim2.new(0,14,0,10)
logo.BackgroundTransparency = 1; logo.Text = "Niri Hub"; logo.Font = Enum.Font.GothamBold; logo.TextSize = 20; logo.TextColor3 = Color3.fromRGB(255,255,255); logo.TextXAlignment = Enum.TextXAlignment.Left

-- content area
local content = Instance.new("Frame", root)
content.Size = UDim2.new(1, -268, 1, -84); content.Position = UDim2.new(0, 244, 0, 68)
content.BackgroundColor3 = Color3.fromRGB(28,28,32)
Instance.new("UICorner", content).CornerRadius = UDim.new(0,10)

local contentTitle = Instance.new("TextLabel", content)
contentTitle.Size = UDim2.new(1, -24, 0, 40); contentTitle.Position = UDim2.new(0,12,0,12)
contentTitle.BackgroundTransparency = 1; contentTitle.Font = Enum.Font.GothamBold; contentTitle.TextSize = 18; contentTitle.TextColor3 = Color3.fromRGB(245,245,245)
contentTitle.Text = "Informações"

local contentHolder = Instance.new("Frame", content)
contentHolder.Size = UDim2.new(1, -24, 1, -64); contentHolder.Position = UDim2.new(0,12,0,56); contentHolder.BackgroundTransparency = 1

-- ray icon (floating)
local ray = Instance.new("TextButton", screenGui)
ray.Name = "RayIcon"; ray.Size = UDim2.new(0,64,0,64); ray.Position = UDim2.new(0.04,0,0.78,0)
ray.Text = "⚡"; ray.Font = Enum.Font.GothamBold; ray.TextSize = 32; ray.BackgroundColor3 = Color3.fromRGB(60,60,60); ray.TextColor3 = Color3.fromRGB(255,255,255)
ray.Active = true; ray.Draggable = true
Instance.new("UICorner", ray).CornerRadius = UDim.new(0,32)

-- tabs
local tabNames = {"Informações","Jogador","Casas","Carros","Poderes","Jogadores","Flings","Áudios","Avatar"}
local pages = {}
local selectedBtn = nil
local function makeMenuButton(text, y)
    local b = Instance.new("TextButton", menu)
    b.Size = UDim2.new(1, -28, 0, 40); b.Position = UDim2.new(0,14,0,y)
    b.BackgroundColor3 = Color3.fromRGB(34,34,38); b.Text = text; b.Font = Enum.Font.Gotham; b.TextSize = 15; b.TextColor3 = Color3.fromRGB(220,220,220)
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", b).Color = Color3.fromRGB(45,45,50)
    return b
end

for i,name in ipairs(tabNames) do
    local btn = makeMenuButton(name, 74 + (i-1)*46)
    local page = Instance.new("Frame", contentHolder)
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false
    pages[name] = page
    btn.MouseButton1Click:Connect(function()
        if selectedBtn then selectedBtn.BackgroundColor3 = Color3.fromRGB(34,34,38) end
        btn.BackgroundColor3 = Color3.fromRGB(90,44,150)
        selectedBtn = btn
        for k,v in pairs(pages) do v.Visible = (k==name) end
        contentTitle.Text = name
    end)
    if i==1 then
        btn.BackgroundColor3 = Color3.fromRGB(90,44,150)
        selectedBtn = btn
        page.Visible = true
        contentTitle.Text = name
    end
end

-- =============================
-- Informações page (player count only)
-- =============================
do
    local page = pages["Informações"]
    local lbl = Instance.new("TextLabel", page)
    lbl.Size = UDim2.new(1,-10,1,-10); lbl.Position = UDim2.new(0,5,0,5); lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Top; lbl.TextWrapped = true
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 16; lbl.TextColor3 = Color3.fromRGB(230,230,230)
    local function refresh()
        lbl.Text = string.format("👥 Jogadores: %d\n\nObservação: ações aqui são locais/no seu cliente.", #Players:GetPlayers())
    end
    refresh()
    keepConn(Players.PlayerAdded:Connect(refresh)); keepConn(Players.PlayerRemoving:Connect(refresh))
end

-- =============================
-- Jogador page (Nome RGB local + copiar roupa local + local teleport to player)
-- =============================
do
    local page = pages["Jogador"]

    -- Target input
    local lblTarget = Instance.new("TextLabel", page)
    lblTarget.Size = UDim2.new(0,80,0,24); lblTarget.Position = UDim2.new(0,12,0,12)
    lblTarget.BackgroundTransparency = 1; lblTarget.Font = Enum.Font.Gotham; lblTarget.TextColor3 = Color3.fromRGB(220,220,220); lblTarget.Text = "Alvo:"

    local targetBox = Instance.new("TextBox", page)
    targetBox.Size = UDim2.new(0,320,0,30); targetBox.Position = UDim2.new(0,100,0,10)
    targetBox.PlaceholderText = "nick ou display (referência local)"; targetBox.BackgroundColor3 = Color3.fromRGB(40,40,44); targetBox.TextColor3 = Color3.fromRGB(255,255,255)

    -- Teleport self to target (local)
    local tpBtn = Instance.new("TextButton", page)
    tpBtn.Size = UDim2.new(0,200,0,36); tpBtn.Position = UDim2.new(0,12,0,56); tpBtn.Text = "Ir p/ Alvo (local)"; tpBtn.Font = Enum.Font.GothamSemibold; tpBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    tpBtn.MouseButton1Click:Connect(function()
        local p = findPlayerByName(targetBox.Text)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local myhrp = safeWaitForChild(LocalPlayer.Character, "HumanoidRootPart", 2)
            if myhrp then pcall(function() myhrp.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3) end) end
        else warn("Alvo não encontrado ou sem character.") end
    end)

    -- Copy clothes local
    local copyBtn = Instance.new("TextButton", page)
    copyBtn.Size = UDim2.new(0,200,0,36); copyBtn.Position = UDim2.new(0,230,0,56); copyBtn.Text = "Copiar roupa (local)"
    copyBtn.Font = Enum.Font.GothamSemibold; copyBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)
    copyBtn.MouseButton1Click:Connect(function()
        local p = findPlayerByName(targetBox.Text)
        if not p or not p.Character then warn("Alvo inválido"); return end
        local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        -- backup current clothes (optional) - store as tags on _G if desired (not persistent)
        for _,v in ipairs(myChar:GetChildren()) do
            if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then pcall(function() v:Destroy() end) end
            if v:IsA("Accessory") then pcall(function() v:Destroy() end) end
        end
        for _,v in ipairs(p.Character:GetChildren()) do
            if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
                pcall(function() v:Clone().Parent = myChar end)
            end
            if v:IsA("Accessory") then
                local ok, cl = pcall(function() return v:Clone() end)
                if ok and cl then
                    cl.Parent = myChar
                    pcall(function()
                        local mh = myChar:FindFirstChildOfClass("Humanoid")
                        if mh and mh.AddAccessory then mh:AddAccessory(cl) end
                    end)
                end
            end
        end
        warn("Roupas copiadas localmente.")
    end)

    -- Local RGB name (Billboard on you)
    local nameLabel = Instance.new("TextLabel", page)
    nameLabel.Size = UDim2.new(0,80,0,24); nameLabel.Position = UDim2.new(0,12,0,110)
    nameLabel.BackgroundTransparency = 1; nameLabel.Font = Enum.Font.Gotham; nameLabel.TextColor3 = Color3.fromRGB(220,220,220); nameLabel.Text = "Seu nome:"

    local nameInput = Instance.new("TextBox", page)
    nameInput.Size = UDim2.new(0,320,0,32); nameInput.Position = UDim2.new(0,100,0,108)
    nameInput.PlaceholderText = "Ex: DONO"; nameInput.BackgroundColor3 = Color3.fromRGB(40,40,44); nameInput.TextColor3 = Color3.fromRGB(255,255,255)

    local nameToggle = Instance.new("TextButton", page)
    nameToggle.Size = UDim2.new(0,140,0,36); nameToggle.Position = UDim2.new(0,440,0,108)
    nameToggle.Text = "Ativar Nome RGB"; nameToggle.Font = Enum.Font.GothamSemibold; nameToggle.BackgroundColor3 = Color3.fromRGB(80,160,80)

    local currBillboard, currConn, currText = nil, nil, nil
    local function createNameBill(text)
        pcall(function() if currBillboard then currBillboard:Destroy() end end)
        if currConn then currConn:Disconnect(); currConn = nil end
        currText = tostring(text or LocalPlayer.Name)
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local head = safeWaitForChild(char, "Head", 4)
        if not head then return end
        local billboard = Instance.new("BillboardGui", char)
        billboard.Name = "NiriNameLocal"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0,220,0,52)
        billboard.StudsOffset = Vector3.new(0,3.2,0)
        billboard.AlwaysOnTop = true
        local f = Instance.new("Frame", billboard); f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3 = Color3.fromRGB(255,255,255)
        Instance.new("UICorner", f).CornerRadius = UDim.new(0,12)
        local stroke = Instance.new("UIStroke", f); stroke.Thickness = 3; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local lbl = Instance.new("TextLabel", f); lbl.Size = UDim2.new(1,-10,1,0); lbl.Position = UDim2.new(0,5,0,0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 18; lbl.Text = currText; lbl.TextColor3 = Color3.fromRGB(18,18,18)
        currConn = RunService.Heartbeat:Connect(function()
            if not stroke.Parent then return end
            local t = time() * 1.5
            local r = math.sin(t) * 127 + 128
            local g = math.sin(t + 2) * 127 + 128
            local b = math.sin(t + 4) * 127 + 128
            stroke.Color = Color3.fromRGB(clamp(r,0,255), clamp(g,0,255), clamp(b,0,255))
        end)
        currBillboard = billboard
    end

    nameToggle.MouseButton1Click:Connect(function()
        if currBillboard then
            pcall(function() currBillboard:Destroy() end)
            if currConn then currConn:Disconnect(); currConn = nil end
            currBillboard = nil; currConn = nil; currText = nil
            nameToggle.Text = "Ativar Nome RGB"; nameToggle.BackgroundColor3 = Color3.fromRGB(80,160,80)
            return
        end
        local txt = (nameInput.Text ~= "" and nameInput.Text) or LocalPlayer.Name
        createNameBill(txt)
        nameToggle.Text = "Desativar Nome RGB"; nameToggle.BackgroundColor3 = Color3.fromRGB(160,60,60)
    end)

    -- persist across respawn
    keepConn(LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.8)
        if currText then pcall(function() createNameBill(currText) end) end
    end))
end

-- =============================
-- Casas page (safe detection + local teleport to plot)
-- =============================
do
    local page = pages["Casas"]
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1,-24,0,24); title.Position = UDim2.new(0,12,0,12)
    title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize = 14; title.TextColor3 = Color3.fromRGB(230,230,230)
    title.Text = "Casas (Brookhaven) - varredura segura"

    local refreshBtn = Instance.new("TextButton", page)
    refreshBtn.Size = UDim2.new(0,140,0,36); refreshBtn.Position = UDim2.new(1,-156,0,12)
    refreshBtn.Text = "Atualizar lista (seguro)"; refreshBtn.Font = Enum.Font.GothamSemibold; refreshBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)

    local scroll = Instance.new("ScrollingFrame", page); scroll.Size = UDim2.new(1,-24,1,-72); scroll.Position = UDim2.new(0,12,0,52); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 6
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0,8)

    local function detectPlotsSafe()
        local candidates = {}
        local children = Workspace:GetChildren()
        -- look for obvious containers
        for _,c in ipairs(children) do
            local n = c.Name:lower()
            if n == "plots" or n == "houses" or n:find("house") then
                for i=1, math.min(80, #c:GetChildren()) do
                    local m = c:GetChildren()[i]
                    if m and m:IsA("Model") then table.insert(candidates, m) end
                end
            end
        end
        -- fallback: sample limited top-level models
        if #candidates == 0 then
            for i=1, math.min(60, #children) do
                local c = children[i]
                if c and c:IsA("Model") then table.insert(candidates, c) end
            end
        end
        return candidates
    end

    local function clearList()
        for _,ch in ipairs(scroll:GetChildren()) do if not ch:IsA("UIListLayout") then ch:Destroy() end end
    end

    local function buildList()
        clearList()
        local plots = detectPlotsSafe()
        if #plots == 0 then
            local none = Instance.new("TextLabel", scroll)
            none.Size = UDim2.new(1,-20,0,36); none.Position = UDim2.new(0,10,0,10)
            none.BackgroundTransparency = 1; none.Font = Enum.Font.Gotham; none.TextSize = 14; none.TextColor3 = Color3.fromRGB(200,200,200)
            none.Text = "Nenhuma casa/plot detectada automaticamente (varredura segura)."
            scroll.CanvasSize = UDim2.new(0,0,0,60)
            return
        end
        for i,plot in ipairs(plots) do
            local entry = Instance.new("Frame", scroll); entry.Size = UDim2.new(1,-20,0,72); entry.BackgroundColor3 = Color3.fromRGB(36,36,40)
            Instance.new("UICorner", entry).CornerRadius = UDim.new(0,8)
            local lbl = Instance.new("TextLabel", entry); lbl.Size = UDim2.new(0.6,-10,1,0); lbl.Position = UDim2.new(0,10,0,0)
            lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 14; lbl.TextColor3 = Color3.fromRGB(230,230,230)
            lbl.Text = tostring(plot.Name)

            local infoBtn = Instance.new("TextButton", entry); infoBtn.Size = UDim2.new(0,100,0,28); infoBtn.Position = UDim2.new(1,-110,0,8)
            infoBtn.Text = "Ver Info"; infoBtn.Font = Enum.Font.GothamSemibold; infoBtn.BackgroundColor3 = Color3.fromRGB(60,120,60)
            infoBtn.MouseButton1Click:Connect(function() warn("Plot:", plot.Name, "Parts:", #plot:GetDescendants()) end)

            local tpBtn = Instance.new("TextButton", entry); tpBtn.Size = UDim2.new(0,100,0,28); tpBtn.Position = UDim2.new(1,-110,0,36)
            tpBtn.Text = "Ir p/ Casa"; tpBtn.Font = Enum.Font.GothamSemibold; tpBtn.BackgroundColor3 = Color3.fromRGB(80,80,160)
            tpBtn.MouseButton1Click:Connect(function()
                local dest = plot.PrimaryPart or plot:FindFirstChildWhichIsA("BasePart")
                if dest then
                    local hrp = safeWaitForChild(LocalPlayer.Character, "HumanoidRootPart", 2)
                    if hrp then pcall(function() hrp.CFrame = dest.CFrame * CFrame.new(0,1,0) end) end
                else warn("Destino não encontrado (varredura segura).") end
            end)
        end
        scroll.CanvasSize = UDim2.new(0,0,0, #plots * 82)
    end

    refreshBtn.MouseButton1Click:Connect(buildList)
    task.defer(buildList)
end

-- =============================
-- Carros page (local sound + local color + limited search)
-- =============================
do
    local page = pages["Carros"]
    local info = Instance.new("TextLabel", page); info.Size = UDim2.new(1,-24,0,24); info.Position = UDim2.new(0,12,0,12); info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham; info.TextSize = 14; info.TextColor3 = Color3.fromRGB(220,220,220); info.Text = "Controle de veículo próximo (local)"

    local findBtn = Instance.new("TextButton", page); findBtn.Size = UDim2.new(0,160,0,36); findBtn.Position = UDim2.new(0,12,0,52); findBtn.Text = "Encontrar Veículo (local)"
    local foundLabel = Instance.new("TextLabel", page); foundLabel.Size = UDim2.new(0,520,0,36); foundLabel.Position = UDim2.new(0,188,0,52); foundLabel.BackgroundTransparency = 1; foundLabel.Font = Enum.Font.Gotham; foundLabel.TextColor3 = Color3.fromRGB(220,220,220); foundLabel.Text = "Nenhum veículo selecionado"

    local function findNearestVehicleSafe(maxRange)
        maxRange = maxRange or 120
        local myChar = LocalPlayer.Character
        if not myChar or not myChar.PrimaryPart then return nil end
        local myPos = myChar.PrimaryPart.Position
        local nearest, nd = nil, 1e9
        local cnt = 0
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if cnt > 250 then break end
            cnt = cnt + 1
            if obj:IsA("VehicleSeat") or (obj:IsA("Model") and (obj.Name:lower():find("vehicle") or obj.Name:lower():find("car"))) then
                local model = obj:IsA("VehicleSeat") and obj.Parent or obj
                if model.PrimaryPart then
                    local d = (model.PrimaryPart.Position - myPos).Magnitude
                    if d < nd and d <= maxRange then nd = d; nearest = model end
                end
            end
        end
        return nearest
    end

    local selectedVehicle = nil
    findBtn.MouseButton1Click:Connect(function()
        local v = findNearestVehicleSafe(120)
        if v then selectedVehicle = v; foundLabel.Text = "Selecionado: "..(v.Name or "Veículo") else foundLabel.Text = "Nenhum veículo próximo encontrado" end
    end)

    local soundBox = Instance.new("TextBox", page); soundBox.Size = UDim2.new(0,260,0,32); soundBox.Position = UDim2.new(0,12,0,108); soundBox.PlaceholderText = "ID da música (números)"
    local playBtn = Instance.new("TextButton", page); playBtn.Size = UDim2.new(0,100,0,32); playBtn.Position = UDim2.new(0,288,0,108); playBtn.Text = "Tocar (local)"
    local currentSound = nil
    playBtn.MouseButton1Click:Connect(function()
        if not selectedVehicle then warn("Selecione veículo primeiro (local)"); return end
        local id = tostring(soundBox.Text or "")
        if id == "" then warn("Digite ID"); return end
        local parent = selectedVehicle.PrimaryPart or selectedVehicle:FindFirstChildWhichIsA("BasePart") or selectedVehicle
        if currentSound then pcall(function() currentSound:Stop(); currentSound:Destroy() end); currentSound = nil end
        local s = Instance.new("Sound", parent); s.Name = "NiriCarSound"; s.Looped = true; s.SoundId = "rbxassetid://"..id
        pcall(function() s:Play() end)
        currentSound = s
    end)

    local rBox = Instance.new("TextBox", page); rBox.Size = UDim2.new(0,80,0,32); rBox.Position = UDim2.new(0,12,0,156); rBox.PlaceholderText = "R"
    local gBox = Instance.new("TextBox", page); gBox.Size = UDim2.new(0,80,0,32); gBox.Position = UDim2.new(0,100,0,156); gBox.PlaceholderText = "G"
    local bBox = Instance.new("TextBox", page); bBox.Size = UDim2.new(0,80,0,32); bBox.Position = UDim2.new(0,188,0,156); bBox.PlaceholderText = "B"
    local colorBtn = Instance.new("TextButton", page); colorBtn.Size = UDim2.new(0,140,0,32); colorBtn.Position = UDim2.new(0,276,0,156); colorBtn.Text = "Aplicar Cor (local)"
    colorBtn.MouseButton1Click:Connect(function()
        if not selectedVehicle then warn("Selecione veículo primeiro (local)"); return end
        local r,g,b = tonumber(rBox.Text), tonumber(gBox.Text), tonumber(bBox.Text)
        if not r or not g or not b then warn("RGB inválido"); return end
        r,g,b = clamp(r,0,255), clamp(g,0,255), clamp(b,0,255)
        for _,part in ipairs(selectedVehicle:GetDescendants()) do
            if part:IsA("BasePart") then pcall(function() part.Color = Color3.fromRGB(r,g,b) end) end
        end
        warn("Cor aplicada localmente (pode não replicar).")
    end)
end

-- =============================
-- Poderes page (local Fly / Speed / Jump / Noclip) — careful: may be detected on some servers
-- =============================
do
    local page = pages["Poderes"]
    local info = Instance.new("TextLabel", page); info.Size = UDim2.new(1,-24,0,24); info.Position = UDim2.new(0,12,0,12); info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham; info.TextSize = 14; info.TextColor3 = Color3.fromRGB(220,220,220)
    info.Text = "Poderes (APENAS LOCAIS). Podem ser detectados por anticheats."

    -- Fly
    local flyBtn = Instance.new("TextButton", page); flyBtn.Size = UDim2.new(0,160,0,36); flyBtn.Position = UDim2.new(0,12,0,52); flyBtn.Text = "Fly: OFF"; flyBtn.Font = Enum.Font.GothamSemibold
    local flying = false; local flyVel, flyGyro, flyConn = nil, nil, nil
    local flySpeed = 80
    flyBtn.MouseButton1Click:Connect(function()
        if flying then
            flying = false
            pcall(function() if flyVel then flyVel:Destroy() end end)
            pcall(function() if flyGyro then flyGyro:Destroy() end end)
            if flyConn then flyConn:Disconnect(); flyConn=nil end
            flyBtn.Text = "Fly: OFF"
            return
        end
        local char = LocalPlayer.Character
        if not char then warn("Character não pronto"); return end
        local hrp = safeWaitForChild(char, "HumanoidRootPart", 2)
        if not hrp then warn("HRP não encontrado"); return end
        flyVel = Instance.new("BodyVelocity", hrp); flyVel.MaxForce = Vector3.new(1e5,1e5,1e5); flyVel.Velocity = Vector3.new(0,0,0)
        flyGyro = Instance.new("BodyGyro", hrp); flyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5); flyGyro.D = 10
        flying = true; flyBtn.Text = "Fly: ON"
        flyConn = RunService.Heartbeat:Connect(function()
            if not flying or not hrp then return end
            local cam = workspace.CurrentCamera
            local move = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + (cam.CFrame.LookVector) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - (cam.CFrame.LookVector) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - (cam.CFrame.RightVector) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + (cam.CFrame.RightVector) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
            local vel = (move.Magnitude > 0) and (move.Unit * flySpeed) or Vector3.new(0,0,0)
            pcall(function() if flyVel then flyVel.Velocity = vel end; if flyGyro then flyGyro.CFrame = workspace.CurrentCamera.CFrame end end)
        end)
        keepConn(flyConn)
    end)

    -- Speed
    local speedBox = Instance.new("TextBox", page); speedBox.Size = UDim2.new(0,120,0,32); speedBox.Position = UDim2.new(0,12,0,110); speedBox.PlaceholderText = "WalkSpeed"
    local speedBtn = Instance.new("TextButton", page); speedBtn.Size = UDim2.new(0,120,0,32); speedBtn.Position = UDim2.new(0,144,0,110); speedBtn.Text = "Aplicar Speed"
    speedBtn.MouseButton1Click:Connect(function()
        local v = tonumber(speedBox.Text); if not v then warn("Speed inválida"); return end
        local char = LocalPlayer.Character; if not char then warn("Character não encontrado"); return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then pcall(function() humanoid.WalkSpeed = v end); warn("WalkSpeed aplicado (local).") end
    end)

    -- Jump
    local jumpBox = Instance.new("TextBox", page); jumpBox.Size = UDim2.new(0,120,0,32); jumpBox.Position = UDim2.new(0,12,0,156); jumpBox.PlaceholderText = "JumpPower"
    local jumpBtn = Instance.new("TextButton", page); jumpBtn.Size = UDim2.new(0,120,0,32); jumpBtn.Position = UDim2.new(0,144,0,156); jumpBtn.Text = "Aplicar Jump"
    jumpBtn.MouseButton1Click:Connect(function()
        local v = tonumber(jumpBox.Text); if not v then warn("Jump inválido"); return end
        local char = LocalPlayer.Character; if not char then warn("Character não encontrado"); return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then pcall(function() humanoid.JumpPower = v end); warn("JumpPower aplicado (local).") end
    end)

    -- Noclip (local)
    local noclipBtn = Instance.new("TextButton", page); noclipBtn.Size = UDim2.new(0,160,0,36); noclipBtn.Position = UDim2.new(0,12,0,204); noclipBtn.Text = "Noclip: OFF"
    local noclipOn = false; local noclipConn = nil
    noclipBtn.MouseButton1Click:Connect(function()
        noclipOn = not noclipOn
        if not noclipOn then
            noclipBtn.Text = "Noclip: OFF"
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            local c = LocalPlayer.Character
            if c then for _,part in ipairs(c:GetDescendants()) do if part:IsA("BasePart") then pcall(function() part.CanCollide = true end) end end end
            return
        end
        noclipBtn.Text = "Noclip: ON"
        noclipConn = RunService.Stepped:Connect(function()
            local c = LocalPlayer.Character
            if c then
                for _,part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
                end
            end
        end)
        keepConn(noclipConn)
    end)
end

-- =============================
-- Jogadores page (list + safe local teleport to player)
-- =============================
do
    local page = pages["Jogadores"]
    local title = Instance.new("TextLabel", page); title.Size = UDim2.new(1,-24,0,28); title.Position = UDim2.new(0,12,0,12); title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold; title.TextSize = 14; title.TextColor3 = Color3.fromRGB(230,230,230); title.Text = "Jogadores no mapa"

    local refreshBtn = Instance.new("TextButton", page); refreshBtn.Size = UDim2.new(0,140,0,34); refreshBtn.Position = UDim2.new(1,-156,0,10); refreshBtn.Text = "Atualizar"; refreshBtn.Font = Enum.Font.GothamSemibold; refreshBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    local scroll = Instance.new("ScrollingFrame", page); scroll.Size = UDim2.new(1,-24,1,-64); scroll.Position = UDim2.new(0,12,0,52); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 6
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0,8)

    local function build()
        for _,c in ipairs(scroll:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            local entry = Instance.new("Frame", scroll); entry.Size = UDim2.new(1,-24,0,56); entry.BackgroundColor3 = Color3.fromRGB(36,36,40)
            Instance.new("UICorner", entry).CornerRadius = UDim.new(0,8)
            local lbl = Instance.new("TextLabel", entry); lbl.Size = UDim2.new(0.5,-10,1,0); lbl.Position = UDim2.new(0,10,0,0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 14; lbl.TextColor3 = Color3.fromRGB(230,230,230)
            lbl.Text = p.Name.." ("..(p.DisplayName or "")..")"

            local infoBtn = Instance.new("TextButton", entry); infoBtn.Size = UDim2.new(0,92,0,28); infoBtn.Position = UDim2.new(1,-104,0,8); infoBtn.Text = "Info"; infoBtn.Font = Enum.Font.GothamSemibold; infoBtn.BackgroundColor3 = Color3.fromRGB(150,60,60)
            infoBtn.MouseButton1Click:Connect(function() warn("Jogador:", p.Name, "UserId:", p.UserId) end)

            local tpBtn = Instance.new("TextButton", entry); tpBtn.Size = UDim2.new(0,92,0,28); tpBtn.Position = UDim2.new(1,-104,0,32); tpBtn.Text = "Ir p/ ele (local)"; tpBtn.Font = Enum.Font.GothamSemibold; tpBtn.BackgroundColor3 = Color3.fromRGB(80,120,200)
            tpBtn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local myhrp = safeWaitForChild(LocalPlayer.Character, "HumanoidRootPart", 2)
                    if myhrp then pcall(function() myhrp.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3) end) end
                else warn("Alvo sem character.") end
            end)
        end
        scroll.CanvasSize = UDim2.new(0,0,0, #Players:GetPlayers()*66)
    end

    build()
    keepConn(Players.PlayerAdded:Connect(build)); keepConn(Players.PlayerRemoving:Connect(build))
    refreshBtn.MouseButton1Click:Connect(build)
end

-- =============================
-- Flings / Áudios / Avatar pages (placeholders + local utilities)
-- =============================
do
    -- Flings (placeholder)
    local p = pages["Flings"]
    local l = Instance.new("TextLabel", p)
    l.Size = UDim2.new(1,-24,1,-24); l.Position = UDim2.new(0,12,0,12); l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham; l.TextSize = 14; l.TextColor3 = Color3.fromRGB(220,220,220)
    l.Text = "Flings: placeholder seguro. Não contém ações que afetem outros jogadores."

    -- Áudios (local sound manager)
    local a = pages["Áudios"]
    local la = Instance.new("TextLabel", a); la.Size = UDim2.new(1,-24,0,24); la.Position = UDim2.new(0,12,0,12); la.BackgroundTransparency = 1
    la.Font = Enum.Font.Gotham; la.TextSize = 14; la.TextColor3 = Color3.fromRGB(220,220,220); la.Text = "Áudios locais: adicione IDs e reproduza no seu cliente."
    local audioBox = Instance.new("TextBox", a); audioBox.Size = UDim2.new(0,260,0,32); audioBox.Position = UDim2.new(0,12,0,52); audioBox.PlaceholderText = "ID da música"; audioBox.BackgroundColor3 = Color3.fromRGB(40,40,44)
    local playBtn = Instance.new("TextButton", a); playBtn.Size = UDim2.new(0,100,0,32); playBtn.Position = UDim2.new(0,280,0,52); playBtn.Text = "Tocar (local)"
    local current = nil
    playBtn.MouseButton1Click:Connect(function()
        local id = tostring(audioBox.Text or "")
        if id == "" then warn("Digite ID"); return end
        if current then pcall(function() current:Stop(); current:Destroy() end); current = nil end
        local s = Instance.new("Sound", workspace) s.SoundId = "rbxassetid://"..id s.Looped = true
        pcall(function() s:Play() end)
        current = s
    end)

    -- Avatar placeholder
    local av = pages["Avatar"]
    local avl = Instance.new("TextLabel", av); avl.Size = UDim2.new(1,-24,1,-24); avl.Position = UDim2.new(0,12,0,12); avl.BackgroundTransparency = 1
    avl.Font = Enum.Font.Gotham; avl.TextSize = 14; avl.TextColor3 = Color3.fromRGB(220,220,220)
    avl.Text = "Avatar: trocas locais (placeholder)."
end

-- =============================
-- Ray & Toggles & Slider behavior
-- =============================
ray.MouseButton1Click:Connect(function() root.Visible = not root.Visible end)
closeBtn.MouseButton1Click:Connect(function() root.Visible = false end)

local expanded = true
expandBtn.MouseButton1Click:Connect(function()
    expanded = not expanded
    if expanded then
        expandBtn.Text = "🔼"
        TweenService:Create(root, TweenInfo.new(0.25), {Size = UDim2.new(0, 920, 0, 560)}):Play()
    else
        expandBtn.Text = "🔽"
        TweenService:Create(root, TweenInfo.new(0.25), {Size = UDim2.new(0, 920, 0, 300)}):Play()
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Escape then root.Visible = not root.Visible end
end)

-- Slider logic
local dragging = false
local startPos, startOffset
local sliderMin = 0.6; local sliderMax = 1.5
thumb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; startPos = input.Position; startOffset = thumb.Position.X.Offset
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position.X - startPos.X
        local newOff = startOffset + delta
        local maxOff = math.max(0, sliderBar.AbsoluteSize.X - thumb.AbsoluteSize.X)
        newOff = clamp(newOff, 0, maxOff)
        thumb.Position = UDim2.new(0, newOff, 0, 0)
        local rel = (maxOff == 0) and 0 or (newOff / maxOff)
        local scale = sliderMin + (sliderMax - sliderMin) * rel
        local newX = math.floor(920 * scale); local newY = math.floor(560 * scale)
        root.Size = UDim2.new(0, newX, 0, newY)
    end
end)
task.defer(function()
    task.wait(0.08)
    local rel = (1.0 - sliderMin) / (sliderMax - sliderMin)
    local maxOff = math.max(0, sliderBar.AbsoluteSize.X - thumb.AbsoluteSize.X)
    thumb.Position = UDim2.new(0, clamp(math.floor(maxOff * rel), 0, maxOff), 0, 0)
    local newX = math.floor(920 * 1.0); local newY = math.floor(560 * 1.0)
    root.Size = UDim2.new(0, newX, 0, newY)
end)

-- make root draggable via topBar
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    local conn1, conn2
    conn1 = handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    conn2 = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    keepConn(conn1); keepConn(conn2)
end
makeDraggable(root, topBar)

-- =============================
-- GLOBAL cleanup function
-- =============================
function _G.NiriHub.cleanup()
    pcall(function()
        disconnectAll()
        if screenGui and screenGui.Parent then screenGui:Destroy() end
        _G.NiriHub = nil
    end)
end

print("Niri Hub ⚡ (completo, seguro e otimizado) carregado. Ações que afetariam outros jogadores foram removidas ou tornadas locais.")