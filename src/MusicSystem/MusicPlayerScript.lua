--[[
	MusicPlayerScript.lua - Sistema Completo de Música para Roblox

	INSTRUCCIONES DE INSTALACIÓN:
	1. Este script debe ir en StarterPlayer > StarterPlayerScripts como LocalScript
	2. El SongsConfig.lua debe estar en ReplicatedStorage
	3. Los objetos Sound se crearán automáticamente en SoundService

	CARACTERÍSTICAS:
	- UI en esquina inferior izquierda con nombre de canción actual
	- Botón para pausar/reanudar música
	- Panel selector de canciones
	- Actualización automática de UI
	- Compatible con audios de la Toolbox
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar a que cargue la configuración de canciones
local SongsConfig = ReplicatedStorage:WaitForChild("SongsConfig")
local songsData = require(SongsConfig)

-- Variables globales
local currentSongIndex = songsData.DefaultSong
local currentSound = nil
local isPlaying = true
local isSelectorOpen = false

-- Referencias a elementos de UI (se crearán dinámicamente)
local musicPlayerUI = nil
local songNameLabel = nil
local playPauseButton = nil
local playPauseIcon = nil
local selectorButton = nil
local songSelectorPanel = nil
local songListFrame = nil

-- ==================== CREACIÓN DE UI ====================

local function createMusicPlayerUI()
	-- ScreenGui principal
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MusicPlayerUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Frame principal (esquina inferior izquierda)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 300, 0, 80)
	mainFrame.Position = UDim2.new(0, 20, 1, -100)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	-- Esquinas redondeadas
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

	-- Sombra/borde
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 70)
	stroke.Thickness = 2
	stroke.Parent = mainFrame

	-- Icono de música (decorativo)
	local musicIcon = Instance.new("TextLabel")
	musicIcon.Name = "MusicIcon"
	musicIcon.Size = UDim2.new(0, 40, 0, 40)
	musicIcon.Position = UDim2.new(0, 10, 0.5, -20)
	musicIcon.BackgroundTransparency = 1
	musicIcon.Text = "🎵"
	musicIcon.TextSize = 28
	musicIcon.Font = Enum.Font.GothamBold
	musicIcon.Parent = mainFrame

	-- Label del nombre de la canción
	local songLabel = Instance.new("TextLabel")
	songLabel.Name = "SongNameLabel"
	songLabel.Size = UDim2.new(1, -120, 0, 30)
	songLabel.Position = UDim2.new(0, 55, 0, 10)
	songLabel.BackgroundTransparency = 1
	songLabel.Text = "Cargando..."
	songLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	songLabel.TextSize = 16
	songLabel.Font = Enum.Font.GothamBold
	songLabel.TextXAlignment = Enum.TextXAlignment.Left
	songLabel.TextTruncate = Enum.TextTruncate.AtEnd
	songLabel.Parent = mainFrame

	-- Botón Play/Pause
	local ppButton = Instance.new("TextButton")
	ppButton.Name = "PlayPauseButton"
	ppButton.Size = UDim2.new(0, 40, 0, 40)
	ppButton.Position = UDim2.new(1, -90, 0.5, -20)
	ppButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	ppButton.BorderSizePixel = 0
	ppButton.Text = ""
	ppButton.Parent = mainFrame

	local ppCorner = Instance.new("UICorner")
	ppCorner.CornerRadius = UDim.new(0, 8)
	ppCorner.Parent = ppButton

	local ppIcon = Instance.new("TextLabel")
	ppIcon.Name = "Icon"
	ppIcon.Size = UDim2.new(1, 0, 1, 0)
	ppIcon.BackgroundTransparency = 1
	ppIcon.Text = "⏸️"
	ppIcon.TextSize = 20
	ppIcon.Font = Enum.Font.GothamBold
	ppIcon.Parent = ppButton

	-- Botón de selector de canciones
	local selectorBtn = Instance.new("TextButton")
	selectorBtn.Name = "SelectorButton"
	selectorBtn.Size = UDim2.new(0, 40, 0, 40)
	selectorBtn.Position = UDim2.new(1, -45, 0.5, -20)
	selectorBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
	selectorBtn.BorderSizePixel = 0
	selectorBtn.Text = ""
	selectorBtn.Parent = mainFrame

	local selectorCorner = Instance.new("UICorner")
	selectorCorner.CornerRadius = UDim.new(0, 8)
	selectorCorner.Parent = selectorBtn

	local selectorIcon = Instance.new("TextLabel")
	selectorIcon.Size = UDim2.new(1, 0, 1, 0)
	selectorIcon.BackgroundTransparency = 1
	selectorIcon.Text = "📜"
	selectorIcon.TextSize = 18
	selectorIcon.Font = Enum.Font.GothamBold
	selectorIcon.Parent = selectorBtn

	-- Panel selector de canciones (inicialmente invisible)
	local selectorPanel = Instance.new("Frame")
	selectorPanel.Name = "SongSelectorPanel"
	selectorPanel.Size = UDim2.new(0, 320, 0, 400)
	selectorPanel.Position = UDim2.new(0, 20, 0.5, -200)
	selectorPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	selectorPanel.BorderSizePixel = 0
	selectorPanel.Visible = false
	selectorPanel.Parent = screenGui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 12)
	panelCorner.Parent = selectorPanel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Color = Color3.fromRGB(70, 130, 220)
	panelStroke.Thickness = 3
	panelStroke.Parent = selectorPanel

	-- Título del panel
	local panelTitle = Instance.new("TextLabel")
	panelTitle.Name = "Title"
	panelTitle.Size = UDim2.new(1, -20, 0, 40)
	panelTitle.Position = UDim2.new(0, 10, 0, 10)
	panelTitle.BackgroundTransparency = 1
	panelTitle.Text = "🎵 Selecciona una Canción"
	panelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	panelTitle.TextSize = 20
	panelTitle.Font = Enum.Font.GothamBold
	panelTitle.TextXAlignment = Enum.TextXAlignment.Left
	panelTitle.Parent = selectorPanel

	-- Botón cerrar
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -40, 0, 10)
	closeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "✕"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 18
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = selectorPanel

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeButton

	-- Frame para la lista de canciones con scroll
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "SongListFrame"
	scrollFrame.Size = UDim2.new(1, -20, 1, -70)
	scrollFrame.Position = UDim2.new(0, 10, 0, 60)
	scrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = selectorPanel

	local scrollCorner = Instance.new("UICorner")
	scrollCorner.CornerRadius = UDim.new(0, 8)
	scrollCorner.Parent = scrollFrame

	-- Layout para organizar las canciones
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = scrollFrame

	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 8)
	listPadding.PaddingBottom = UDim.new(0, 8)
	listPadding.PaddingLeft = UDim.new(0, 8)
	listPadding.PaddingRight = UDim.new(0, 8)
	listPadding.Parent = scrollFrame

	-- Guardar referencias
	musicPlayerUI = screenGui
	songNameLabel = songLabel
	playPauseButton = ppButton
	playPauseIcon = ppIcon
	selectorButton = selectorBtn
	songSelectorPanel = selectorPanel
	songListFrame = scrollFrame

	return screenGui, closeButton
end

-- ==================== CREACIÓN DE BOTONES DE CANCIONES ====================

local function createSongButton(songData, index)
	local button = Instance.new("TextButton")
	button.Name = "Song_" .. index
	button.Size = UDim2.new(1, -16, 0, 50)
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = songListFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	-- Indicador de canción actual
	local indicator = Instance.new("Frame")
	indicator.Name = "CurrentIndicator"
	indicator.Size = UDim2.new(0, 4, 1, -10)
	indicator.Position = UDim2.new(0, 5, 0, 5)
	indicator.BackgroundColor3 = Color3.fromRGB(70, 220, 100)
	indicator.BorderSizePixel = 0
	indicator.Visible = (index == currentSongIndex)
	indicator.Parent = button

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(1, 0)
	indicatorCorner.Parent = indicator

	-- Número de canción
	local numberLabel = Instance.new("TextLabel")
	numberLabel.Size = UDim2.new(0, 30, 1, 0)
	numberLabel.Position = UDim2.new(0, 15, 0, 0)
	numberLabel.BackgroundTransparency = 1
	numberLabel.Text = tostring(index)
	numberLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
	numberLabel.TextSize = 18
	numberLabel.Font = Enum.Font.GothamBold
	numberLabel.Parent = button

	-- Nombre de la canción
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -60, 1, 0)
	nameLabel.Position = UDim2.new(0, 50, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = songData.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 16
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = button

	-- Efecto hover
	button.MouseEnter:Connect(function()
		if index ~= currentSongIndex then
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(60, 60, 70)
			}):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		if index ~= currentSongIndex then
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(45, 45, 50)
			}):Play()
		end
	end)

	-- Click para seleccionar canción
	button.MouseButton1Click:Connect(function()
		changeSong(index)
	end)

	return button, indicator
end

-- ==================== FUNCIONES DE CONTROL DE MÚSICA ====================

local function createSound(songData)
	-- Eliminar sonido anterior si existe
	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
	end

	-- Crear nuevo sonido en SoundService
	local sound = Instance.new("Sound")
	sound.Name = "MusicPlayer_" .. songData.Name
	sound.SoundId = songData.AssetId
	sound.Volume = songsData.DefaultVolume
	sound.Looped = true
	sound.Parent = SoundService

	return sound
end

local function updateUI()
	local currentSong = songsData.Songs[currentSongIndex]
	songNameLabel.Text = currentSong.Name

	-- Actualizar indicadores en la lista
	for i, child in pairs(songListFrame:GetChildren()) do
		if child:IsA("TextButton") then
			local indicator = child:FindFirstChild("CurrentIndicator")
			if indicator then
				local songIndex = tonumber(child.Name:match("%d+"))
				if songIndex == currentSongIndex then
					indicator.Visible = true
					child.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
				else
					indicator.Visible = false
					child.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
				end
			end
		end
	end
end

local function playSong()
	if currentSound then
		currentSound:Play()
		isPlaying = true
		playPauseIcon.Text = "⏸️"
	end
end

local function pauseSong()
	if currentSound then
		currentSound:Pause()
		isPlaying = false
		playPauseIcon.Text = "▶️"
	end
end

function changeSong(newIndex)
	if newIndex < 1 or newIndex > #songsData.Songs then
		warn("Índice de canción inválido:", newIndex)
		return
	end

	currentSongIndex = newIndex
	local songData = songsData.Songs[currentSongIndex]

	-- Crear y reproducir nueva canción
	currentSound = createSound(songData)
	updateUI()
	playSong()

	print("Reproduciendo:", songData.Name)
end

-- ==================== EVENTOS DE BOTONES ====================

local function setupButtons(closeButton)
	-- Botón Play/Pause
	playPauseButton.MouseButton1Click:Connect(function()
		if isPlaying then
			pauseSong()
		else
			playSong()
		end
	end)

	-- Botón abrir selector
	selectorButton.MouseButton1Click:Connect(function()
		isSelectorOpen = not isSelectorOpen
		songSelectorPanel.Visible = isSelectorOpen

		if isSelectorOpen then
			-- Animación de apertura
			songSelectorPanel.Size = UDim2.new(0, 0, 0, 0)
			songSelectorPanel.Visible = true
			TweenService:Create(songSelectorPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
				Size = UDim2.new(0, 320, 0, 400)
			}):Play()
		else
			-- Animación de cierre
			TweenService:Create(songSelectorPanel, TweenInfo.new(0.2), {
				Size = UDim2.new(0, 0, 0, 0)
			}):Play()
			task.wait(0.2)
			songSelectorPanel.Visible = false
		end
	end)

	-- Botón cerrar selector
	closeButton.MouseButton1Click:Connect(function()
		isSelectorOpen = false
		TweenService:Create(songSelectorPanel, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		task.wait(0.2)
		songSelectorPanel.Visible = false
	end)
end

-- ==================== INICIALIZACIÓN ====================

local function initialize()
	print("🎵 Inicializando Sistema de Música...")

	-- Crear UI
	local screenGui, closeButton = createMusicPlayerUI()
	print("✅ UI creada correctamente")

	-- Crear botones de canciones
	for i, songData in ipairs(songsData.Songs) do
		createSongButton(songData, i)
	end
	print("✅ Botones de canciones creados:", #songsData.Songs)

	-- Ajustar tamaño del scroll frame
	songListFrame.CanvasSize = UDim2.new(0, 0, 0, (#songsData.Songs * 58) + 16)

	-- Configurar eventos de botones
	setupButtons(closeButton)
	print("✅ Eventos configurados")

	-- Iniciar con la canción por defecto
	changeSong(currentSongIndex)
	print("✅ Sistema de Música iniciado correctamente")
	print("🎵 Reproduciendo:", songsData.Songs[currentSongIndex].Name)
end

-- Esperar un momento antes de inicializar (para que cargue todo)
task.wait(0.5)
initialize()
