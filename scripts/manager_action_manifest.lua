function onInit()
	ActionsManager.registerModHandler("manifest", modManifest);
	ActionsManager.registerResultHandler("manifest", onManifest)
end

function getRoll(draginfo, rActor, rAction)
	-- Build basic roll
	local rRoll = {};
	rRoll.sType = "manifest";
	rRoll.aDice = { rAction.sPowerDie };
	rRoll.nMod = 0;

	-- Build the description label
	rRoll.sDesc = "[MANIFEST] " .. rAction.label;

	if rAction.nLevel then
		local sOrder = Interface.getString("order_" .. rAction.nLevel);
		if (sOrder or "") ~= "" then
			rRoll.sDesc = rRoll.sDesc .. " (" .. Interface.getString("order_" .. rAction.nLevel) .. ")";
		end
		rRoll.sDesc = rRoll.sDesc .. " [ORDER: " .. rAction.nLevel .. "]";
	end

	return rRoll;
end

function modManifest(rSource, rTarget, rRoll)
	if rSource then
		local aAddDesc = {};
		local aAddDice = {};
		local nAddMod = 0;
		local nEffectCount = 0;
		aAddDice, nAddMod, nEffectCount = EffectManager5E.getEffectsBonus(rSource, {"MANIFEST"}, false);
		if (nEffectCount > 0) then
			bEffects = true;
		end

		-- If effects happened, then add note
		if bEffects then
			local sEffects = "";
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			if sMod ~= "" then
				sEffects = "[" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
			else
				sEffects = "[" .. Interface.getString("effects_tag") .. "]";
			end
			table.insert(aAddDesc, sEffects);
		end
		if #aAddDesc > 0 then
			rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
		end
		ActionsManager2.encodeDesktopMods(rRoll);
		for _,vDie in ipairs(aAddDice) do
			if vDie:sub(1,1) == "-" then
				table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
			else
				table.insert(rRoll.aDice, "p" .. vDie:sub(2));
			end
		end
		rRoll.nMod = rRoll.nMod + nAddMod;
	end
end

function onManifest(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	local nTotal = ActionsManager.total(rRoll);
	local nOrder = tonumber(rRoll.sDesc:match("%[ORDER: (%d-)%]") or "0");
	rMessage.text = string.gsub(rMessage.text, " %[ORDER:[^]]*%]", "");

	local sResult = "SUCCESS";
	local nStrain = 0;
	if nTotal == nOrder then
		sResult = "PARTIAL SUCCESS";
		nStrain = 1;
	elseif nTotal < nOrder then
		sResult = "FAILURE";
		nStrain = nOrder;
	end

	rMessage.text = rMessage.text .. " -> " .. StringManager.capitalize(sResult);
	Comm.deliverChatMessage(rMessage);

	-- Initiate Strain roll
	rAction = {};
	rAction.label = rRoll.sDesc:match("%[MANIFEST%] ([^[]*) %[");
	rAction.sResult = sResult;
	rAction.nMod = nStrain;
	ActionStrain.performRoll(nil, rSource, rTarget, rAction);
end