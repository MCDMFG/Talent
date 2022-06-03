local sType = "";
local nLevel = 0;
local charnode = nil;

function onInit()
	charnode = parentcontrol.window.getDatabaseNode();
	sType = parentcontrol.parameters[1]["stat"][1]
	nLevel = tonumber(parentcontrol.parameters[1]["level"][1]);

	description.setValue(Interface.getString("strainlevel_" .. sType .. "_" .. nLevel));

	if parentcontrol.parameters[1]["automated"] then
		automated.setVisible(true);
	end
	
	DB.addHandler(DB.getPath(charnode, "strain." .. sType .. ".max"), "onUpdate", update);
	DB.addHandler(DB.getPath(charnode, "strain." .. sType .. ".current"), "onUpdate", update);

	update();
end

function onClose()
	DB.removeHandler(DB.getPath(charnode, "strain." .. sType .. ".max"), "onUpdate", update);
	DB.removeHandler(DB.getPath(charnode, "strain." .. sType .. ".current"), "onUpdate", update);
end

function update()
	updateFrame();
end

function updateFrame()
	nMax = StrainManager.getMaxStrain(charnode, sType);
	nCur = StrainManager.getCurrentStrain(charnode, sType);
	local sFrame = "";
	if nLevel > nMax then
		sFrame = "fieldlight";
	elseif nLevel <= nCur then
		sFrame = "required";
	else
		sFrame = "fielddark";
	end

	setFrame(sFrame, 7,5,7,5);
	clicker.update(sFrame ~= "fieldlight");
end

function onClick()
	-- Edge case where if we click the first strain level and the first strain level
	-- Is already checked off, uncheck it.
	local nCur = StrainManager.getCurrentStrain(charnode, sType);
	if nCur == 1 and nLevel == 1 then
		StrainManager.setCurrentStrain(charnode, sType, 0);
		return;
	end

	StrainManager.setCurrentStrain(charnode, sType, nLevel);

	-- Calculate the difference between old value and new value
	local nDelta = nLevel - nCur;

	local nCurToApply = StrainManager.getStrainToApply(charnode);
	if nCurToApply > 0 and nDelta > 0 then
		StrainManager.addStrainToApply(charnode, -nDelta);
	end
end