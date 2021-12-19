-- Türkçe Kaliteli Scriptin Adresi : https://sparrow-mta.blogspot.com
-- Bu paket SparroW Tarafından Toplanmıştır...
-- SparroW MTA

local mods = {};

addEventHandler ("onResourceStart", resourceRoot, 
	function ()
		local meta = xmlLoadFile ("meta.xml");
		parseMeta(mods, meta);
	end
);


addEvent ("loader.onload", true);
addEventHandler ("loader.onload", root, 
	function ()
		triggerLatentClientEvent (client, "loader.request", client, mods);
	end
);	



function parseMeta(tbl, meta)
	for i, v in ipairs (xmlNodeGetChildren(meta)) do 
		if xmlNodeGetName(v) == "file" then 
			local model = tonumber (xmlNodeGetAttribute(v, "model"));
			local isim = xmlNodeGetAttribute(v, "isim")
			local file = xmlNodeGetAttribute (v, "src");
			local dosya = fileOpen(file)
			local boyut = fileGetSize(dosya)
			fileClose(dosya)
			table.insert (tbl, {isim=isim,file = file, model = model,boyut=boyut});	
		end
	end	
end	





