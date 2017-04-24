{_x setMarkerAlpha 0} foreach OT_regions;

//Find NATO HQ
{
    _x params ["_pos","_name"];
    if(_name == OT_NATO_HQ) then {
        OT_NATO_HQPos = _pos;
    };
}foreach (OT_objectiveData + OT_airportData);

private _allActiveShops = [];
private _allActiveCarShops = [];
private _allActivePiers = [];

if((server getVariable ["EconomyVersion",0]) < OT_economyVersion) then {
    {
        _x params ["_cls","_name","_side"];
        if(_side == 1) then {
            server setVariable [format["standing%1",_cls],-100,true];
        }else{
            _town = selectRandom OT_allTowns;
            if(_name == "AAF") then {_town = server getvariable "spawntown"};
            _posTown = server getVariable _town;
            _building = [_posTown,OT_lowPopHouses] call OT_fnc_getRandomBuilding;
            while {isNil "_building"} do {
                _town = selectRandom OT_allTowns;
                _posTown = server getVariable _town;
                _building = [_posTown,OT_lowPopHouses] call OT_fnc_getRandomBuilding;
            };

            _pos = (_building call BIS_fnc_buildingPositions) call BIS_fnc_selectRandom;
            if(isNil "_pos") then {
                _pos = [[[getpos _building,50]]] call BIS_fnc_randomPos;
            };
        	server setVariable [format["factionrep%1",_cls],_pos,true];
        	_building setVariable ["owner","system",true];

        };
    }foreach(OT_allFactions);
};

//Stability markers
{
    _stability = server getVariable format["stability%1",_x];
    _posTown = server getVariable _x;
    _pos = [_posTown,40,-90] call BIS_fnc_relPos;
    _mSize = 250;

    if(_x in OT_Capitals) then {
        _mSize = 400;
    };

    _mrk = createMarker [_x,_pos];
    _mrk setMarkerShape "ELLIPSE";
    _mrk setMarkerSize[_mSize,_mSize];
    _mrk setMarkerColor "ColorRed";

    if(_stability < 50) then {
        _mrk setMarkerAlpha 1.0 - (_stability / 50);
    }else{
        _mrk setMarkerAlpha 0;
    };
    _mrk = createMarker [format["%1-abandon",_x],_pos];
    _mrk setMarkerShape "ICON";
    _garrison = server getVariable [format['police%1',_x],0];
	if(_garrison > 0) then {
		_mrk setMarkerType "OT_Police";
	}else{
		_mrk setMarkerType "OT_Anarchy";
	};
    if(_stability < 50) then {
        _mrk setMarkerColor "ColorOPFOR";
    }else{
        _mrk setMarkerColor "ColorGUER";
    };
    if(_x in (server getVariable ["NATOabandoned",[]])) then {
        _mrk setMarkerAlpha 1;
    }else{
        _mrk setMarkerAlpha 0;
    };

    if((server getVariable ["EconomyVersion",0]) < OT_economyVersion) then {
        [_x] call OT_fnc_setupTownEconomy;
    };

	_shops = server getVariable [format["activeshopsin%1",_x],[]];
	[_allActiveShops,_shops] call BIS_fnc_arrayPushStack;

	_carshops = server getVariable [format["activecarshopsin%1",_x],[]];
	[_allActiveCarShops,_carshops] call BIS_fnc_arrayPushStack;

	_piers = server getVariable [format["activepiersin%1",_x],[]];
	[_allActivePiers,_piers] call BIS_fnc_arrayPushStack;

}foreach(OT_allTowns);

OT_allEconomic = [];
{
	_x params ["_pos","_name"];
	_mrk = createMarker [_name,_pos];
	_mrk setMarkerShape "ICON";
    _mrk setMarkerType "ot_Business";
    _mrk setMarkerColor "ColorWhite";
    if(_name in (server getVariable["GEURowned",[]])) then {_mrk setMarkerColor "ColorGUER"};
    _mrk setMarkerAlpha 0.8;
	OT_allEconomic pushback _name;
    server setVariable [_name,_pos,true];
    cost setVariable [_name,_x,true];
}foreach(OT_economicData);

_mrk = createMarker ["Factory",OT_factoryPos];
_mrk setMarkerShape "ICON";
_mrk setMarkerType "ot_Factory";
_mrk setMarkerColor "ColorWhite";
if("Factory" in (server getVariable["GEURowned",[]])) then {_mrk setMarkerColor "ColorGUER"};
_mrk setMarkerAlpha 0.8;

server setVariable ["EconomyVersion",OT_economyVersion,false];

OT_allActiveShops = _allActiveShops;
publicVariable "OT_allActiveShops";

OT_allActiveCarShops = _allActiveCarShops;
publicVariable "OT_allActiveCarShops";

OT_allActivePiers = _allActivePiers;
publicVariable "OT_allActivePiers";

OT_economyLoadDone = true;
publicVariable "OT_economyLoadDone";
