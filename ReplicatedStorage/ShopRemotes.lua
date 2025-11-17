-- ReplicatedStorage > ShopRemotes
-- Este módulo contiene referencias a todos los RemoteEvents necesarios para el sistema de compras

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear carpeta para los RemoteEvents si no existe
local RemotesFolder = ReplicatedStorage:FindFirstChild("ShopRemotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "ShopRemotes"
	RemotesFolder.Parent = ReplicatedStorage
end

-- Crear RemoteEvents necesarios
local function createRemoteEvent(name)
	local remote = RemotesFolder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = RemotesFolder
	end
	return remote
end

-- RemoteEvents para el sistema
local PurchaseGamepass = createRemoteEvent("PurchaseGamepass")
local PurchaseDeveloperProduct = createRemoteEvent("PurchaseDeveloperProduct")
local CheckGamepassOwnership = createRemoteEvent("CheckGamepassOwnership")

return {
	PurchaseGamepass = PurchaseGamepass,
	PurchaseDeveloperProduct = PurchaseDeveloperProduct,
	CheckGamepassOwnership = CheckGamepassOwnership
}
