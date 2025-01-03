surface.CreateFont("TardisSpawner.CloseBtn", {
    font = "Roboto",
    size = ScreenScale(4),
    weight = 500,
    antialias = true,
    shadow = false
})

surface.CreateFont("TardisSpawner.PanelTitle", {
    font = "Roboto",
    size = ScreenScale(8),
    weight = 700,
    antialias = true,
    shadow = false
})
local PANEL = {}

function PANEL:Init()
    self:SetRoundness(TARDIS_SPAWNER_CONFIG.Theme.Roundness)
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

function PANEL:AddHeader()
    self.header = self:Add("DoctorWhoRP.VGUI.Panel")
    self.header:Dock(TOP)
    self.header:SetColor(TARDIS_SPAWNER_CONFIG.Theme.Secondary)
    self.header:SetRoundness(self.roundness, false, false, false, false)

    self.closeBtn = self.header:Add("DoctorWhoRP.VGUI.Button")
    self.closeBtn:Dock(RIGHT)
    self.closeBtn:DockMargin(0, 0, 0, 0)
    self.closeBtn:SetButtonText("X")
    self.closeBtn:SetHoverColor(Color(0, 0, 0, 0))
    self.closeBtn:SetButtonTextHoverColor(TARDIS_SPAWNER_CONFIG.Theme.Red)
    self.closeBtn:SetFont("TardisSpawner.CloseBtn")
    self.closeBtn.DoClick = function(me)
        self:Remove()
    end
    
    self.title = self.header:Add("DLabel")
    self.title:Dock(LEFT)
    self.title:DockMargin(5, 0, 0, 0)
    self.title:SetText("")
    self.title:SetFont("TardisSpawner.PanelTitle")
    self.title:SetTextColor(TARDIS_SPAWNER_CONFIG.Theme.Text)
end

function PANEL:HideCloseButton()
    if self.closeBtn then
        self.closeBtn:SetVisible(false)
    end
end

--[[function PANEL:SizeToContents() CURRENTLY BROKEN
    local pnls = self:GetChildren()
    local w = self:GetWide()
    local h = self:GetTall()

    self.actualWidth = 0
    self.actualHeight = 0

    for _, pnl in pairs(pnls) do
        if pnl == self.header or pnl == self.closeBtn then continue end
        local pnlW, pnlH = pnl:GetSize()

        self.actualWidth = self.actualWidth + pnlW
        self.actualHeight = self.actualHeight + pnlH
    end

    self:SetSize(self.actualWidth, self.actualHeight)
end--]]

function PANEL:SetTitle(str)
    self.title:SetText(str)
    self.title:SizeToContents()
end

function PANEL:SetTitleFont(font)
    self.title:SetFont(font)
    self.title:SizeToContents()
end

function PANEL:SetTitleColor(clr)
    self.title:SetTextColor(clr)
end

function PANEL:SetHeaderHeight(h)
    self.header:SetTall(h)
    self:InvalidateLayout()
end

function PANEL:SetTitlePos(x, y)
    if self.title then
        self.title:SetPos(x * self.header:GetWide(), y * self.header:GetTall())
        self:InvalidateLayout()
    end
end

function PANEL:PerformLayout(w, h)
    --self.header:SetTall(h * 0.1)
    if self.closeBtn ~= nil then
        self.closeBtn:SetWide(w * 0.04)
    end
end

function PANEL:Paint(w,  h)
    draw.RoundedBoxEx(self.roundness or 0, 0, 0, w, h, self.color or TARDIS_SPAWNER_CONFIG.Theme.Body, self.roundnessTopLeft, self.roundnessTopRight, self.roundnessBottomLeft, self.roundnessBottomRight)
end
derma.DefineControl("DoctorWhoRP.VGUI.Panel", "", PANEL, "DPanel")