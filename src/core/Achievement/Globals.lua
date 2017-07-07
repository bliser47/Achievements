-- TODO: Make this a LOT safer! (we don't like globals)

UIPanelWindows["AchievementFrame"] = { area = "doublewide", pushable = 0, width = 840, xoffset = 80, whileDead = 1 };

ACHIEVEMENT_SUMMARY_CATEGORY = "Summary"

ACHIEVEMENTUI_CATEGORIES = {};

ACHIEVEMENTUI_GOLDBORDER_R = 1;
ACHIEVEMENTUI_GOLDBORDER_G = 0.675;
ACHIEVEMENTUI_GOLDBORDER_B = 0.125;
ACHIEVEMENTUI_GOLDBORDER_A = 1;

ACHIEVEMENTUI_REDBORDER_R = 0.7;
ACHIEVEMENTUI_REDBORDER_G = 0.15;
ACHIEVEMENTUI_REDBORDER_B = 0.05;
ACHIEVEMENTUI_REDBORDER_A = 1;

ACHIEVEMENTUI_CATEGORIESWIDTH = 175;

ACHIEVEMENTUI_PROGRESSIVEHEIGHT = 50;
ACHIEVEMENTUI_PROGRESSIVEWIDTH = 42;

ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS = 4;

ACHIEVEMENTUI_MAXCONTENTWIDTH = 330;
ACHIEVEMENTUI_FONTHEIGHT = nil;				-- set in AchievementButton_OnLoad
ACHIEVEMENTUI_MAX_LINES_COLLAPSED = 3;		-- can show 3 lines of text when achievement is collapsed

ACHIEVEMENTUI_DEFAULTSUMMARYACHIEVEMENTS = {0}; -- MODIFIED

ACHIEVEMENT_CATEGORY_NORMAL_R = 0;
ACHIEVEMENT_CATEGORY_NORMAL_G = 0;
ACHIEVEMENT_CATEGORY_NORMAL_B = 0;
ACHIEVEMENT_CATEGORY_NORMAL_A = .9;

ACHIEVEMENT_CATEGORY_HIGHLIGHT_R = 0;
ACHIEVEMENT_CATEGORY_HIGHLIGHT_G = .6;
ACHIEVEMENT_CATEGORY_HIGHLIGHT_B = 0;
ACHIEVEMENT_CATEGORY_HIGHLIGHT_A = .65;

ACHIEVEMENTBUTTON_LABELWIDTH = 320;

ACHIEVEMENT_COMPARISON_SUMMARY_ID = -1
ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID = -2

ACHIEVEMENT_FILTER_ALL = 1;
ACHIEVEMENT_FILTER_COMPLETE = 2;
ACHIEVEMENT_FILTER_INCOMPLETE = 3;

FEAT_OF_STRENGTH_ID = 81;

ACHIEVEMENT_FUNCTIONS = {
    categoryAccessor = GetCategoryList,
    clearFunc = AchievementFrameAchievements_ClearSelection,
    updateFunc = AchievementFrameAchievements_Update,
    selectedCategory = "summary";
}

STAT_FUNCTIONS = {
    categoryAccessor = GetStatisticsCategoryList,
    clearFunc = nil,
    updateFunc = AchievementFrameStats_Update,
    selectedCategory = "summary";
}

COMPARISON_ACHIEVEMENT_FUNCTIONS = {
    categoryAccessor = GetCategoryList,
    clearFunc = AchievementFrameComparison_ClearSelection,
    updateFunc = AchievementFrameComparison_Update,
    selectedCategory = -1,
}

COMPARISON_STAT_FUNCTIONS = {
    categoryAccessor = GetStatisticsCategoryList,
    clearFunc = AchievementFrameComparison_ClearSelection,
    updateFunc = AchievementFrameComparison_UpdateStats,
    selectedCategory = -2,
}

achievementFunctions = ACHIEVEMENT_FUNCTIONS;


ACHIEVEMENT_TEXTURES_TO_LOAD = {
    {
        name="AchievementFrameAchievementsBackground",
        file="Interface\\Addons\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-AchievementBackground",
    },
    {
        name="AchievementFrameSummaryBackground",
        file="Interface\\Addons\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-AchievementBackground",
    },
    --[[
    {
        name="AchievementFrameComparisonBackground",
        file="Interface\\Addons\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-AchievementBackground",
    },
    ]]--
    {
        name="AchievementFrameCategoriesBG",
        file="Interface\\Addons\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-AchievementBackground",
    },
    {
        name="AchievementFrameWaterMark",
    },
    {
        name="AchievementFrameHeaderLeft",
        file="Interface\\Addons\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-Header",
    },
    {
        name="AchievementFrameHeaderRight",
        file="Interface\\Addons\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-Header",
    },
    {
        name="AchievementFrameHeaderPointBorder",
        file="Interface\\Addons\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-Header",
    },
    --[[
    {
        name="AchievementFrameComparisonWatermark",
        file="Interface\\Addons\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-StatsComparisonBackground",
    },
    ]]--
}


-- TODO: The SUPER UNSAFE variable start here
-- TODO: Please make this safe :)
trackedAchievements = {};
function updateTrackedAchievements (params)
    local count = table.getn(params);
    for i = 1, count do
        trackedAchievements[params[i]] = true;
    end
end


criteriaTable = {}
miniTable = {};
progressBarTable = {};
metaCriteriaTable = {};
achievementList = {};