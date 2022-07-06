local fGetDefenseValue;

function onInit()
	fGetDefenseValue = ActorManager5E.getDefenseValue;
	ActorManager5E.getDefenseValue = getDefenseValue;
end

function getDefenseValue(rAttacker, rDefender, rRoll)
	local nDefenseVal, nAtkEffectsBonus, nDefEffectsBonus, bADV, bDIS = fGetDefenseValue(rAttacker, rDefender, rRoll);

	if ActorManager.isPC(rDefender) then
		local impact = StrainManager.getStrainImpact(rDefender, "ac");
		if impact.nModifier ~= 0 then
			nDefEffectsBonus = nDefEffectsBonus + impact.nModifier;
		end
	end
	
	return nDefenseVal, nAtkEffectsBonus, nDefEffectsBonus, bADV, bDIS;
end