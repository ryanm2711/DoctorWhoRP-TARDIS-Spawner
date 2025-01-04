TARDIS_SPAWNER_CONFIG = TARDIS_SPAWNER_CONFIG or {}

TARDIS_SPAWNER_CONFIG.Theme = {
    Body = Color(40, 45, 56),
    Primary = Color(45, 51, 63),
    Secondary = Color(31, 35, 43),
    Accent = Color(0, 195, 255),
    Accent2 = Color(0, 175, 228),
    Red = Color(224, 67, 67),
    Green = Color(90, 255, 68),
    Blue = Color(59, 126, 226),
    Text = Color(211, 211, 211),
    TextAccent = Color(255, 255, 255),
    Font = "Conthrax Sb",
    Roundness = 8
}

-- List of tardis IDs that are locked and cannot be spawned unless conditions are met
-- The key of the table has to be a valid TARDIS ID. To get a list of valid TARDIS IDs use this command in the console:
-- lua_run PrintTable(TARDIS.MetadataVersions)
TARDIS_SPAWNER_CONFIG.LockedTardises = {
    ["default"] = {
        --level = 5,
        --whitelistedTeams = {
            --[TEAM_MAYOR] = true
        --}
        --customCheck = function(tardis, ply)
            --return false, "Message to display to player here"
        --end
    }
}

-- This message will be displayed if the player does not meet the requirements to spawn a locked TARDIS and we do not have a specific reason why
TARDIS_SPAWNER_CONFIG.GenericLockedTardisMessage = "You do not meet the requirements to spawn this TARDIS."

TARDIS_SPAWNER_CONFIG.LevelLockedMessage = "You must be level %s to spawn this TARDIS."

TARDIS_SPAWNER_CONFIG.RestrictedJobMessage = "You are not the correct job to spawn this TARDIS."

TARDIS_SPAWNER_CONFIG.TARDISAddonNotInstalledMessage = "This weapon requires the TARDIS addon installed to function properly!"