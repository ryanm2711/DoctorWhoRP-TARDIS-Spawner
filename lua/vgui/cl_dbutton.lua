local screenScale = ScreenScale

surface.CreateFont("TardisSpawner.ButtonTitle", {
    font = "Roboto",
    size = screenScale(4),
    weight = 700,
    antialias = true,
    shadow = false
})

local PANEL = {}

function PANEL:Init()
    self:SetText("")
    self:SetRoundness(TARDIS_SPAWNER_CONFIG.Theme.Roundness)

    --[[self.text = vgui.Create("DLabel", self)
    self.text:SetPos(0, 0)--]]
end

function PANEL:SetRoundness(roundness, bTopLeft, bTopRight, bBottomLeft, bBottomRight)
    self.roundness = roundness
    
    self.roundnessTopLeft = bTopLeft or true
    self.roundnessTopRight = bTopRight or true
    self.roundnessBottomLeft = bBottomLeft or true
    self.roundnessBottomRight = bBottomRight or true
end

function PANEL:SetColor(color)
    self.color = color
end

function PANEL:SetHoverColor(color)
    self.hoverColor = color
end

function PANEL:SetButtonText(text)
    self.text = text
end

function PANEL:SetButtonTextColor(color)
    self.buttonTextColor = color
end

function PANEL:SetButtonTextHoverColor(color)
    self.buttonTextHoverColor = color
end

function PANEL:SetFont(font)
    self.font = font
end

function PANEL:Paint(w, h)
    local color = self.color or TARDIS_SPAWNER_CONFIG.Theme.Secondary
    if self:IsHovered() then
        color = self.hoverColor or TARDIS_SPAWNER_CONFIG.Theme.Accent
    end
    draw.RoundedBoxEx(self.roundness or 0, 0, 0, w, h, color, self.roundnessTopLeft, self.roundnessTopRight, self.roundnessBottomLeft, self.roundnessBottomRight)

    local textColor = self.buttonTextColor or TARDIS_SPAWNER_CONFIG.Theme.Text
    if self:IsHovered() then
        textColor = self.buttonTextHoverColor or TARDIS_SPAWNER_CONFIG.Theme.TextAccent
    end
    draw.SimpleText(self.text, self.font or "TardisSpawner.ButtonTitle", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
derma.DefineControl("DoctorWhoRP.VGUI.Button", "", PANEL, "DButton")