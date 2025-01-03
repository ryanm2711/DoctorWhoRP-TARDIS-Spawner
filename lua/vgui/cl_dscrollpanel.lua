local PANEL = {}

function PANEL:Init()
    self.vbar = self:GetVBar()

    self.vbar.Paint = function(me, w, h)
        draw.RoundedBox(TARDIS_SPAWNER_CONFIG.Theme.Roundness, 0, 0, w, h, TARDIS_SPAWNER_CONFIG.Theme.Secondary)
    end

    self.vbar.btnGrip.Paint = function(me, w, h)
        local color = TARDIS_SPAWNER_CONFIG.Theme.Primary
        if me:IsHovered() or me.Depressed then
            color = TARDIS_SPAWNER_CONFIG.Theme.Accent
        end
        draw.RoundedBox(TARDIS_SPAWNER_CONFIG.Theme.Roundness, 0, 0, w, h, color)
    end
end

function PANEL:DisableButtons()
    self.vbar:SetHideButtons(true)
end

--[[function PANEL:Paint(w, h)

end--]]
derma.DefineControl("DoctorWhoRP.VGUI.ScrollPanel", "", PANEL, "DScrollPanel")