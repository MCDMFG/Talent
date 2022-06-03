local fGetPCPowerActionOriginal;
local fPerformActionOriginal;

function onInit()
	fGetPCPowerActionOriginal = PowerManager.getPCPowerAction;
	PowerManager.getPCPowerAction = getPCPowerAction;
	fPerformActionOriginal = PowerManager.performAction;
	PowerManager.performAction = performAction;

	PowerManager.getPCPowerManifestActionText = getPCPowerManifestActionText;
end

function getPCPowerAction(nodeAction, sSubRoll)
	if not nodeAction then
		return;
	end
	local rActor = ActorManager.resolveActor(nodeAction.getChild("....."));
	if not rActor then
		return;
	end

	local rAction = {};
	rAction.type = DB.getValue(nodeAction, "type", "");
	rAction.label = DB.getValue(nodeAction, "...name", "");
	rAction.order = PowerManager.getPCPowerActionOutputOrder(nodeAction);
	if rAction.type == "manifest" then
		local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
		local nodePower = nodeAction.getChild("...");
		local sGroup = DB.getValue(nodePower, "group", "");
		local nodePowerGroup = nil;
		for _,v in pairs(DB.getChildren(nodeActor, "powergroup")) do
			if DB.getValue(v, "name", "") == sGroup then
				nodePowerGroup = v;
			end
		end
		if nodePowerGroup then
			rAction.sPowerDie = DB.getValue(nodePowerGroup, "powerdie", "");
		end
		rAction.nLevel = DB.getValue(nodePower, "level", 0);
		rAction.bPrompt = DB.getValue(nodeAction, "prompt", "") == "yes";
	else
		rAction, rActor = fGetPCPowerActionOriginal(nodeAction, sSubRoll)
	end

	return rAction, rActor;
end

function getPCPowerManifestActionText(nodeAction)
	local sPowerDie = "";
	local rAction, rActor = PowerManager.getPCPowerAction(nodeAction);
	if rAction then
		sPowerDie = rAction.sPowerDie;
		if rAction.bPrompt then
			sPowerDie = sPowerDie .. "*";
		end
	end
	return sPowerDie or "";
end

function performAction(draginfo, rActor, rAction, nodePower)
	if not rActor or not rAction then
		return false;
	end

	local rRolls = {};
	if rAction.type == "manifest" then
		PowerManager.evalAction(rActor, nodePower, rAction);

		if rAction.bPrompt then
			local window = Interface.openWindow("power_manifest_prompt", "");
			window.setData(rActor, rAction, nodePower);
			return;
		end
		
		table.insert(rRolls, ActionManifest.getRoll(nil, rActor, rAction))
	else
		return fPerformActionOriginal(draginfo, rActor, rAction, nodePower)
	end

	if #rRolls > 0 then
		ActionsManager.performMultiAction(draginfo, rActor, rRolls[1].sType, rRolls);
		return true;
	end
end