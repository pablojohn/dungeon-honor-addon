-- List of WoW-specific global functions and variables
globals = {
  -- WoW API Functions
  CreateFrame,
  UnitExists,
  UnitIsPlayer,
  UnitName,
  GetRealmName,

  -- WoW Global Variables
  DungeonHonorData,
  GameTooltip,
  HonorData,
}

-- Settings to suppress certain warnings
unused_args = false  -- Suppress warnings for unused arguments in functions
allow_defined = true -- Allow globals to be defined without warnings
