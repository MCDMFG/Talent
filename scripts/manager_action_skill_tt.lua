local fGetRollOriginal;

function onInit()
	fGetRollOriginal = ActionSkill.getRoll;
	ActionSkill.getRoll = getRoll;
end

function getRoll(rActor, nodeSkill)
	local rRoll = fGetRollOriginal(rActor, nodeSkill);

	local sSkill = DB.getValue(nodeSkill, "name", "");
	local sAbility = DB.getValue(nodeSkill, "stat", "");

	if (sSkill or ""):lower():match("tool") then
		sSkill = "tool";
	end

	StrainManager.modifyRollWithStrainImpact(rActor, rRoll, "check", sSkill, nodeSkill);

	return rRoll;
end