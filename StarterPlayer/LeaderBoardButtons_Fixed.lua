-- LeaderBoardButtons (Versión Mejorada - Sin Error P1)
-- REEMPLAZA el LeaderBoardButtons original con este código
-- Ubicación: StarterPlayer > StarterPlayerScripts > LeaderBoardButtons

local boards = workspace:WaitForChild("DonoBoard")
local pagenumbers = {}

function changepage(part,number)
  for i,v in pairs(part.SurfaceGui.MainFrame.Pages:GetChildren()) do
    v.Visible = false
  end

  -- Esperar a que la página exista antes de hacerla visible
  local page = part.SurfaceGui.MainFrame.Pages:WaitForChild("P"..number, 10)

  if page then
    page.Visible = true

    -- Verificar que los elementos del footer existan
    local footer = part.SurfaceGui.MainFrame.Footer
    local pageNumbers = footer:FindFirstChild("PageNumbers")
    if pageNumbers and pageNumbers:FindFirstChild("pagumber") then
      local textLabel = pageNumbers.pagumber:FindFirstChild("TextLabel")
      if textLabel then
        textLabel.Text = "Page: "..number
      end
    end
  else
    warn("⚠️ La página P"..number.." no existe o no se creó a tiempo")
  end
end

pagenumbers[boards.Name] = {}
local screen = boards:WaitForChild("Screen")

-- ====================================
-- CONFIGURACIÓN DE SCREEN (PANTALLA)
-- ====================================
if screen.SurfaceGui.MainFrame:FindFirstChild("Pages") and
	screen.SurfaceGui.MainFrame.Footer:FindFirstChild('PageNumbers') then
  pagenumbers[boards.Name]["Screen"] = 1
  local pagenumber = boards.Screen.SurfaceGui.MainFrame.Footer.PageNumbers

  -- ESPERAR A QUE P1 EXISTA antes de cambiar de página
  boards.Screen.SurfaceGui.MainFrame.Pages:WaitForChild("P1", 10)
  changepage(boards.Screen,pagenumbers[boards.Name]["Screen"])

  pagenumber.Pre.Activated:Connect(function()
    if pagenumbers[boards.Name]["Screen"] > 1 then
      pagenumbers[boards.Name]["Screen"] -= 1
    elseif pagenumbers[boards.Name]["Screen"] == 1 then
      pagenumbers[boards.Name]["Screen"] = #boards.Screen.SurfaceGui.MainFrame.Pages:GetChildren()
    end
    changepage(boards.Screen,pagenumbers[boards.Name]["Screen"])
  end)

  pagenumber.Net.Activated:Connect(function()
    if pagenumbers[boards.Name]["Screen"] < #boards.Screen.SurfaceGui.MainFrame.Pages:GetChildren()then
      pagenumbers[boards.Name]["Screen"] += 1
    elseif pagenumbers[boards.Name]["Screen"] == #boards.Screen.SurfaceGui.MainFrame.Pages:GetChildren() then
      pagenumbers[boards.Name]["Screen"] = 1
    end
    changepage(boards.Screen,pagenumbers[boards.Name]["Screen"])
  end)
end

-- ====================================
-- CONFIGURACIÓN DE BUTTONS (BOTONES)
-- ====================================
if boards.Buttons.SurfaceGui.MainFrame:FindFirstChild("Pages") and
   boards.Buttons.SurfaceGui.MainFrame.Footer:FindFirstChild('PageNumbers') then
  pagenumbers[boards.Name]["Button"] = 1
  local pagenumber = boards.Buttons.SurfaceGui.MainFrame.Footer.PageNumbers

  -- ESPERAR A QUE P1 EXISTA antes de cambiar de página
  boards.Buttons.SurfaceGui.MainFrame.Pages:WaitForChild("P1", 10)
  changepage(boards.Buttons,pagenumbers[boards.Name]["Button"])

  pagenumber.Pre.Activated:Connect(function()
    if pagenumbers[boards.Name]["Button"] > 1 then
      pagenumbers[boards.Name]["Button"] -= 1
    elseif pagenumbers[boards.Name]["Button"] == 1 then
      pagenumbers[boards.Name]["Button"] = #boards.Buttons.SurfaceGui.MainFrame.Pages:GetChildren()
    end
    changepage(boards.Buttons,pagenumbers[boards.Name]["Button"])
  end)

  pagenumber.Net.Activated:Connect(function()
    if pagenumbers[boards.Name]["Button"] < #boards.Buttons.SurfaceGui.MainFrame.Pages:GetChildren()then
      pagenumbers[boards.Name]["Button"] += 1
    elseif pagenumbers[boards.Name]["Button"] == #boards.Buttons.SurfaceGui.MainFrame.Pages:GetChildren() then
      pagenumbers[boards.Name]["Button"] = 1
    end
    changepage(boards.Buttons,pagenumbers[boards.Name]["Button"])
  end)
end

-- ====================================
-- CONFIGURACIÓN DE PRODUCTOS
-- ====================================
if boards:FindFirstChild("Products") then
  local productsmodule = require(boards.Products)
  local products = productsmodule.Products
  boards.Screen.SurfaceGui.MainFrame.Footer.TakeModel.Activated:Connect(function()
    game:GetService("MarketplaceService"):PromptPurchase(game.Players.LocalPlayer,8482978293)
  end)

  if boards.Buttons.SurfaceGui.MainFrame:FindFirstChild("Pages") then
    for _,page in pairs(boards.Buttons.SurfaceGui.MainFrame.Pages:GetChildren()) do
      for _,v in pairs(page:GetChildren()) do
        if v:IsA("TextButton") then
          v.Activated:Connect(function()
            boards.MainScript.UpdateplayerDonoStats:FireServer(v.Name)
          end)
        end
      end
    end
  else
    for i,v in pairs(boards.Buttons.SurfaceGui.MainFrame.Scroll:GetChildren()) do
      if v:IsA("TextButton") then
        v.Activated:Connect(function()
          boards.MainScript.UpdateplayerDonoStats:FireServer(v.Name)
        end)
      end
    end
  end
end

print("✅ LeaderBoardButtons cargado correctamente (versión mejorada)")
