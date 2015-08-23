-- Protocol

Evt_InitMap = Event(1)
Evt_InitMap.key = {
	numberOfMaps = 1,
}

Evt_CreateMap = Event(2)
Evt_CreateMap.key = {
	row = 1,
	col = 2,
	numberOfMaps = 3,
}

Evt_LoadMap = Event(3)
Evt_LoadMap.key = {
	mapNumber = 1,
	row = 2,
	col = 3,
}

Evt_SaveMap = Event(4)
Evt_SaveMap.key = {
	numberOfMaps = 1,
}

Evt_PrintMap = Event(5)
Evt_PrintMap.key = {
	mapNumber = 1,
}	

Evt_Select = Event(10)
Evt_Select.key = {
	mapImage = 1,
	mapImageIndex = 2,
	mapType = 3,
}

Evt_SelectMapUnit = Event(11)
Evt_SelectMapUnit.key = {
	row = 1,
	col = 2,
}

Evt_CancelMapUnit = Event(12)
Evt_CancelMapUnit.key = {
	row = 1,
	col = 2,
}