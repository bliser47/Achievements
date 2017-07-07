-- TODO: When comparison is implemented ALL of this
-- TODO: needs to go back into the comparison files

-- We only need these functions since the latest achievements
-- in the SummaryAchievements inherit the ComparisonPlayerTemplate

function AchievementComparisonPlayerButton_Saturate (self)
    local name = self:GetName();
    getglobal(name .. "TitleBackground"):SetTexCoord(0, 0.9765625, 0, 0.3125);
    getglobal(name .. "Background"):SetTexture("Interface\\Addons\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-Parchment-Horizontal");
    getglobal(name .. "Glow"):SetVertexColor(1.0, 1.0, 1.0);
    self.icon:Saturate();
    self.shield:Saturate();
    self.shield.points:SetVertexColor(1, 1, 1);
    self.label:SetVertexColor(1, 1, 1);
    self.description:SetTextColor(0, 0, 0, 1);
    self.description:SetShadowOffset(0, 0);
    self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
end


function AchievementComparisonPlayerButton_Desaturate (self)
    local name = self:GetName();
    getglobal(name .. "TitleBackground"):SetTexCoord(0, 0.9765625, 0.34375, 0.65625);
    getglobal(name .. "Background"):SetTexture("Interface\\Addons\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-Parchment-Horizontal-Desaturated");
    getglobal(name .. "Glow"):SetVertexColor(.22, .17, .13);
    self.icon:Desaturate();
    self.shield:Desaturate();
    self.shield.points:SetVertexColor(.65, .65, .65);
    self.label:SetVertexColor(.65, .65, .65);
    self.description:SetTextColor(1, 1, 1, 1);
    self.description:SetShadowOffset(1, -1);
    self:SetBackdropBorderColor(.5, .5, .5);
end

function AchievementComparisonPlayerButton_OnLoad (self)

    local name = self:GetName();
    self.label = getglobal(name .. "Label");
    self.description = getglobal(name .. "Description");
    self.icon = getglobal(name .. "Icon");
    self.shield = getglobal(name .. "Shield");
    self.dateCompleted = getglobal(name .. "DateCompleted");
    self.titleBar = getglobal(name .. "TitleBackground");

    self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
    self.Saturate = AchievementComparisonPlayerButton_Saturate;
    self.Desaturate = AchievementComparisonPlayerButton_Desaturate;

    self:Desaturate();

    --AchievementFrameComparison.buttons = AchievementFrameComparison.buttons or {};
    --tinsert(AchievementFrameComparison.buttons, self);
end