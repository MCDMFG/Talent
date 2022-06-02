local sType = "";
local nLevel = 0;

function onInit()
	sType = parentcontrol.parameters[1]["stat"][1]
	nLevel = tonumber(parentcontrol.parameters[1]["level"][1]);

	description.setValue(Interface.getString("strainlevel_" .. sType .. "_" .. nLevel));

	if parentcontrol.parameters[1]["automated"] then
		automated.setVisible(true);
	end
end

function onClick()
	Debug.chat('onClick()')
end