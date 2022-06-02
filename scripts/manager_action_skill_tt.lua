local fGetRollOriginal;

function onInit()
	fGetRollOriginal = ActionSkill.getRoll;
	ActionSkill.getRoll = getRoll;
end

function getRoll(rActor, nodeSkill)
	local rRoll = fGetRollOriginal(rActor, nodeSkill);

	local sSkill = DB.getValue(nodeSkill, "name", "");
	local sAbility = DB.getValue(nodeSkill, "stat", "");

	local aAddDesc = {};
	local bStrain = false;
	local bADV = false;
	local bDIS = false;
	if rRoll.sDesc:match(" %[ADV%]") then
		bADV = true;
		rRoll.sDesc = rRoll.sDesc:gsub(" %[ADV%]", "");		
	end
	if rRoll.sDesc:match(" %[DIS%]") then
		bDIS = true;
		rRoll.sDesc = rRoll.sDesc:gsub(" %[DIS%]", "");
	end

	local nodeChar = nodeSkill.getChild("...");
	local nProf = DB.getValue(nodeSkill, "prof", 0);
	local bIsTool = (sSkill or ""):match("tool");

	if StrainManager.isAtOrAboveStrainLevel(rActor, "body", 2) and (sAbility == "strength" or sAbility == "dexterity") then
		bStrain = true;
		bDIS = true;
	end
	if StrainManager.isAtOrAboveStrainLevel(rActor, "mind", 2) and (sAbility == "intelligence" or bIsTool) then
		bStrain = true;
		bDIS = true;
	end
	if StrainManager.isAtOrAboveStrainLevel(rActor, "soul", 2) and (sAbility == "wisdom" or sAbility == "charisma") then
		bStrain = true;
		bDIS = true;
	end
	-- Lose prof in all skills you're proficient in
	if StrainManager.isAtOrAboveStrainLevel(rActor, "mind", 6) or (StrainManager.isAtOrAboveStrainLevel(rActor, "mind", 3) and bIsTool) then
		local nProf = DB.getValue(nodeSkill, "prof", 0);
		if nProf == 1 then
			rRoll.nMod = rRoll.nMod - DB.getValue(nodeChar, "profbonus", 0);
			rRoll.sDesc = rRoll.sDesc:gsub(" %[PROF%]", "");		
			bStrain = true;
		elseif nProf == 2 then
			rRoll.nMod = rRoll.nMod - (2 * DB.getValue(nodeChar, "profbonus", 0));
			rRoll.sDesc = rRoll.sDesc:gsub(" %[PROF x2%]", "");		
			bStrain = true;
		elseif nProf == 3 then
			-- TODO: Figure out how this strain penalty interacts with half proficiency bonuses
			-- rRoll.nMod = rRoll.nMod + math.floor(DB.getValue(nodeChar, "profbonus", 0) / 2);
			-- rRoll.sDesc = rRoll.sDesc .. " [PROF x1/2]";
		end
	end
	
	if bADV then
		rRoll.sDesc = rRoll.sDesc .. " [ADV]";
	end
	if bDIS then
		rRoll.sDesc = rRoll.sDesc .. " [DIS]";
	end
	if bStrain then
		rRoll.sDesc = rRoll.sDesc .. " [STRAIN]";
	end

	return rRoll;
end