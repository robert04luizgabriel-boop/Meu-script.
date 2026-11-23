local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove GUIs antigas se reexecutar
for _, nome in ipairs({ "ArgentinaKeyGui", "ArgentinaStoryGui" }) do
	local antiga = playerGui:FindFirstChild(nome)
	if antiga then
		antiga:Destroy()
	end
end

-- 10 Keys configuráveis com duração ao lado (em segundos; infinita = true para não expirar)
-- A contagem começa automaticamente no momento em que a Key é validada/usada
local KEYS_CONFIG = {
	{ key = "KEY_BybZUSUOyqWyCHqziqBzyAjN5Uk4GBmku-CinQz7Twat7f3L", duracaoSegundos = 0, infinita = true }, -- 1ª Key (infinita)
	{ key = "KEY_SLOT_02", duracaoSegundos = 3600, infinita = false }, -- 2ª Key (ex.: 1 hora = 3600s)
	{ key = "KEY_SLOT_03", duracaoSegundos = 7200, infinita = false }, -- 3ª Key (ex.: 2 horas = 7200s)
	{ key = "KEY_SLOT_04", duracaoSegundos = 1800, infinita = false }, -- 4ª Key (ex.: 30 min = 1800s)
	{ key = "KEY_SLOT_05", duracaoSegundos = 900, infinita = false },  -- 5ª Key (ex.: 15 min = 900s)
	{ key = "KEY_SLOT_06", duracaoSegundos = 86400, infinita = false }, -- 6ª Key (ex.: 24h = 86400s)
	{ key = "KEY_SLOT_07", duracaoSegundos = 600, infinita = false },  -- 7ª Key (ex.: 10 min = 600s)
	{ key = "KEY_SLOT_08", duracaoSegundos = 1200, infinita = false }, -- 8ª Key (ex.: 20 min = 1200s)
	{ key = "KEY_SLOT_09", duracaoSegundos = 5400, infinita = false }, -- 9ª Key (ex.: 1h30 = 5400s)
	{ key = "KEY_SLOT_10", duracaoSegundos = 10800, infinita = false }, -- 10ª Key (ex.: 3h = 10800s)
}

local KeyAtivaDados = nil -- { key = "...", infinita = false, inicioUso = os.clock(), duracaoSegundos = 3600 }

local function keyEstaValida()
	if not KeyAtivaDados then
		return false
	end
	if KeyAtivaDados.infinita then
		return true
	end
	local decorrido = os.clock() - KeyAtivaDados.inicioUso
	return decorrido < KeyAtivaDados.duracaoSegundos
end

local function formatarTempoRestante()
	if not KeyAtivaDados then
		return "Nenhuma"
	end
	if KeyAtivaDados.infinita then
		return "INFINITA"
	end
	local restante = math.max(0, math.floor(KeyAtivaDados.duracaoSegundos - (os.clock() - KeyAtivaDados.inicioUso)))
	local horas = math.floor(restante / 3600)
	local minutos = math.floor((restante % 3600) / 60)
	local segundos = restante % 60
	return string.format("%02d:%02d:%02d", horas, minutos, segundos)
end

local function buscarConfigKey(digitada)
	local limpa = string.gsub(tostring(digitada or ""), "^%s*(.-)%s*$", "%1")
	if limpa == "" then
		return nil
	end
	for _, item in ipairs(KEYS_CONFIG) do
		if item.key ~= "" and limpa == item.key then
			return item
		end
	end
	return nil
end

local Parte2 -- iniciará a aba ARGENTINA STORY após a Key ser validada

local function abrirPainelKey()
	local keyGui = Instance.new("ScreenGui")
	keyGui.Name = "ArgentinaKeyGui"
	keyGui.ResetOnSpawn = false
	keyGui.IgnoreGuiInset = true
	keyGui.Parent = playerGui

	local painel = Instance.new("Frame")
	painel.Name = "PainelKey"
	painel.Size = UDim2.new(0, 340, 0, 185)
	painel.Position = UDim2.new(0.5, -170, 0.5, -92)
	painel.BackgroundColor3 = Color3.fromRGB(22, 24, 29)
	painel.BorderColor3 = Color3.fromRGB(58, 63, 74)
	painel.BorderSizePixel = 1
	painel.Parent = keyGui

	local cantoPainel = Instance.new("UICorner")
	cantoPainel.CornerRadius = UDim.new(0, 6)
	cantoPainel.Parent = painel

	local barraTopo = Instance.new("Frame")
	barraTopo.Size = UDim2.new(1, 0, 0, 34)
	barraTopo.BackgroundColor3 = Color3.fromRGB(30, 33, 40)
	barraTopo.BorderSizePixel = 0
	barraTopo.Parent = painel

	local cantoTopo = Instance.new("UICorner")
	cantoTopo.CornerRadius = UDim.new(0, 6)
	cantoTopo.Parent = barraTopo

	local titulo = Instance.new("TextLabel")
	titulo.Size = UDim2.new(1, -16, 1, 0)
	titulo.Position = UDim2.new(0, 12, 0, 0)
	titulo.BackgroundTransparency = 1
	titulo.TextColor3 = Color3.fromRGB(235, 238, 245)
	titulo.Text = "ARGENTINA STORY • KEY SYSTEM"
	titulo.TextXAlignment = Enum.TextXAlignment.Left
	titulo.TextSize = 13
	titulo.Font = Enum.Font.GothamBold
	titulo.Parent = barraTopo

	-- Arrastar painel pela barra superior
	do
		local arrastando = false
		local inputAtual = nil
		local posInicialToque = Vector2.zero
		local posInicialPainel = Vector2.zero

		local function comecar(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				arrastando = true
				inputAtual = input
				posInicialToque = input.Position
				posInicialPainel = Vector2.new(painel.Position.X.Offset, painel.Position.Y.Offset)
			end
		end

		barraTopo.InputBegan:Connect(comecar)
		titulo.InputBegan:Connect(comecar)

		UserInputService.InputChanged:Connect(function(input)
			if arrastando and input == inputAtual then
				if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = input.Position - posInicialToque
					painel.Position = UDim2.new(0.5, posInicialPainel.X + delta.X, 0.5, posInicialPainel.Y + delta.Y)
				end
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input == inputAtual then
				arrastando = false
				inputAtual = nil
			end
		end)
	end

	local caixaKey = Instance.new("TextBox")
	caixaKey.Name = "CaixaKey"
	caixaKey.Size = UDim2.new(1, -24, 0, 38)
	caixaKey.Position = UDim2.new(0, 12, 0, 46)
	caixaKey.BackgroundColor3 = Color3.fromRGB(32, 35, 42)
	caixaKey.BorderColor3 = Color3.fromRGB(58, 63, 74)
	caixaKey.BorderSizePixel = 1
	caixaKey.TextColor3 = Color3.fromRGB(240, 242, 246)
	caixaKey.PlaceholderColor3 = Color3.fromRGB(130, 136, 148)
	caixaKey.PlaceholderText = "Cole ou digite sua Key aqui..."
	caixaKey.Text = ""
	caixaKey.ClearTextOnFocus = false
	caixaKey.TextSize = 12
	caixaKey.Font = Enum.Font.Gotham
	caixaKey.Parent = painel

	local cantoCaixa = Instance.new("UICorner")
	cantoCaixa.CornerRadius = UDim.new(0, 6)
	cantoCaixa.Parent = caixaKey

	local botaoValidar = Instance.new("TextButton")
	botaoValidar.Name = "BotaoValidar"
	botaoValidar.Size = UDim2.new(1, -24, 0, 36)
	botaoValidar.Position = UDim2.new(0, 12, 0, 94)
	botaoValidar.BackgroundColor3 = Color3.fromRGB(46, 160, 92)
	botaoValidar.TextColor3 = Color3.fromRGB(255, 255, 255)
	botaoValidar.Text = "Validar Key"
	botaoValidar.TextSize = 13
	botaoValidar.Font = Enum.Font.GothamBold
	botaoValidar.Parent = painel

	local cantoBotao = Instance.new("UICorner")
	cantoBotao.CornerRadius = UDim.new(0, 6)
	cantoBotao.Parent = botaoValidar

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusKey"
	statusLabel.Size = UDim2.new(1, -24, 0, 28)
	statusLabel.Position = UDim2.new(0, 12, 0, 138)
	statusLabel.BackgroundTransparency = 1
	statusLabel.TextColor3 = Color3.fromRGB(185, 192, 204)
	statusLabel.Text = "Aguardando Key válida..."
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextSize = 12
	statusLabel.Font = Enum.Font.GothamSemibold
	statusLabel.Parent = painel

	botaoValidar.MouseButton1Click:Connect(function()
		local encontrado = buscarConfigKey(caixaKey.Text)
		if not encontrado then
			statusLabel.TextColor3 = Color3.fromRGB(235, 87, 87)
			statusLabel.Text = "Key inválida! Confira e tente novamente."
			return
		end

		-- Inicia a contagem no exato momento em que a Key é usada
		KeyAtivaDados = {
			key = encontrado.key,
			infinita = encontrado.infinita == true,
			duracaoSegundos = tonumber(encontrado.duracaoSegundos) or 0,
			inicioUso = os.clock(),
		}

		if not keyEstaValida() then
			statusLabel.TextColor3 = Color3.fromRGB(235, 87, 87)
			statusLabel.Text = "Esta Key já expirou."
			return
		end

		statusLabel.TextColor3 = Color3.fromRGB(72, 199, 124)
		statusLabel.Text = "Key aceita! Tempo: " .. formatarTempoRestante()
		task.wait(0.25)

		keyGui:Destroy()

		-- Avança da Parte 1 para a Parte 2 (aba ARGENTINA STORY)
		if type(Parte2) == "function" then
			task.spawn(Parte2)
		end
	end)
end

abrirPainelKey()
local AutoMineradorAtivo = false
local GeracaoExecucao = 0

local function estaAtivo(geracao)
	return AutoMineradorAtivo and (geracao == GeracaoExecucao) and keyEstaValida()
end

local function limparEstadoPersonagem()
	pcall(function()
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
	end)
	pcall(function()
		local cam = workspace.CurrentCamera
		local posTela = cam and Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5) or Vector2.new(500, 300)
		VirtualInputManager:SendMouseButtonEvent(posTela.X, posTela.Y, 0, false, game, 0)
	end)

	local char = player.Character
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.Anchored = false
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			for _, obj in ipairs(hrp:GetChildren()) do
				if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
					obj:Destroy()
				end
			end
		end

		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = false
		end

		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = true
			end
		end
	end
end

local Parte3 -- definida na Parte 3 (mineração)
local Parte4 -- definida na Parte 4 (TP/venda + equipar 1º slot)

local function iniciarCicloCompleto(geracao)
	while estaAtivo(geracao) do
		-- Parte 2 chama a Parte 3 (mineração)
		if type(Parte3) == "function" then
			local ok3, err3 = pcall(function()
				Parte3(geracao)
			end)
			if not ok3 and estaAtivo(geracao) then
				warn("Erro na Parte 3 (mineração):", err3)
			end
		end

		if not estaAtivo(geracao) then
			break
		end

		-- Parte 3 encerra e segue para a Parte 4 (TP/venda + retorno + 1º slot)
		if type(Parte4) == "function" then
			local ok4, err4 = pcall(function()
				Parte4(geracao)
			end)
			if not ok4 and estaAtivo(geracao) then
				warn("Erro na Parte 4 (TP/venda):", err4)
			end
		end

		if not estaAtivo(geracao) then
			break
		end

		task.wait(0.5)
	end

	limparEstadoPersonagem()
end

Parte2 = function()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ArgentinaStoryGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local janela = Instance.new("Frame")
	janela.Name = "JanelaPrincipal"
	janela.Size = UDim2.new(0, 320, 0, 152)
	janela.Position = UDim2.new(0.5, -160, 0.5, -76)
	janela.BackgroundColor3 = Color3.fromRGB(22, 24, 29)
	janela.BorderColor3 = Color3.fromRGB(58, 63, 74)
	janela.BorderSizePixel = 1
	janela.Parent = screenGui

	local cantoJanela = Instance.new("UICorner")
	cantoJanela.CornerRadius = UDim.new(0, 6)
	cantoJanela.Parent = janela

	local barraTitulo = Instance.new("Frame")
	barraTitulo.Name = "BarraTitulo"
	barraTitulo.Size = UDim2.new(1, 0, 0, 34)
	barraTitulo.Position = UDim2.new(0, 0, 0, 0)
	barraTitulo.BackgroundColor3 = Color3.fromRGB(30, 33, 40)
	barraTitulo.BorderSizePixel = 0
	barraTitulo.Parent = janela

	local cantoTitulo = Instance.new("UICorner")
	cantoTitulo.CornerRadius = UDim.new(0, 6)
	cantoTitulo.Parent = barraTitulo

	local tituloLabel = Instance.new("TextLabel")
	tituloLabel.Name = "TituloArgentinaStory"
	tituloLabel.Size = UDim2.new(1, -16, 1, 0)
	tituloLabel.Position = UDim2.new(0, 12, 0, 0)
	tituloLabel.BackgroundTransparency = 1
	tituloLabel.TextColor3 = Color3.fromRGB(235, 238, 245)
	tituloLabel.Text = "ARGENTINA STORY"
	tituloLabel.TextXAlignment = Enum.TextXAlignment.Left
	tituloLabel.TextSize = 14
	tituloLabel.Font = Enum.Font.GothamBold
	tituloLabel.Parent = barraTitulo

	local divisor = Instance.new("Frame")
	divisor.Size = UDim2.new(1, 0, 0, 1)
	divisor.Position = UDim2.new(0, 0, 0, 34)
	divisor.BackgroundColor3 = Color3.fromRGB(52, 57, 68)
	divisor.BorderSizePixel = 0
	divisor.Parent = janela

	do
		local arrastando = false
		local inputArraste = nil
		local inicioToque = Vector2.zero
		local inicioJanela = Vector2.zero

		local function iniciarArraste(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				arrastando = true
				inputArraste = input
				inicioToque = input.Position
				inicioJanela = Vector2.new(janela.Position.X.Offset, janela.Position.Y.Offset)
			end
		end

		tituloLabel.InputBegan:Connect(iniciarArraste)
		barraTitulo.InputBegan:Connect(iniciarArraste)

		UserInputService.InputChanged:Connect(function(input)
			if arrastando and input == inputArraste then
				if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = input.Position - inicioToque
					janela.Position = UDim2.new(
						0.5,
						inicioJanela.X + delta.X,
						0.5,
						inicioJanela.Y + delta.Y
					)
				end
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input == inputArraste then
				arrastando = false
				inputArraste = nil
			end
		end)
	end

	local linhaOpcao = Instance.new("Frame")
	linhaOpcao.Name = "LinhaAutoMinerador"
	linhaOpcao.Size = UDim2.new(1, -24, 0, 48)
	linhaOpcao.Position = UDim2.new(0, 12, 0, 48)
	linhaOpcao.BackgroundColor3 = Color3.fromRGB(32, 35, 42)
	linhaOpcao.BorderColor3 = Color3.fromRGB(54, 59, 70)
	linhaOpcao.BorderSizePixel = 1
	linhaOpcao.Parent = janela

	local cantoLinha = Instance.new("UICorner")
	cantoLinha.CornerRadius = UDim.new(0, 6)
	cantoLinha.Parent = linhaOpcao

	local textoOpcao = Instance.new("TextLabel")
	textoOpcao.Name = "LabelAutoMinerador"
	textoOpcao.Size = UDim2.new(1, -84, 1, 0)
	textoOpcao.Position = UDim2.new(0, 12, 0, 0)
	textoOpcao.BackgroundTransparency = 1
	textoOpcao.TextColor3 = Color3.fromRGB(225, 229, 236)
	textoOpcao.Text = "Auto minerador"
	textoOpcao.TextXAlignment = Enum.TextXAlignment.Left
	textoOpcao.TextSize = 14
	textoOpcao.Font = Enum.Font.GothamSemibold
	textoOpcao.Parent = linhaOpcao

	local trilho = Instance.new("TextButton")
	trilho.Name = "TrilhoDeslizante"
	trilho.Size = UDim2.new(0, 52, 0, 26)
	trilho.Position = UDim2.new(1, -64, 0.5, -13)
	trilho.BackgroundColor3 = Color3.fromRGB(68, 73, 84)
	trilho.Text = ""
	trilho.AutoButtonColor = false
	trilho.Parent = linhaOpcao

	local cantoTrilho = Instance.new("UICorner")
	cantoTrilho.CornerRadius = UDim.new(1, 0)
	cantoTrilho.Parent = trilho

	local bolinha = Instance.new("Frame")
	bolinha.Name = "Bolinha"
	bolinha.Size = UDim2.new(0, 20, 0, 20)
	bolinha.Position = UDim2.new(0, 3, 0.5, -10)
	bolinha.BackgroundColor3 = Color3.fromRGB(240, 242, 246)
	bolinha.BorderSizePixel = 0
	bolinha.Parent = trilho

	local cantoBolinha = Instance.new("UICorner")
	cantoBolinha.CornerRadius = UDim.new(1, 0)
	cantoBolinha.Parent = bolinha

	local tempoKeyLabel = Instance.new("TextLabel")
	tempoKeyLabel.Name = "TempoKeyRestante"
	tempoKeyLabel.Size = UDim2.new(1, -24, 0, 26)
	tempoKeyLabel.Position = UDim2.new(0, 12, 0, 108)
	tempoKeyLabel.BackgroundTransparency = 1
	tempoKeyLabel.TextColor3 = Color3.fromRGB(165, 173, 186)
	tempoKeyLabel.Text = "Key: " .. formatarTempoRestante()
	tempoKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
	tempoKeyLabel.TextSize = 12
	tempoKeyLabel.Font = Enum.Font.Gotham
	tempoKeyLabel.Parent = janela

	local function atualizarVisualSwitch(ligado)
		if ligado then
			trilho.BackgroundColor3 = Color3.fromRGB(46, 160, 92)
			bolinha:TweenPosition(UDim2.new(1, -23, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.14, true)
		else
			trilho.BackgroundColor3 = Color3.fromRGB(68, 73, 84)
			bolinha:TweenPosition(UDim2.new(0, 3, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.14, true)
		end
	end

	local function forcarDesligar(motivo)
		if AutoMineradorAtivo then
			AutoMineradorAtivo = false
			GeracaoExecucao += 1
			atualizarVisualSwitch(false)
			limparEstadoPersonagem()
			if motivo then
				warn(motivo)
			end
		end
	end

	local function alternarAutoMinerador()
		if not AutoMineradorAtivo then
			if not keyEstaValida() then
				warn("Key expirada ou inválida. Abra o painel de Key novamente.")
				return
			end
			AutoMineradorAtivo = true
			GeracaoExecucao += 1
			local minhaGeracao = GeracaoExecucao
			atualizarVisualSwitch(true)
			print("Auto minerador: ATIVADO")
			task.spawn(function()
				iniciarCicloCompleto(minhaGeracao)
			end)
		else
			forcarDesligar("Auto minerador: DESATIVADO")
		end
	end

	trilho.MouseButton1Click:Connect(alternarAutoMinerador)
	bolinha.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			alternarAutoMinerador()
		end
	end)

	-- Atualiza a contagem da Key na tela e desliga automaticamente se o tempo acabar
	task.spawn(function()
		while screenGui.Parent do
			tempoKeyLabel.Text = "Key: " .. formatarTempoRestante()
			if AutoMineradorAtivo and not keyEstaValida() then
				forcarDesligar("Tempo da Key encerrado! Auto minerador parado.")
			end
			task.wait(0.5)
		end
	end)
end
Parte3 = function(geracao)
	if not estaAtivo(geracao) then
		return
	end

	print("Iniciando mineração...")

	local CONFIG = {
		LimiteColetas = 9,
		VelocidadeVoo = 30,
		DistanciaChegada = 4.5,
		DistanciaFrentePedra = 3.2,
		AlturaFrentePedra = 1.2,
		TempoMaximoPorPedra = 25,
		TempoEsperaProxima = 0.6,
		TextoPromptAlvo = "minerar",
	}

	local function obterRootEHumanoid()
		local character = player.Character or player.CharacterAdded:Wait()
		local hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
		return character, hrp, humanoid
	end

	local function obterBasePartDoPrompt(prompt)
		if not prompt or not prompt.Parent then
			return nil
		end

		local pai = prompt.Parent
		if pai:IsA("BasePart") then
			return pai
		elseif pai:IsA("Attachment") and pai.Parent and pai.Parent:IsA("BasePart") then
			return pai.Parent
		elseif pai:IsA("Model") then
			return pai.PrimaryPart or pai:FindFirstChildWhichIsA("BasePart", true)
		end

		return nil
	end

	local function promptEhDeMinerar(prompt)
		if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then
			return false
		end

		local acao = string.lower(prompt.ActionText or "")
		local objeto = string.lower(prompt.ObjectText or "")
		local nomePrompt = string.lower(prompt.Name or "")
		local nomePai = prompt.Parent and string.lower(prompt.Parent.Name) or ""
		local nomeAvo = (prompt.Parent and prompt.Parent.Parent) and string.lower(prompt.Parent.Parent.Name) or ""

		if string.find(acao, CONFIG.TextoPromptAlvo, 1, true)
			or string.find(objeto, CONFIG.TextoPromptAlvo, 1, true)
			or string.find(nomePrompt, CONFIG.TextoPromptAlvo, 1, true)
			or string.find(nomePai, "pedra", 1, true)
			or string.find(nomePai, "min", 1, true)
			or string.find(nomeAvo, "pedra", 1, true)
			or string.find(nomeAvo, "min", 1, true) then
			return true
		end

		return false
	end

	local function encontrarProximaPedra(ignoradas)
		local _, hrp = obterRootEHumanoid()
		local posAtual = hrp and hrp.Position or Vector3.zero

		local melhorParte = nil
		local melhorPrompt = nil
		local melhorAlvo = nil
		local menorDistancia = math.huge

		for _, obj in ipairs(workspace:GetDescendants()) do
			if not estaAtivo(geracao) then
				return nil, nil, nil
			end
			if obj:IsA("ProximityPrompt") and promptEhDeMinerar(obj) then
				local parte = obterBasePartDoPrompt(obj)
				if parte and parte:IsDescendantOf(workspace) and parte.Transparency < 1 then
					local alvo = (parte.Parent and parte.Parent:IsA("Model")) and parte.Parent or parte
					if not ignoradas[parte] and not ignoradas[alvo] and not ignoradas[obj] then
						local dist = (parte.Position - posAtual).Magnitude
						if dist < menorDistancia then
							menorDistancia = dist
							melhorParte = parte
							melhorPrompt = obj
							melhorAlvo = alvo
						end
					end
				end
			end
		end

		return melhorParte, melhorPrompt, melhorAlvo
	end

	local function pedraAindaExiste(parte, prompt, alvo)
		if not parte or not parte.Parent or not parte:IsDescendantOf(workspace) then
			return false
		end
		if parte.Transparency >= 1 then
			return false
		end
		if prompt and (not prompt.Parent or not prompt.Enabled) then
			return false
		end
		if alvo and alvo ~= parte and (not alvo.Parent or not alvo:IsDescendantOf(workspace)) then
			return false
		end
		return true
	end

	local function calcularPosicaoFrentePedra(parte, posReferencia)
		local centro = parte.Position
		local raioHorizontal = math.max(parte.Size.X, parte.Size.Z) * 0.5
		local afastamento = raioHorizontal + CONFIG.DistanciaFrentePedra

		local dirPlano = Vector3.new(posReferencia.X - centro.X, 0, posReferencia.Z - centro.Z)
		if dirPlano.Magnitude > 0.05 then
			dirPlano = dirPlano.Unit
		else
			local look = parte.CFrame.LookVector
			dirPlano = Vector3.new(look.X, 0, look.Z)
			if dirPlano.Magnitude > 0.05 then
				dirPlano = dirPlano.Unit
			else
				dirPlano = Vector3.new(0, 0, 1)
			end
		end

		local frentePos = centro + (dirPlano * afastamento)
		local alturaSegura = math.max(centro.Y - (parte.Size.Y * 0.25) + CONFIG.AlturaFrentePedra, centro.Y + 0.5)
		return Vector3.new(frentePos.X, alturaSegura, frentePos.Z)
	end

	local function voarDevagarAte(parte, prompt, alvo)
		local _, hrp, humanoid = obterRootEHumanoid()
		if not hrp or not humanoid then
			return false
		end

		humanoid.PlatformStand = true

		local noclipConn = RunService.Stepped:Connect(function()
			if not estaAtivo(geracao) then
				return
			end
			local char = player.Character
			if char then
				for _, p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then
						p.CanCollide = false
					end
				end
			end
		end)

		local bodyVel = Instance.new("BodyVelocity")
		bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bodyVel.Velocity = Vector3.zero
		bodyVel.Parent = hrp

		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		bodyGyro.P = 3000
		bodyGyro.Parent = hrp

		local chegou = false
		while estaAtivo(geracao) and pedraAindaExiste(parte, prompt, alvo) do
			local _, atualHrp = obterRootEHumanoid()
			if not atualHrp then
				break
			end

			local destino = calcularPosicaoFrentePedra(parte, atualHrp.Position)
			local direcao = destino - atualHrp.Position
			local distancia = direcao.Magnitude

			if distancia <= CONFIG.DistanciaChegada then
				chegou = true
				break
			end

			bodyVel.Velocity = direcao.Unit * CONFIG.VelocidadeVoo
			bodyGyro.CFrame = CFrame.lookAt(atualHrp.Position, Vector3.new(parte.Position.X, atualHrp.Position.Y, parte.Position.Z))
			RunService.Heartbeat:Wait()
		end

		bodyVel.Velocity = Vector3.zero
		bodyVel:Destroy()
		bodyGyro:Destroy()
		if noclipConn then
			noclipConn:Disconnect()
		end

		if humanoid and humanoid.Parent then
			humanoid.PlatformStand = false
		end

		return chegou and estaAtivo(geracao)
	end

	local function segurarColetaAteSumir(parte, prompt, alvo)
		local inicio = os.clock()
		local segurandoTecla = false
		local segurandoClique = false

		local function iniciarSegurar()
			if not estaAtivo(geracao) then
				return
			end
			if prompt and prompt.Parent and prompt.Enabled then
				pcall(function()
					prompt:InputHoldBegin()
				end)
			end

			if not segurandoTecla then
				segurandoTecla = true
				pcall(function()
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
				end)
			end

			if not segurandoClique then
				segurandoClique = true
				local cam = workspace.CurrentCamera
				local posTela = cam and Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5) or Vector2.new(500, 300)
				pcall(function()
					VirtualInputManager:SendMouseButtonEvent(posTela.X, posTela.Y, 0, true, game, 0)
				end)
			end
		end

		local function soltarSegurar()
			if prompt and prompt.Parent then
				pcall(function()
					prompt:InputHoldEnd()
				end)
			end
			if segurandoTecla then
				segurandoTecla = false
				pcall(function()
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
				end)
			end
			if segurandoClique then
				segurandoClique = false
				local cam = workspace.CurrentCamera
				local posTela = cam and Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5) or Vector2.new(500, 300)
				pcall(function()
					VirtualInputManager:SendMouseButtonEvent(posTela.X, posTela.Y, 0, false, game, 0)
				end)
			end
		end

		while estaAtivo(geracao) and pedraAindaExiste(parte, prompt, alvo) and (os.clock() - inicio) < CONFIG.TempoMaximoPorPedra do
			local _, hrp = obterRootEHumanoid()
			if hrp then
				local pontoFrente = calcularPosicaoFrentePedra(parte, hrp.Position)
				hrp.Anchored = true
				hrp.CFrame = CFrame.lookAt(pontoFrente, Vector3.new(parte.Position.X, pontoFrente.Y, parte.Position.Z))
			end

			iniciarSegurar()
			task.wait(0.15)
		end

		soltarSegurar()

		local _, hrpFim = obterRootEHumanoid()
		if hrpFim then
			hrpFim.Anchored = false
		end

		return not pedraAindaExiste(parte, prompt, alvo)
	end

	local function executarCicloMineracao()
		local tentativasFeitas = 0
		local ignoradas = {}

		while estaAtivo(geracao) and tentativasFeitas < CONFIG.LimiteColetas do
			local partePedra, promptPedra, alvoPedra = encontrarProximaPedra(ignoradas)
			if not estaAtivo(geracao) then
				break
			end
			if not partePedra then
				warn("Nenhuma pedra com prompt 'Minerar' encontrada no momento.")
				break
			end

			local chegou = voarDevagarAte(partePedra, promptPedra, alvoPedra)
			if not estaAtivo(geracao) then
				break
			end

			if chegou and pedraAindaExiste(partePedra, promptPedra, alvoPedra) then
				tentativasFeitas += 1
				local coletou = segurarColetaAteSumir(partePedra, promptPedra, alvoPedra)

				ignoradas[partePedra] = true
				if promptPedra then
					ignoradas[promptPedra] = true
				end
				if alvoPedra then
					ignoradas[alvoPedra] = true
				end

				if coletou then
					print("Tentativa/coleta concluída:", tentativasFeitas .. "/" .. CONFIG.LimiteColetas)
				else
					print("Tentativa registrada:", tentativasFeitas .. "/" .. CONFIG.LimiteColetas)
				end

				if tentativasFeitas >= CONFIG.LimiteColetas then
					break
				end
			else
				ignoradas[partePedra] = true
			end

			if estaAtivo(geracao) and tentativasFeitas < CONFIG.LimiteColetas then
				task.wait(CONFIG.TempoEsperaProxima)
			end
		end

		print("Ciclo encerrado nas 9 tentativas. Total registrado:", tentativasFeitas)
	end

	executarCicloMineracao()
	limparEstadoPersonagem()

	if estaAtivo(geracao) then
		print("Mineração finalizada!")
	end
end
Parte4 = function(geracao)
	if not estaAtivo(geracao) then
		return
	end

	print("Iniciando venda...")

	local CONFIG = {
		TextoPromptAlvo = "vender minérios",
		TituloMenuAlvo = "companhia de mineração",
		CoordenadasVender = {
			{ x = 314, y = 278 },
			{ x = 386, y = 280 },
			{ x = 459, y = 277 },
			{ x = 524, y = 278 },
			{ x = 590, y = 277 },
		},
		CoordenadaFecharX = { x = 639, y = 143 },
		IntervaloCliqueVender = 1.0,
		TempoExtraSegurar = 0.55,
		TempoMaximoSegurando = 2.2,
		TempoEsperaMenu = 0.35,
		RaioDetectarCarro = 300,
		PosicaoVenda = Vector3.new(2933.27, 4.13, 3183.48),
		AlturaLevantadaTp = 18,
		EsperaCarregarMapa = 0.35,
		PosicaoRetorno = Vector3.new(386.17, 5.08, 2121.79),
		VelocidadeAproximacaoNpc = 18,
		DistanciaParadaNpc = 3.5,
	}

	local function obterPersonagem()
		local character = player.Character or player.CharacterAdded:Wait()
		local hrp = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		return character, hrp, humanoid
	end

	local function equiparPrimeiroSlot()
		if not estaAtivo(geracao) then
			return
		end

		local character, _, humanoid = obterPersonagem()
		if not character or not humanoid then
			return
		end

		pcall(function()
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
			task.wait(0.04)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
		end)

		task.wait(0.08)

		local backpack = player:FindFirstChildOfClass("Backpack")
		local tool = backpack and backpack:FindFirstChildWhichIsA("Tool")
		if tool and tool.Parent == backpack and estaAtivo(geracao) then
			pcall(function()
				humanoid:EquipTool(tool)
			end)
		end
	end

	local function obterBasePartDoPrompt(prompt)
		if not prompt or not prompt.Parent then
			return nil
		end

		local pai = prompt.Parent
		if pai:IsA("BasePart") then
			return pai
		elseif pai:IsA("Attachment") and pai.Parent and pai.Parent:IsA("BasePart") then
			return pai.Parent
		elseif pai:IsA("Model") then
			return pai.PrimaryPart or pai:FindFirstChildWhichIsA("BasePart", true)
		end

		return nil
	end

	local function promptEhDeVenderMinerios(prompt)
		if not prompt or not prompt:IsA("ProximityPrompt") then
			return false
		end

		local acao = string.lower(prompt.ActionText or "")
		local objeto = string.lower(prompt.ObjectText or "")
		local nomePrompt = string.lower(prompt.Name or "")
		local nomePai = prompt.Parent and string.lower(prompt.Parent.Name) or ""
		local nomeAvo = (prompt.Parent and prompt.Parent.Parent) and string.lower(prompt.Parent.Parent.Name) or ""

		return string.find(acao, CONFIG.TextoPromptAlvo, 1, true)
			or string.find(objeto, CONFIG.TextoPromptAlvo, 1, true)
			or string.find(nomePrompt, "vender", 1, true)
			or string.find(nomePai, "vender", 1, true)
			or string.find(nomePai, "miner", 1, true)
			or string.find(nomeAvo, "vender", 1, true)
			or string.find(nomeAvo, "miner", 1, true)
	end

	local function encontrarPromptNpcVenda()
		for _, obj in ipairs(workspace:GetDescendants()) do
			if not estaAtivo(geracao) then
				return nil, nil
			end
			if obj:IsA("ProximityPrompt") and promptEhDeVenderMinerios(obj) then
				local parte = obterBasePartDoPrompt(obj)
				if parte and parte:IsDescendantOf(workspace) then
					return obj, parte
				end
			end
		end
		return nil, nil
	end

	local function modeloPertenceAoJogador(modelo)
		if not modelo or not modelo:IsA("Model") then
			return false
		end

		local nomeJogador = string.lower(player.Name)
		local displayJogador = string.lower(player.DisplayName or "")
		local userIdStr = tostring(player.UserId)

		local function valorEhDoJogador(val)
			if val == nil then
				return false
			end
			if typeof(val) == "Instance" then
				return val == player or val == player.Character
			end
			local s = string.lower(tostring(val))
			return s == nomeJogador
				or (displayJogador ~= "" and s == displayJogador)
				or s == userIdStr
				or string.find(s, nomeJogador, 1, true) ~= nil
				or string.find(s, userIdStr, 1, true) ~= nil
		end

		for chave, valor in pairs(modelo:GetAttributes()) do
			local chaveLower = string.lower(tostring(chave))
			if string.find(chaveLower, "owner", 1, true)
				or string.find(chaveLower, "dono", 1, true)
				or string.find(chaveLower, "player", 1, true)
				or string.find(chaveLower, "user", 1, true)
				or string.find(chaveLower, "driver", 1, true)
				or string.find(chaveLower, "motorista", 1, true)
			then
				if valorEhDoJogador(valor) then
					return true
				end
			end
		end

		for _, desc in ipairs(modelo:GetDescendants()) do
			if desc:IsA("ObjectValue") or desc:IsA("StringValue") or desc:IsA("IntValue") or desc:IsA("NumberValue") then
				local n = string.lower(desc.Name)
				if string.find(n, "owner", 1, true)
					or string.find(n, "dono", 1, true)
					or string.find(n, "player", 1, true)
					or string.find(n, "user", 1, true)
					or string.find(n, "driver", 1, true)
				then
					if valorEhDoJogador(desc.Value) then
						return true
					end
				end
			elseif desc:IsA("Seat") or desc:IsA("VehicleSeat") then
				if desc.Occupant and desc.Occupant.Parent == player.Character then
					return true
				end
			end
		end

		local nomeModelo = string.lower(modelo.Name)
		if string.find(nomeModelo, nomeJogador, 1, true) or string.find(nomeModelo, userIdStr, 1, true) then
			return true
		end

		return false
	end

	local function encontrarMeuCarroPerto()
		local _, hrp = obterPersonagem()
		if not hrp then
			return nil, nil
		end

		local melhorCarro = nil
		local melhorAssento = nil
		local menorDist = CONFIG.RaioDetectarCarro

		for _, obj in ipairs(workspace:GetDescendants()) do
			if not estaAtivo(geracao) then
				return nil, nil
			end
			if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
				local modelo = obj:FindFirstAncestorOfClass("Model")
				if modelo and modelo ~= player.Character and modeloPertenceAoJogador(modelo) then
					if not obj.Occupant or obj.Occupant.Parent == player.Character then
						local dist = (obj.Position - hrp.Position).Magnitude
						if dist <= menorDist then
							menorDist = dist
							melhorCarro = modelo
							melhorAssento = obj
						end
					end
				end
			end
		end

		return melhorCarro, melhorAssento
	end

	local function entrarNoCarro(carro, assento)
		local character, hrp, humanoid = obterPersonagem()
		if not character or not hrp or not humanoid or not carro or not assento then
			return false
		end

		if humanoid.SeatPart == assento then
			return true
		end

		character:PivotTo(assento.CFrame * CFrame.new(0, 1.5, 0))
		pcall(function()
			assento:Sit(humanoid)
		end)

		for _ = 1, 15 do
			if not estaAtivo(geracao) then
				return false
			end
			if humanoid.SeatPart and humanoid.SeatPart:IsDescendantOf(carro) then
				return true
			end
			character:PivotTo(assento.CFrame * CFrame.new(0, 1.2, 0))
			task.wait(0.03)
		end

		return humanoid.SeatPart ~= nil and humanoid.SeatPart:IsDescendantOf(carro)
	end

	local function sairDoCarro()
		local character, hrp, humanoid = obterPersonagem()
		if not character or not hrp or not humanoid then
			return
		end

		humanoid.Sit = false
		if humanoid.SeatPart then
			pcall(function()
				humanoid.SeatPart.Occupant = nil
			end)
		end
		task.wait(0.03)
		character:PivotTo(hrp.CFrame * CFrame.new(0, 2.5, -3.5))
	end

	local function teleporteLivre(cfDestino, carro)
		if not estaAtivo(geracao) then
			return false
		end
		local character, hrp = obterPersonagem()
		if not character or not hrp then
			return false
		end

		if carro then
			local base = carro.PrimaryPart or carro:FindFirstChildWhichIsA("BasePart", true)
			if base then
				local offsetCar = base.CFrame:ToObjectSpace(hrp.CFrame)
				carro:PivotTo(cfDestino)
				character:PivotTo(base.CFrame * offsetCar)
			else
				carro:PivotTo(cfDestino)
				character:PivotTo(cfDestino * CFrame.new(0, 2, 0))
			end
		else
			character:PivotTo(cfDestino)
		end

		return true
	end

	local function voarDevagarAteNpc(parteNpc)
		local character, hrp = obterPersonagem()
		if not character or not hrp or not parteNpc or not parteNpc.Parent then
			return false
		end

		local inicio = os.clock()
		local maxDuracao = 6.0

		while estaAtivo(geracao) and (os.clock() - inicio) < maxDuracao do
			character, hrp = obterPersonagem()
			if not character or not hrp or not parteNpc.Parent then
				return false
			end

			local alvoPos = parteNpc.Position
			local vetorAteNpc = alvoPos - hrp.Position
			local distancia = vetorAteNpc.Magnitude

			if distancia <= CONFIG.DistanciaParadaNpc then
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
				hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(alvoPos.X, hrp.Position.Y, alvoPos.Z))
				return true
			end

			local dt = RunService.Heartbeat:Wait()
			if not estaAtivo(geracao) then
				return false
			end
			local passo = math.min(distancia - CONFIG.DistanciaParadaNpc * 0.5, CONFIG.VelocidadeAproximacaoNpc * dt)
			if passo > 0 then
				local direcao = vetorAteNpc.Unit
				local novaPos = hrp.Position + (direcao * passo)
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
				character:PivotTo(CFrame.lookAt(novaPos, Vector3.new(alvoPos.X, hrp.Position.Y, alvoPos.Z)))
			end
		end

		return estaAtivo(geracao)
	end

	local function guiEstaVisivelNaTela(guiObj)
		if not guiObj or not guiObj.Parent then
			return false
		end

		local atual = guiObj
		while atual and atual ~= game do
			if atual:IsA("ScreenGui") then
				return atual.Enabled
			elseif atual:IsA("GuiObject") and not atual.Visible then
				return false
			end
			atual = atual.Parent
		end

		return true
	end

	local function menuVendaEstaAberto()
		local pGui = player:FindFirstChild("PlayerGui")
		if not pGui then
			return false
		end

		for _, gui in ipairs(pGui:GetDescendants()) do
			if guiEstaVisivelNaTela(gui) and (gui:IsA("TextLabel") or gui:IsA("TextButton")) then
				local txt = string.lower(gui.Text or "")
				if string.find(txt, CONFIG.TituloMenuAlvo, 1, true) or txt == "vender" then
					return true
				end
			end
		end

		return false
	end

	local function segurarAteAbrirMenuVenda(prompt, parteNpc)
		local inicio = os.clock()
		local holdDuracao = (prompt and prompt.HoldDuration and prompt.HoldDuration > 0) and prompt.HoldDuration or 0.6
		local tempoMinimoHold = holdDuracao + CONFIG.TempoExtraSegurar

		local teclaAlvo = (prompt and prompt.KeyboardKeyCode and prompt.KeyboardKeyCode ~= Enum.KeyCode.Unknown)
			and prompt.KeyboardKeyCode or Enum.KeyCode.E

		local cam = workspace.CurrentCamera
		local posTela = cam and Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5) or Vector2.new(500, 300)

		local function pressionarContinuo()
			if not estaAtivo(geracao) then
				return
			end
			local _, hrp = obterPersonagem()
			if hrp and parteNpc and parteNpc.Parent then
				hrp.CFrame = CFrame.lookAt(hrp.Position, parteNpc.Position)
			end

			if prompt and prompt.Parent and prompt.Enabled then
				pcall(function()
					prompt:InputHoldBegin()
				end)
			end

			pcall(function()
				VirtualInputManager:SendKeyEvent(true, teclaAlvo, false, game)
			end)

			pcall(function()
				VirtualInputManager:SendMouseButtonEvent(posTela.X, posTela.Y, 0, true, game, 0)
			end)
		end

		local function soltarTudo()
			pcall(function()
				VirtualInputManager:SendMouseButtonEvent(posTela.X, posTela.Y, 0, false, game, 0)
			end)
			pcall(function()
				VirtualInputManager:SendKeyEvent(false, teclaAlvo, false, game)
			end)
			if prompt and prompt.Parent then
				pcall(function()
					prompt:InputHoldEnd()
				end)
			end
		end

		local abriu = false

		while estaAtivo(geracao) and (os.clock() - inicio) < CONFIG.TempoMaximoSegurando do
			pressionarContinuo()

			if (os.clock() - inicio) >= tempoMinimoHold and menuVendaEstaAberto() then
				abriu = true
				break
			end

			task.wait(0.06)
		end

		soltarTudo()

		if not abriu and estaAtivo(geracao) then
			local esperaExtra = os.clock()
			while estaAtivo(geracao) and (os.clock() - esperaExtra) < CONFIG.TempoEsperaMenu do
				if menuVendaEstaAberto() then
					abriu = true
					break
				end
				task.wait(0.06)
			end
		end

		return abriu and estaAtivo(geracao)
	end

	local function clicarCoordenada(x, y)
		if not estaAtivo(geracao) then
			return
		end
		pcall(function()
			VirtualInputManager:SendMouseMoveEvent(x, y, game)
		end)
		task.wait(0.015)
		if not estaAtivo(geracao) then
			return
		end
		pcall(function()
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
			task.wait(0.03)
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
		end)
		pcall(function()
			if VirtualInputManager.SendTouchEvent then
				VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.Begin, x, y)
				task.wait(0.03)
				VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.End, x, y)
			end
		end)
	end

	local function executarVendaERetorno()
		local character, hrp = obterPersonagem()
		if not character or not hrp then
			warn("Personagem ou HumanoidRootPart não encontrado.")
			return
		end

		local offsetAltura = Vector3.new(0, CONFIG.AlturaLevantadaTp, 0)
		local destinoVendaLevantado = CFrame.new(CONFIG.PosicaoVenda + offsetAltura)
		local destinoRetornoLevantado = CFrame.new(CONFIG.PosicaoRetorno + offsetAltura)

		local carro, assento = encontrarMeuCarroPerto()
		if not carro or not assento then
			warn("Seu carro não foi encontrado no raio de " .. CONFIG.RaioDetectarCarro .. " studs.")
			return
		end

		if not entrarNoCarro(carro, assento) then
			warn("Não foi possível sentar no seu carro.")
			return
		end

		if not estaAtivo(geracao) then
			return
		end

		teleporteLivre(destinoVendaLevantado, carro)
		task.wait(CONFIG.EsperaCarregarMapa)
		if not estaAtivo(geracao) then
			return
		end

		sairDoCarro()
		task.wait(0.1)
		if not estaAtivo(geracao) then
			return
		end

		local prompt, parteNpc = encontrarPromptNpcVenda()
		if not prompt or not parteNpc then
			warn("ProximityPrompt de 'Vender Minérios' não encontrado após sair do carro.")
			if estaAtivo(geracao) then
				entrarNoCarro(carro, assento)
				task.wait(0.05)
				teleporteLivre(destinoRetornoLevantado, carro)
				task.wait(CONFIG.EsperaCarregarMapa)
				sairDoCarro()
				task.wait(0.12)
				equiparPrimeiroSlot()
				task.wait(0.1)
			end
			return
		end

		voarDevagarAteNpc(parteNpc)
		if not estaAtivo(geracao) then
			return
		end
		task.wait(0.05)

		segurarAteAbrirMenuVenda(prompt, parteNpc)
		if not estaAtivo(geracao) then
			return
		end
		task.wait(0.08)

		for i = 1, #CONFIG.CoordenadasVender do
			if not estaAtivo(geracao) then
				return
			end
			local coord = CONFIG.CoordenadasVender[i]
			print("Clicando em Vender " .. i .. " (" .. coord.x .. ", " .. coord.y .. ")")
			clicarCoordenada(coord.x, coord.y)
			if i < #CONFIG.CoordenadasVender and estaAtivo(geracao) then
				task.wait(CONFIG.IntervaloCliqueVender)
			end
		end

		if not estaAtivo(geracao) then
			return
		end
		task.wait(CONFIG.IntervaloCliqueVender)

		if CONFIG.CoordenadaFecharX and estaAtivo(geracao) then
			print("Clicando no X (" .. CONFIG.CoordenadaFecharX.x .. ", " .. CONFIG.CoordenadaFecharX.y .. ")")
			clicarCoordenada(CONFIG.CoordenadaFecharX.x, CONFIG.CoordenadaFecharX.y)
			task.wait(0.08)
		end

		if not estaAtivo(geracao) then
			return
		end

		entrarNoCarro(carro, assento)
		task.wait(0.05)
		teleporteLivre(destinoRetornoLevantado, carro)
		task.wait(CONFIG.EsperaCarregarMapa)
		if not estaAtivo(geracao) then
			return
		end
		sairDoCarro()
		task.wait(0.12)
		equiparPrimeiroSlot()
		task.wait(0.1)
	end

	executarVendaERetorno()
	limparEstadoPersonagem()

	if estaAtivo(geracao) then
		print("Venda finalizada!")
	end
end
