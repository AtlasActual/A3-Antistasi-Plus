/*  Handles the reinforcements of markers
*   Params:
*       Nothing
*
*   Returns:
*       Nothing
*/
private _fileName = "reinforcementsAI";
private _recruitCount =  round ((10 + 2 * tierWar + (floor ((count allPlayers)/2))) * (0.5 * skillMult));
[2, format ["Airports are now able to send %1 reinforcements", _recruitCount], _fileName] call A3A_fnc_log;
{
    //Setting the number of recruitable units per ticks per airport
    garrison setVariable [format ["%1_recruit", _x], _recruitCount, true];
} forEach airportsX;

_recruitCount = round ((5 + (round (0.5 * tierWar)) + (floor ((count allPlayers)/4))) * (0.5 * skillMult));
[2, format ["Outposts are now able to send %1 reinforcements", _recruitCount], _fileName] call A3A_fnc_log;
{
    //Setting the number of recruitable units per ticks per outpost
    garrison setVariable [format ["%1_recruit", _x], _recruitCount, true];
} forEach outposts;

//New reinf system (still reactive, so a bit shitty)
{
    _side = _x;
    _reinfMarker = if(_x == Occupants) then {reinforceMarkerOccupants} else {reinforceMarkerInvader};
    _canReinf = if(_x == Occupants) then {canReinforceOccupants} else {canReinforceInvader};
    //Make a hard copy to work on it
    _canReinf = +_canReinf;
    _canReinf = _canReinf select {(garrison getVariable [format ["%1_recruit", _x], 0]) > 0};
    [
        2,
        format ["Side %1, %2 sites need reinforcement , %3 can send some", _x, count _reinfMarker, count _canReinf],
        _fileName
    ] call A3A_fnc_log;
    _reinfMarker sort true;
    {
        _target = (_x select 1);
        [_target, "Reinforce", _side, [_canReinf]] remoteExec ["A3A_fnc_createAIAction", 2];
        sleep 10;		// prevents convoys spawning on top of each other
        _canReinf = _canReinf select {(garrison getVariable [format ["%1_recruit", _x], 0]) >= 5};
        //No bases left for sending reinforcements
        if(count _canReinf == 0) exitWith {};
    } forEach _reinfMarker;
} forEach [Occupants, Invaders];
//hint "ReinforcementsAI done";

//Replenish airports if possible
{
    [_x] call A3A_fnc_replenishGarrison;
} forEach airportsX;
