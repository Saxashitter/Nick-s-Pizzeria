ntopp_v2.enums = {}
local enumval = 1

local function enum(str)
	ntopp_v2.enums[str] = enumval
	enumval = $+1
	return ntopp_v2.enums[str]
end

enum('BASE')
enum('MACH1')
enum('MACH2')
enum('MACH3')
enum('SKID')
enum('DRIFT')
enum('GRAB')
enum('BASE_GRABBEDENEMY')
enum('GRAB_KILLENEMY')
enum('CROUCH')
enum('ROLL')
enum('DIVE')
enum('BELLYSLIDE')
enum('SUPERJUMPSTART')
enum('SUPERJUMP')
enum('SUPERJUMPCANCEL')
enum('PAIN')
enum('WALLCLIMB')
enum('BODYSLAM')
enum('UPPERCUT')
enum('TAUNT')
enum('GRABBED')
enum('PARRY')
enum('STUN')
enum('PILEDRIVER')
enum('BREAKDANCESTART')
enum('BREAKDANCE')
enum('BREAKDANCELAUNCH')
enum('SUPERTAUNT')
enum('SWINGDING')
enum("FIREASS")
enum("BOOSTER")

/*ntopp_v2.enums.BASE = 1
ntopp_v2.enums.MACH1 = 2
ntopp_v2.enums.MACH2 = 3
ntopp_v2.enums.MACH3 = 4
ntopp_v2.enums.MACH4 = 5
ntopp_v2.enums.SKID = 6
ntopp_v2.enums.DRIFT = 7
ntopp_v2.enums.GRAB = 8
ntopp_v2.enums.BASE_GRABBEDENEMY = 9
ntopp_v2.enums.GRAB_KILLENEMY = 10
ntopp_v2.enums.LONGJUMP = 11
ntopp_v2.enums.CROUCH = 12
ntopp_v2.enums.ROLL = 13
ntopp_v2.enums.DIVE = 14
ntopp_v2.enums.BELLYSLIDE = 15
ntopp_v2.enums.SUPERJUMPSTART = 16
ntopp_v2.enums.SUPERJUMP = 17
ntopp_v2.enums.SUPERJUMPCANCEL = 18
ntopp_v2.enums.PAIN = 19
ntopp_v2.enums.WALLCLIMB = 20
ntopp_v2.enums.BODYSLAM = 21
ntopp_v2.enums.UPPERCUT = 22
ntopp_v2.enums.TAUNT = 23
ntopp_v2.enums.GRABBED  = 24
ntopp_v2.enums.PARRY = 25
ntopp_v2.enums.STUN = 26
ntopp_v2.enums.PILEDRIVER = 27
ntopp_v2.enums.BREAKDANCESTART = 28
ntopp_v2.enums.BREAKDANCELAUNCH = 29
ntopp_v2.enums.BREAKDANCE = 30
ntopp_v2.enums.SUPERTAUNT = 31*/