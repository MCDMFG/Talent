local fModAttackOriginal;

function onInit()
	fModAttackOriginal = ActionAttack.modAttack;
	ActionAttack.modAttack = modAttack;
	ActionsManager.registerModHandler("attack", modAttack);
end

function modAttack(rSource, rTarget, rRoll)
	fModAttackOriginal(rSource, rAttack, rRoll);

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
	
	-- Lose proficiency with weapons
	if rSource and ActorManager.isPC(rSource) and StrainManager.isAtOrAboveStrainLevel(rSource, "mind", 3) then
		bStrain = true;
	end

	-- attacks against PC have advantage
	if rTarget and ActorManager.isPC(rTarget) and StrainManager.isAtOrAboveStrainLevel(rTarget, "body", 7) then
		bStrain = true;
		bADV = true;
	end

	if bStrain then
		table.insert(aAddDesc, "[STRAIN]")
	end

	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end

	ActionsManager2.encodeAdvantage(rRoll, bADV, bDIS);
end