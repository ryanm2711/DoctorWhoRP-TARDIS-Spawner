include("shared.lua")

surface.CreateFont("TARDIS_Spawner.Title", {
    font = "Roboto",
    size = ScreenScale(4),
    weight = 700,
    antialias = true,
    shadow = false
})

surface.CreateFont("TARDIS_Spawner.TardisTitle", {
    font = "Roboto",
    size = ScreenScale(3),
    weight = 700,
    antialias = true,
    shadow = false
})



local localPlayer = LocalPlayer
local isValid = IsValid
local vector = Vector
local renderSetModulationColor = render.SetColorModulation
local renderSetBlend = render.SetBlend
local screenScale = ScreenScale
local material = Material
local scrW = ScrW
local scrH = ScrH

local preview_model = ClientsideModel("models/molda/toyota_ext/exterior.mdl")
preview_model:SetMaterial("models/wireframe")
preview_model:SetNoDraw(true)

local tr = { collisiongroup = COLLISION_GROUP_WORLD, output = {} }

function util.IsInWorld( pos )
	tr.start = pos
	tr.endpos = pos

	return not util.TraceLine( tr ).HitWorld
end

local function IsOnGround(pos)
    local tr = util.TraceLine( {
        collisiongroup = COLLISION_GROUP_WORLD,
        start = pos,
        endpos = pos - Vector( 0, 0, 1 ),
    } )

    return tr.HitWorld, tr.HitPos
end

hook.Add("PostDrawOpaqueRenderables", "DoctorWhoRP.Weapons.TARDISSpawner.DrawPreviewModel", function()
    local ply = localPlayer()
    local swep = ply:GetActiveWeapon()

    if not isValid(swep) or swep:GetClass() ~= "weapon_tardis_spawner" then return end

    local isColliding = false
    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * swep.SpawnDistance.max,
        filter = function(ent)
            if ent:IsPlayer() or ent == ply then return false end
            isColliding = (ent ~= nil)
            return true
        end,
    })

    local pos = vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z)

    local ang = ply:EyeAngles()
    ang = Angle(0, ang.y - 180, 0)

    renderSetBlend(0.05)
    if pos:Distance(ply:GetPos()) >= swep.SpawnDistance.min and not isColliding and util.IsInWorld(pos) then
        renderSetModulationColor(0.8, 0.8, 0.8)
    else
        renderSetModulationColor(0.8, 0, 0)
    end    
    
    if IsOnGround(pos) then
        preview_model:SetRenderOrigin(pos)
        preview_model:SetRenderAngles(ang)
        --preview_model:SetModel(ply:GetModel())
        preview_model:DrawModel()
    end
end)

local PANEL = {}

function PANEL:Init()
    self.interiors = {}

    self.scrollbar = self:Add("DoctorWhoRP.VGUI.ScrollPanel")
    self.scrollbar:Dock(FILL)
    
    self.layout = self.scrollbar:Add("DIconLayout")
    self.layout:Dock(LEFT)
    self.layout:DockMargin(0, 7, 0, 0)
    self.layout:SetSpaceX(2)
    self.layout:SetSpaceY(2)
    self.layout:SetBorder(0)

    self.layout.Paint = function(me, w, h)
        draw.RoundedBox(TARDIS_SPAWNER_CONFIG.Theme.Roundness, 0, 0, w, h, TARDIS_SPAWNER_CONFIG.Theme.Primary)
    end

    if TARDIS then
        for k, v in pairs(TARDIS.MetadataRaw) do
            if v.Base == true or v.Hidden or v.IsVersionOf then continue end
            --if LocalPlayer():Team() ~= TEAM_RANI and v.ID == "rani" then continue end
            local hasAccess = TARDIS_SPAWNER_IsTardisAvailable(v.ID, LocalPlayer())
            if not hasAccess and TARDIS_SPAWNER_CONFIG.HideLockedTARDISInteriors then continue end
            self:AddInterior(v)
        end
    end
end

function PANEL:PerformLayout(w, h)
    self.layout:SetWide(w)
end

-- Taken from TARDIS addib
local function try_icon(filename)
    --if ent.IconOverride ~= nil then return end
    local fileFormats = {".vmt", ".vtf", ".jpg", ".png"}
    local mat = ""

    for _, format in pairs(fileFormats) do
        if file.Exists("materials/vgui/entities/" .. filename .. format, "GAME") then
            mat = "vgui/entities/" .. filename .. format
            break
        end
    end

    return mat
end

--[[local function try_int_icon(filename)
    if TARDIS.InteriorIcons[t.ID] ~= nil then return end
    if file.Exists("materials/vgui/entities/" .. filename, "GAME") then
        TARDIS.InteriorIcons[t.ID] = "vgui/entities/" .. filename
    end
end--]]

function PANEL:AddInterior(T)
    local pnl = self.layout:Add("DoctorWhoRP.VGUI.Panel")
    pnl:SetSize(150, 150)
    pnl:SetColor(TARDIS_SPAWNER_CONFIG.Theme.Primary)
    pnl:SetRoundness(0)
    pnl:AddHeader()
    pnl:HideCloseButton()
    pnl:SetHeaderHeight(20)

    local limit = 19
    local name = T.Name
    if string.len(T.Name) > limit then
        name = string.sub(T.Name, 1, limit) .. "..."
    end
    
    if name == "Interiors.Default" then
        name = "Default TARDIS"
    end
    pnl:SetTitle(name)
    pnl:SetTitleFont("TARDIS_Spawner.Title")
    pnl:SetTitlePos(0, 0.25)

    local btn = pnl:Add("DoctorWhoRP.VGUI.Button")
    btn:Dock(FILL)
    btn:DockMargin(2, 2, 2, 2)
    btn:SetFont("TARDIS_Spawner.TardisTitle")

    btn.DoClick = function(me)
        self:Remove()

        if #TARDIS.MetadataVersions[T.ID].list_original > 1 then -- If tardis has interiors
            local pnl = vgui.Create("DoctorWhoRP.VGUI.TardisSpawnerIntVersionsSelect")
            pnl:SetSize(scrW() * 0.2, scrH() * 0.7)
            pnl:Center()
            pnl:MakePopup()
            pnl:AddHeader()

            local versions = {}
            for k, version in pairs(TARDIS.MetadataVersions[T.ID].list_original) do
                if k == "main" then continue end
                versions[k] = version
            end

            pnl:SetupVersions(versions)
        else
            hook.Run("DoctorWhoRP.Weapons.TARDISSpawner_SelectInterior", T.ID, T.Name)
        end
    end

    local iconMat = ""
    iconMat = try_icon("tardis/" .. T.ID)

    if iconMat == "" then
        iconMat = try_icon("tardis/default/" .. T.ID)
    end

    if iconMat == "" then
        iconMat = try_icon("tardis/interiors/" .. T.ID)
    end

    if iconMat == "" then
        iconMat = try_icon("tardis/interiors/default/" .. T.ID)
    end

    if iconMat == "" then
        iconMat = "vgui/entities/gmod_tardis.vmt"
    end

    btn.Paint = function(me, w, h)
        local mat = iconMat
        if me:IsHovered() then
            mat = TARDIS.InteriorIcons[T.ID] or iconMat
        end

        if mat ~= "" then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(material(mat))
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end

    self.interiors[#self.interiors + 1] = pnl
end

function PANEL:SetSelectedInterior(ID)
    self.selectedInterior = ID
    net.Start("DoctorWhoRP.Weapons.SelectInteriorTardisSpawner")
        net.WriteString(ID)
    net.SendToServer()
end
vgui.Register("DoctorWhoRP.VGUI.TardisSpawnerIntSelect", PANEL, "DoctorWhoRP.VGUI.Panel")

PANEL = {}

function PANEL:Init()
    self.versions = {}
    self.versionBtns = {}

    self.scrollbar = self:Add("DoctorWhoRP.VGUI.ScrollPanel")
    self.scrollbar:Dock(FILL)
    self.scrollbar:DisableButtons()
end

function PANEL:SetupVersions(tbl)
    self.versions = tbl
    
    for k, v in pairs(self.versions) do
        PrintTable(v)
        self.versionBtns[k] = self.scrollbar:Add("DoctorWhoRP.VGUI.Button")
        local btn = self.versionBtns[k]
        btn:Dock(TOP)
        btn:DockMargin(0, 2, 0, 2)
        btn:SetButtonText(v.name)

        local ID = ""
        if v.id then
            ID = v.id
        elseif v.classic_doors_id then -- Support for 1963 TARDIS because it doesn't follow the pattern
            ID = v.classic_doors_id
        elseif v.double_doors_id then
            ID = v.double_doors_id
        end

        btn.DoClick = function(me)
            hook.Run("DoctorWhoRP.Weapons.TARDISSpawner_SelectInterior", ID, v.name)
            self:Remove()
        end
    end
end
vgui.Register("DoctorWhoRP.VGUI.TardisSpawnerIntVersionsSelect", PANEL, "DoctorWhoRP.VGUI.Panel")

hook.Add("DoctorWhoRP.Weapons.TARDISSpawner_SelectInterior", "DoctorWhoRP.Weapons.TardisSpawner_SendToSwep", function(ID, name)
    net.Start("DoctorWhoRP.Weapons.SelectInteriorTardisSpawner")
        net.WriteString(ID)
    net.SendToServer()

    notification.AddLegacy("[TARDIS] Selected " .. name, NOTIFY_GENERIC, 5)
end)