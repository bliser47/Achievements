ACHIEVEMENTUI_SELECTEDFILTER = AchievementFrame_GetCategoryNumAchievements_All;

AchievementFrameFilters = { {text=ACHIEVEMENTFRAME_FILTER_ALL, func= AchievementFrame_GetCategoryNumAchievements_All},
    {text=ACHIEVEMENTFRAME_FILTER_COMPLETED, func=AchievementFrame_GetCategoryNumAchievements_Complete},
    {text=ACHIEVEMENTFRAME_FILTER_INCOMPLETE, func=AchievementFrame_GetCategoryNumAchievements_Incomplete} };

function AchievementFrameFilterDropDown_OnLoad (self)
    self.relativeTo = "AchievementFrameFilterDropDown"
    self.xOffset = -14;
    self.yOffset = 10;
    UIDropDownMenu_Initialize(self, AchievementFrameFilterDropDown_Initialize);
end

function AchievementFrameFilterDropDown_Initialize (self)
    local info = UIDropDownMenu_CreateInfo();
    for i, filter in ipairs(AchievementFrameFilters) do
        info.text = filter.text;
        info.value = i;
        info.func = AchievementFrameFilterDropDownButton_OnClick;
        if ( filter.func == ACHIEVEMENTUI_SELECTEDFILTER ) then
            info.checked = 1;
            UIDropDownMenu_SetText(self, filter.text);
        else
            info.checked = nil;
        end
        UIDropDownMenu_AddButton(info);
    end
end

function AchievementFrameFilterDropDownButton_OnClick (self)
    AchievementFrame_SetFilter(self.value);
end

function AchievementFrame_SetFilter(value)
    local func = AchievementFrameFilters[value].func;
    if ( func ~= ACHIEVEMENTUI_SELECTEDFILTER ) then
        ACHIEVEMENTUI_SELECTEDFILTER = func;
        UIDropDownMenu_SetText(AchievementFrameFilterDropDown, AchievementFrameFilters[value].text)
        AchievementFrameAchievementsContainerScrollBar:SetValue(0);
        AchievementFrameAchievements_ForceUpdate();
    end
end