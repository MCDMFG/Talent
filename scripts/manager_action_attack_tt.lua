local fGetRollOriginal;
local fModAttackOriginal;

function onInit()
	fGetRollOriginal = ActionAttack.getRoll;
	ActionAttack.getRoll = getRoll;

	-- fModAttackOriginal = ActionAttack.modAttack;
	-- ActionAttack.modAttack = modAttack;
	
	--ActionsManager.registerModHandler("attack", modAttack);
end

function getRoll(rActor, rAction)
	rRoll = fGetRollOriginal(rActor, rAction);

	local sFilter = rAction.stat;
	if rAction.bWeapon then
		sFilter = "weapon";
	end
	
	StrainManager.modifyRollWithStrainImpact(rActor, rRoll, "attack", sFilter, rAction)

	return rRoll;
end

function modAttack(rSource, rTarget, rRoll)
	-- This goes at the end because the original func has the encodeAdvantage call
	-- and that causes problems if run more than once.
	fModAttackOriginal(rSource, rAttack, rRoll);
end