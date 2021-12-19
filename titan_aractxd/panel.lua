-- Türkçe Kaliteli Scriptin Adresi : https://sparrow-mta.blogspot.com
-- Bu paket SparroW Tarafından Toplanmıştır...
-- SparroW MTA

local sx,sy = guiGetScreenSize()
local pg,pu = 500,300
local x,y = (sx-pg)/2,(sy-pu)/2
local lmodlar = {["Araclar"] = {}}

local panel = guiCreateWindow(x,y,pg,pu,"Modları Yönet - Venom",false)
guiSetVisible(panel,false)
local liste = guiCreateGridList(10,20,pg-20,pu-60,false,panel)
guiGridListSetSortingEnabled(liste,false)
guiGridListAddColumn(liste,"Model ID",0.1)
guiGridListAddColumn(liste,"Araç İsim",0.3)
guiGridListAddColumn(liste,"Boyut",0.2)
guiGridListAddColumn(liste,"Durum",0.3)

local devredisi = guiCreateButton(10,pu-30,120,20,"Devre Dışı",false,panel)
local tumdevredisi = guiCreateButton(10+125,pu-30,120,20,"Tümünü Devre Dışı",false,panel)
local tumaktif = guiCreateButton(10+250,pu-30,120,20,"Tümünü Aktif",false,panel)
local panelkapat = guiCreateButton(pg-75,pu-30,75,20,"Kapat",false,panel)

addEventHandler("onClientResourceStart", resourceRoot, function()
	addEventHandler("onClientGUIClick",devredisi,modaktif,false)
	addEventHandler("onClientGUIClick",liste,seciliKontrol,false)
	addEventHandler("onClientGUIClick",tumdevredisi,tumunudevredisi,false)
	addEventHandler("onClientGUIClick",tumaktif,tumunuaktif,false)
	addEventHandler("onClientGUIClick",panelkapat,kapat,false)
end)

bindKey("F4","down",function()
	guiSetVisible(panel,not guiGetVisible(panel))
	showCursor(guiGetVisible(panel))
end)

function kapat()
	guiSetVisible(panel,false)
	showCursor(false)
end

function modaktif()
	local model,isim,durum,row = seciliItem()
	if model then
		local araclar = loadSetting("Araclar","mbLoader") or toJSON({})
		local araclar = fromJSON(araclar)
		if durum == "Aktif" then
			araclar[model] = true
			outputChatBox(isim.. " İsimli aracı deaktif ettin.",255,0,0)
			guiGridListSetItemText(liste,row,4,"Deaktif",false,false)
			aracIslem(model,false)
			guiSetText(devredisi,"Aktif")
		else
			araclar[model] = nil
			outputChatBox(isim.. " İsimli aracı aktif ettin.",255,0,0)
			guiGridListSetItemText(liste,row,4,"Aktif",false,false)
			aracIslem(model,true)
			guiSetText(devredisi,"Devre Dışı")
		end
		saveSetting("Araclar", toJSON(araclar),"mbLoader")
	else
		outputChatBox("Lütfen bir item seç",255,0,0)
	end	
end

function tumunuaktif()
	for i,v in pairs(lmodlar) do
		for model,t in pairs(v) do 
			aracIslem(model,true)
		end
	end
	saveSetting("Araclar", toJSON({}),"mbLoader")
	listeYenile()
end

function tumunudevredisi()
	local araclar = {}
	for i,v in pairs(lmodlar) do
		for model,t in pairs(v) do 
			araclar[model] = true
			aracIslem(model,false)
		end
	end
	saveSetting("Araclar", toJSON(araclar),"mbLoader")
	listeYenile()
end

function seciliKontrol()
	local model,isim,durum,row = seciliItem() 
	if model then
		if durum == "Aktif" then
			guiSetText(devredisi,"Devre Disi")
		else
			guiSetText(devredisi,"Aktif")
		end			
	end
end

function aracIslem(model,islem)
	local model = tonumber(model)
	if islem then
		-- triggerEvent("loader.download",resourceRoot,model)
		downloadFile("files/"..model..".txd")
		downloadFile("files/"..model..".dff")
	else
		engineRestoreModel (model)
	end
end

function seciliItem()
	local row,col = guiGridListGetSelectedItem(liste)
	if row ~= -1 then
		local model = guiGridListGetItemText(liste,row,1)
		local isim = guiGridListGetItemText(liste,row,2)
		local durum = guiGridListGetItemText(liste,row,4)
		return model,isim,durum,row
	else
		return false
	end
end

addEventHandler ("loader.request", root,function (tbl)
	if tbl then 
		mods = tbl;
		local deaktifler = loadSetting("Araclar","mbLoader") or toJSON({})
		local deaktifler = fromJSON(deaktifler)
		for i,v in pairs(mods) do
			local model = tostring(v.model)
			if not lmodlar["Araclar"][model] then 
				lmodlar["Araclar"][model] = {} 
				local isim,boyut =v.isim,getRealBoyut(tonumber(model))
				lmodlar["Araclar"][model] = {isim,sizeFormat(boyut),boyut}
			end
		end
		listeYenile()
	end
end)

function listeYenile()
	if not liste then setTimer(listeYenile,5000,1) return end 
	guiGridListClear(liste)
	local deaktifler = loadSetting("Araclar","mbLoader") or toJSON({})
	local deaktifler = fromJSON(deaktifler)
	for model,v in pairs(lmodlar["Araclar"]) do
		local isim,boyut = unpack(v)
		local row = guiGridListAddRow(liste)
		guiGridListSetItemText(liste,row,1,model,false,false)
		guiGridListSetItemText(liste,row,2,isim,false,false)
		guiGridListSetItemText(liste,row,3,boyut,false,false)
		if deaktifler[tostring(model)] then
			guiGridListSetItemText(liste,row,4,"Deaktif",false,false)
		else
			guiGridListSetItemText(liste,row,4,"Aktif",false,false)
		end	
	end
end


function getRealBoyut(model)
	local boyut = 0
	for i,v in pairs(mods) do
		if v.model == model then
			boyut = boyut+v.boyut
		end
	end
	return boyut
end

function sizeFormat(size)
	local size = tostring(size)
	if size:len() >= 4 then		
		if size:len() >= 7 then
			if size:len() >= 9 then
				local returning = size:sub(1, size:len()-9)
				if returning:len() <= 1 then
					returning = returning.."."..size:sub(2, size:len()-7)
				end
				return returning.." GB";
			else				
				local returning = size:sub(1, size:len()-6)
				if returning:len() <= 1 then
					returning = returning.."."..size:sub(2, size:len()-4)
				end
				return returning.." MB";
			end
		else		
			local returning = size:sub(1, size:len()-3)
			if returning:len() <= 1 then
				returning = returning.."."..size:sub(2, size:len()-1)
			end
			return returning.." KB";
		end
	else
		return size.." B";
	end
end