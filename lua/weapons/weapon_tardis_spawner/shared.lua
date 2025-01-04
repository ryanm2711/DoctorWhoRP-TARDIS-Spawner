AddCSLuaFile()

if SERVER then
    AddCSLuaFile("cl_init.lua")
    util.AddNetworkString("DoctorWhoRP.Weapons.SelectInteriorTardisSpawner")
end

SWEP.PrintName = "TARDIS Spawner"
SWEP.Author = "ryanm2711"
SWEP.Instructions = "Choose an area that is valid, then left click to spawn a TARDIS. Right click to choose interior"
SWEP.Category = "ryanm2711"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 1
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false

SWEP.ViewModel			= ""
SWEP.WorldModel			= ""

SWEP.SpawnDistance = {min=50, max=200}

local function IsTardisSpawnedAlready(ply)
    local isExisting = false
    local ent
    for k, v in ipairs(ents.FindByClass("gmod_tardis")) do
        if v:IsValid() and (v:GetOwner() == ply or v:CPPIGetOwner() == ply) then
            isExisting = true
            ent = v
            break
        end
    end

    return isExisting, ent
end

function SWEP:SetupDataTables()
    self:NetworkVar("String", 0, "Interior")
end

function TARDIS_SPAWNER_IsTardisAvailable(tardis, ply)
    local lockedConfig = TARDIS_SPAWNER_CONFIG.LockedTardises[type(tardis) == "string" and tardis or tardis.metadata.ID]

    if lockedConfig then
        if lockedConfig.whitelistedTeams then
            if not lockedConfig.whitelistedTeams[ply:Team()] then
                return false, TARDIS_SPAWNER_CONFIG.RestrictedJobMessage
            end
        end

        if lockedConfig.level then
            local plyLevel = 0
            -- Vrondakis level system
            if LevelSystemConfiguration and DarkRP then
                plyLevel = ply:getDarkRPVar("level")
            end

            if plyLevel < lockedConfig.level then
                return false, string.format(TARDIS_SPAWNER_CONFIG.LevelLockedMessage, lockedConfig.level)
            end
        end

        if lockedConfig.customCheck then
            local result, msg = lockedConfig.customCheck(tardis, ply)
            return result, msg
        end
    end

    return true
end

function SWEP:SpawnTARDIS(pos)
    --[[local ent = ents.Create("gmod_tardis")
    ent:SetPos(pos)
    ent:Spawn()--]]
    local alreadySpawned = IsTardisSpawnedAlready(self:GetOwner())
    if alreadySpawned then return end
    if not util.IsInWorld(pos) then return end

    --local TARDISID = GetConVar("tardis2_selected_interior")
    local TARDIS_ID = self:GetInterior() or "default"

    local hasAccess, reason = TARDIS_SPAWNER_IsTardisAvailable(TARDIS_ID, self:GetOwner())
    if not hasAccess then
        self:GetOwner():PrintMessage(HUD_PRINTTALK, reason or TARDIS_SPAWNER_CONFIG.GenericLockedTardisMessage)
        return
    end

    --if TARDISID == nil then TARDISID = "default" end
    local ent = TARDIS:SpawnTARDIS(self:GetOwner(), {
        pos = pos,
        metadataID = TARDIS_ID,
    })

    if ent ~= nil then
        ent.SpawnedBySpawner = true
    end

    return ent
end

local function IsOnGround(pos)
    local tr = util.TraceLine( {
        collisiongroup = COLLISION_GROUP_WORLD,
        start = pos,
        endpos = pos - Vector( 0, 0, 1 ),
    } )

    return tr.HitWorld, tr.HitPos
end

function SWEP:GetValidPosition()
    local ply = self:GetOwner()

    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * self.SpawnDistance.max,
        filter = function(ent) return (not ent:IsPlayer() and ent ~= ply) end
    })

    return tr.HitPos, (IsOnGround(tr.HitPos) and tr.HitPos:Distance(ply:GetPos()) >= self.SpawnDistance.min)
end

function SWEP:Deploy()
    if IsFirstTimePredicted() and CLIENT and TARDIS then
        self:GetOwner():PrintMessage(HUD_PRINTTALK, TARDIS_SPAWNER_CONFIG.TARDISAddonNotInstalledMessage)
    end
end

function SWEP:PrimaryAttack()
    if IsFirstTimePredicted() and SERVER then
        if not TARDIS then
            self:GetOwner():PrintMessage(HUD_PRINTTALK, TARDIS_SPAWNER_CONFIG.TARDISAddonNotInstalledMessage)
            return
        end
        
        local pos, validPos = self:GetValidPosition()

        if validPos then
            local ent = self:SpawnTARDIS(pos)
            if ent ~= nil then
                self:Remove()
            end
        end
    end
end

function SWEP:SecondaryAttack()
    if IsFirstTimePredicted() and CLIENT then
        if not TARDIS then
            LocalPlayer():PrintMessage(HUD_PRINTTALK, TARDIS_SPAWNER_CONFIG.TARDISAddonNotInstalledMessage)
            return
        end
        
        local pnl = vgui.Create("DoctorWhoRP.VGUI.TardisSpawnerIntSelect")
        pnl:SetSize(ScrW() * 0.4, ScrH() * 0.5)
        pnl:Center()
        pnl:AddHeader()
        pnl:SetTitle("SELECT AN INTERIOR")
        pnl:MakePopup()
    end
end

if SERVER then
    hook.Add("CanUndo", "DoctorWhoRP.Weapons.TARDISSpawnerBlockUndo", function(ply, undo)
        local shouldNotBlock = true
        if undo.Entities ~= nil then
            for _, v in pairs(undo.Entities) do
                if not v:IsValid() or v:GetClass() ~= "gmod_tardis" then continue end
                if v.SpawnedBySpawner then
                    shouldNotBlock = false 
                    break
                end
            end
        end

        if not shouldNotBlock then return false end
    end)

    hook.Add("PlayerSpawnedSENT", "DoctorWhoRP.Weapons.AddRedecorateToList", function(ply, ent)
        if ent:GetClass() == "gmod_tardis" then
            ent.SpawnedBySpawner = true

            local hasAccess, reason = TARDIS_SPAWNER_IsTardisAvailable(ent, ply)
            if not hasAccess then
                ply:PrintMessage(HUD_PRINTTALK, reason or TARDIS_SPAWNER_CONFIG.GenericLockedTardisMessage)
                timer.Simple(1, function()
                    ent:Remove()
                end)
                return
            end

            ent:RemoveHook("CanToggleRedecoration", "DoctorWhoRP.Weapons.PreventLockedTARDISRedecorate")
            ent:AddHook("CanToggleRedecoration", "DoctorWhoRP.Weapons.PreventLockedTARDISRedecorate", function(self, on)
                local ply = self:GetCreator()
                local chosen_int = TARDIS:GetSetting("redecorate-interior", ply)
                local hasAccess, reason = TARDIS_SPAWNER_IsTardisAvailable(chosen_int, ply)
                if not hasAccess then
                    ply:PrintMessage(HUD_PRINTTALK, reason or TARDIS_SPAWNER_CONFIG.GenericLockedTardisMessage)
                    return false
                end
            end)
        end
    end)

    local function CleanupTardisSpawn(ply)
        local existing, ent = IsTardisSpawnedAlready(ply)
        if existing and ent ~= nil then
            ent:Remove()
        end
    end
    hook.Add("PlayerChangedTeam", "DoctorWhoRP.Weapons.CleanupSpawnedTardis", CleanupTardisSpawn)
    hook.Add("PlayerDisconnected", "DoctorWhoRP.Weapons.CleanupSpawnedTardis", CleanupTardisSpawn)


    --[[hook.Add("PlayerSpawn", "DoctorWhoRP.Weapons.TARDISSpawnerGiveWep", function(ply)
        if DoctorWhoRP.Config.TardisSpawner.ValidTeams[ply:Team()] and not IsTardisSpawnedAlready(ply) then 
            ply:Give("weapon_tardis_spawner")
        end
    end)--]]

    net.Receive("DoctorWhoRP.Weapons.SelectInteriorTardisSpawner", function(len, ply)
        local ID = net.ReadString()
        local swep = ply:GetActiveWeapon()
        if IsValid(swep) and swep:GetClass() == "weapon_tardis_spawner" then
            swep:SetInterior(ID)
        end
    end)
end