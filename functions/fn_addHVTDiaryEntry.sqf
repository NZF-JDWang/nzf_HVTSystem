/*
 * Adds an HVT event to all players' diaries in a dedicated HVT Events section with a clickable map marker
 * 
 * Arguments:
 * 0: STRING - Event title
 * 1: STRING - Event description
 * 2: ARRAY - Position [x, y, z] for the map marker
 * 3: STRING - Marker color ("ColorGreen", "ColorRed", "ColorOrange")
 * 
 * Return Value:
 * STRING - The created marker name
 * 
 * Example:
 * ["HVT Captured", "Abu Hassan surrendered to John", getPos _hvt, "ColorGreen"] call nzf_fnc_addHVTDiaryEntry;
 */

params ["_title", "_description", "_position", "_markerColor"];

// Create unique marker name
private _markerName = format ["hvt_event_%1", diag_tickTime];

// Create marker at position
private _marker = createMarker [_markerName, _position];
_marker setMarkerShape "ICON";
_marker setMarkerType "mil_dot";
_marker setMarkerColor _markerColor;
_marker setMarkerText _title;
_marker setMarkerAlpha 0; // Hidden marker (only visible when clicked in diary)

// Add diary entry to all players with clickable marker link
{
	// Create HVT Events section if it doesn't exist
	if !(_x diarySubjectExists "HVTEvents") then {
		_x createDiarySubject ["HVTEvents", "HVT Events"];
	};
	
	// Add entry with marker link
	_x createDiaryRecord ["HVTEvents", [
		_title, 
		format ["<br/>%1<br/><br/><marker name='%2'>View on Map</marker>", _description, _markerName]
	]];
} forEach allPlayers;

_markerName

