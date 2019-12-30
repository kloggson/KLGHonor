local frame = KLGFrame or CreateFrame("FRAME", "KLGFrame");
frame:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN");
frame:RegisterEvent("ADDON_LOADED");

local function parseHonorMessage(arg1)
  local honor_gain_pattern = string.gsub(COMBATLOG_HONORGAIN, "%(", "%%(")
  honor_gain_pattern = string.gsub(honor_gain_pattern, "%)", "%%)")
  honor_gain_pattern = string.gsub(honor_gain_pattern, "(%%s)", "(.+)")
  honor_gain_pattern = string.gsub(honor_gain_pattern, "(%%d)", "(%%d+)")
  local victim, rank, est_honor = arg1:match(honor_gain_pattern)
  if (victim) then
    est_honor = math.max(0, math.floor(est_honor * (1 - 0.25 * ((KLGHonorDB.killed_players[victim] or 1) - 1)) + 0.5))
  end

  local honor_award_pattern = string.gsub(COMBATLOG_HONORAWARD, "(%%d)", "(%%d+)")
  local awarded_honor = arg1:match(honor_award_pattern)
  return victim, est_honor, awarded_honor
end

local function KLGHonor(self, event, arg1, ...)
  if event == "ADDON_LOADED" and arg1 == "KLGHonor" then
    if KLGHonorDB == nil then
      KLGHonorDB = {
        honor = 0,
        reset_time = 0,
        total_kills = 0,
        lifetime_kills = 0,
        lifetime_honor = 0,
        killed_players = {}


      }
    end
  elseif event == "CHAT_MSG_COMBAT_HONOR_GAIN" then

    local victim, _, awarded_honor = parseHonorMessage(arg1)
    if victim then
      KLGHonorDB.killed_players[victim] = (KLGHonorDB.killed_players[victim] or 0) + 1
      local _, est_honor = parseHonorMessage(arg1)
      KLGHonorDB.honor = KLGHonorDB.honor + est_honor
      KLGHonorDB.lifetime_honor = KLGHonorDB.lifetime_honor + est_honor
      KLGHonorDB.total_kills = KLGHonorDB.total_kills + 1
      KLGHonorDB.lifetime_kills = KLGHonorDB.lifetime_kills + 1
    elseif awarded_honor then

    end
  end
end

SLASH_KLG1 = "/klg"
SlashCmdList["KLG"] = function(functionName)
  local command, arg1, arg2 = strsplit(" ", functionName, 3);
  if command == "test" then

    print(KLGHonorDB.honor)
  elseif command == "report" then
    if (arg1) then
      SendChatMessage("Honor gained since last reset: " .. KLGHonorDB.honor .. " from " .. KLGHonorDB.total_kills .. " kills.", arg1, nil, nil)
    else
      print("Honor gained since last reset: " .. KLGHonorDB.honor .. " from " .. KLGHonorDB.total_kills .. " kills.")
    end
  elseif command == "reset" then
    print("All data has been reset")
    KLGHonorDB = {
      total_kills = 0,
      honor = 0,
      reset_time = 0,
      killed_players = {}
    }
  end
end
frame:SetScript("OnEvent", KLGHonor);
