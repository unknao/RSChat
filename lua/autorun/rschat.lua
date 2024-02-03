if SERVER then
	resource.AddSingleFile("resource/fonts/RS-Bold-12.ttf")
	return
end

local tag = "RSChat"
local bEnabled = CreateConVar("rschat_enabled", "1", {FCVAR_ARCHIVE}, "Enables RuneScape style overhead chat.")
local iTTL = CreateConVar("rschat_ttl", "3", {FCVAR_ARCHIVE}, "Sets the amount of time the overhead chat message is displayed for in seconds.", 1)
local fPadding = CreateConVar("rschat_padding", "19", {FCVAR_ARCHIVE}, "Sets the distance between the text and the players head.")
local fSize = CreateConVar("rschat_size", "1", {FCVAR_ARCHIVE}, "Sets the size of the overhead chat messages.")
local cChat, cChatShadow = Color(255, 255, 0), Color(25, 25, 0)

surface.CreateFont(tag, {
	font = "RuneScape Bold 12",
	size = 130,
	weight = 12,
	extended = true,
})

hook.Add("OnPlayerChat", tag, function(ply, text, isTeam)
	print(ply, text, isTeam)
	if not IsValid(ply) then return end
	if isTeam then return end

	ply.RSChat = text
	timer.Create("RSChatTTL_" .. ply:EntIndex(), iTTL:GetInt(), 1, function()
		ply.RSChat = nil
	end)
end)

hook.Add("PostDrawTranslucentRenderables", tag, function()
	if not bEnabled:GetBool() then return end

	for _, ply in ipairs(player.GetAll()) do
		if not ply.RSChat then continue end
		if ply:IsDormant() then continue end --Only draw for players in PVS
		if ply == LocalPlayer() and not ply:ShouldDrawLocalPlayer() then continue end --Don't draw on yourself if you can't see yourself

		local ePlayer = ply:GetRagdollEntity() == NULL and ply or ply:GetRagdollEntity()
		local iHead = ePlayer:LookupBone("ValveBiped.Bip01_Head1")
		if not iHead then continue end --If theres not a head, bail

		local vHead = ePlayer:GetBonePosition(iHead)
		if vHead == ePlayer:GetPos() then
			vHead = ePlayer:GetBoneMatrix(iHead)
		end

		local fScale = ply:GetModelScale() --take size into account
		local vHeadUp = ePlayer:GetUp()
		local vPos = vHead + vHeadUp * fPadding:GetFloat() * fScale
		local ang = EyeAngles()

		--necessary evil?
		ang:RotateAroundAxis(ang:Up(), -90)
		ang:RotateAroundAxis(ang:Forward(), 90)

		--rschat
		cam.Start3D2D(vPos, ang, 0.035 * fScale * fSize:GetFloat())
			draw.SimpleText(ply.RSChat, tag, 6, 6, cChatShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(ply.RSChat, tag, 0, 0, cChat, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		cam.End3D2D()
	end
end)