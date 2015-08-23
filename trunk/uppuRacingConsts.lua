require "go.util.Serializable"

-- Screen Size
SCREEN_SIZE_X = 800
SCREEN_SIZE_Y = 600

-- Tile Size
TILE_SIZE_X = 60
TILE_SIZE_Y = 60

-- Class Type
CLASS_MASTER = 0
CLASS_SLAVE = 1
CLASS_NPO = 2

-- object sync threshold
DISTANCE_THRESHOLD = 10
ANGLE_THRESHOLD = math.pi/18

-- box2d filter data Mask Bits
COLLISION_FILTER_MASK_HIGHWALL = 0x000000ff		-- (255) 1111 1111	모두 충돌 
COLLISION_FILTER_MASK_LOWWALL = 0x000000fd		-- (253) 1111 1101 비행기(점프카) 빼고 모두 충돌
COLLISION_FILTER_MASK_CAR = 0x000000fd			-- (253) 1111 1101 비행기(점프카) 빼고 모두 충돌
COLLISION_FILTER_MASK_PLANE = 0x0000000a		-- ( 10) 0000 1010 고벽과 비행기만 충돌
COLLISION_FILTER_MASK_MISSILE = 0x000000fd		-- (253) 1111 1101 비행기(점프카) 빼고 모두 충돌
COLLISION_FILTER_MASK_NOCOLLISION = 0x00000008	-- (   ) 0000 1000 고벽만 충돌

-- box2d filter data Category Bits
COLLISION_FILTER_CATEGORY_HIGHWALL = 0x00000008	-- (  8) 0000 1000
COLLISION_FILTER_CATEGORY_LOWWALL = 0x00000004	-- (  4) 0000 0100
COLLISION_FILTER_CATEGORY_PLANE = 0x00000002	-- (  2) 0000 0010	(or jumpcar)
COLLISION_FILTER_CATEGORY_CAR = 0x00000001		-- (  1) 0000 0001
COLLISION_FILTER_CATEGORY_MISSILE = 0x00000010	-- ( 16) 0001 0000

-- car consts
CAR_MAX_STEER_ANGLE = 60						-- 최대 45도까지 핸들을 꺾을 수 있음
CAR_STEER_SPEED = 0.8							-- 핸들 꺾는 각 속도
--CAR_SIDEWAYS_FRICTION_FORCE = 10				-- friction force
CAR_HORSEPOWERS = 80000							-- 차 마력
CAR_DENSITY = 0.05
CAR_RESTITUTION = 0
CAR_LINEAR_DAMPING = 1
CAR_ANGULAR_DAMPING = 1
CAR_WHEEL_DENSITY = 0.1
CAR_WHEEL_SIZE_X = 10
CAR_WHEEL_SIZE_Y = 16
CAR_WHEEL_OFFSET = -23
CAR_REAR_WHEEL_OFFSET = 22
CAR_JUMP_SCALE = 2
CAR_JUMP_DURATION = 0.6
CAR_BOOSTER_VELOCITY = 7000000

CAR_WIDTH = 44
CAR_HEIGHT = 58
CAR_HAAN_WIDTH = 44
CAR_HAAN_HEIGHT = 58
CAR_POONG_WIDTH = 36
CAR_POONG_HEIGHT = 58

MISSILE_INITIAL_VELOCITY = 10000
MISSILE_DENSITY = 1
MISSILE_FORCE = 500000

PENGUIN_BLOCK_DENSITY = 0.1
PENGUIN_BLOCK_LINEAR_DAMPING = 0.8
PENGUIN_BLOCK_ANGULAR_DAMPING = 0.8
PENGUIN_BLOCK_RESTITUTION = 1

BOMBBOX_FORCE = 2000000	-- 3000000
--BOMBBOX_TORQUE = 100000	-- 20000000

TRAP_FORCE = 60000
TRAP_TORQUE = 3000000

ITEM_SIZE = 28

-- timerid
TIMER_RETIRECOUNT = 3
TIMER_GAMERESULT = 4
TIMER_GAMERESULT2 = 5

-- macro
function GetCarOID(playerno)
	return playerno*10000+1
end

----------------
-- State Flag --
----------------

require "RoomState"

RoomState.Open = 1
RoomState.PlayerOpen = 2
RoomState.ObserverOpen = 3
RoomState.Close = 4

require "GameState"

GameState.Wait = 1
GameState.Play = 2

require "UserState"

UserState.Join = 1
UserState.Wait = 2
UserState.Play = 3
UserState.View = 4
UserState.Leave = 5

-- b2Vec2 . b2Vec2
function VectorDot(avec, bvec)
	return avec.x * bvec.x + avec.y * bvec.y;
end

-- mul * b2Vec2
function Multiply(vec, mul)
	vec.x = vec.x * mul
	vec.y = vec.y * mul
	return vec
end

-- rotate (0, d) vector를 angle 각 만큼...
-- angle은 시계방향이 +
function VectorRotate(vec, angle)
	local d = -vec.y
	vec.x = d * math.cos(math.pi/2-angle)
	vec.y = -d * math.sin(math.pi/2-angle)
end

-- 기준점 s를 중심으로 점 p를 r만큼 회전했을 경우의 p'을 리턴
-- r은 시계 반대방향이 +
function VectorRotate2(p, s, r)
	local p_ = b2Vec2(0, 0)
	p_.x = (p.x-s.x) * math.cos(r) - (p.y-s.y) * math.sin(r)
	p_.y = (p.x-s.x) * math.sin(r) + (p.y-s.y) * math.cos(r)
	return p_
end

-- 기준점 s를 중심으로 p의 angle을 구한다.
function CalcAngle(p, s)
	local x = p.x-s.x
	local y = p.y-s.y
	local r = math.atan(x/y)
	return r
end

-- list
class 'List' (Serializable)

function List:__init() super()
	self.list = {}
end

function List:Add(item)
	self.list[#self.list + 1] = item
end

function List:GetCount()
	return #self.list
end

function List:Clear()
	self.list = {}
end

-- time to formatted string
function TimeToString(elapsedTime)
	if elapsedTime == nil then elapsedTime = 0 end

	local minutes = math.floor(elapsedTime/60)
	local seconds = math.floor(elapsedTime) - minutes*60
	local millisec = math.floor((elapsedTime - minutes*60 - seconds)*100)
	return string.format("%02d:%02d:%02d", minutes, seconds, millisec)
end

-- 카트 속도: 138   , 질량: 127.60
-- 풍장군 속도: 145.32, 질량: 104.4
-- 뺘기 속도: 153.86, 질량: 80
-- 토토 속도: 138   , 질량: 127.60
-- 후치 속도: 103.4 , 질량: 282.74
