-- Screen Size
SCREEN_SIZE_X = 800
SCREEN_SIZE_Y = 600

-- Tile Size
TILE_SIZE_X = 60
TILE_SIZE_Y = 60

-- Control Type
CONTROL_USER = 0
CONTROL_AI = 1
CONTROL_NETWORK = 2

-- Animation Type
ANITYPE_CAR = 0
ANITYPE_EFFECT = 1
ANITYPE_MISSILE = 2

-- Class Type
CLASS_MASTER = 0
CLASS_SLAVE = 1
CLASS_NPO = 2

-- box2d filter data Mask Bits
COLLISION_FILTER_MASK_HIGHWALL = 0x000000ff		-- (255) 1111 1111	모두 충돌 
COLLISION_FILTER_MASK_LOWWALL = 0x000000fd		-- (253) 1111 1101 비행기(점프카) 빼고 모두 충돌
COLLISION_FILTER_MASK_CAR = 0x000000fd			-- (253) 1111 1101 비행기(점프카) 빼고 모두 충돌
COLLISION_FILTER_MASK_PLANE = 0x0000000a		-- ( 10) 0000 1010 고벽과 비행기만 충돌
COLLISION_FILTER_MASK_MISSILE = 0x000000fd		-- (253) 1111 1101 비행기(점프카) 빼고 모두 충돌
COLLISION_FILTER_MASK_NOCOLLISION = 0x00000000	-- (  0) 0000 0000 충돌없음

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
CAR_DENSITY = 0.1
CAR_WHEEL_DENSITY = 0.1
CAR_WHEEL_SIZE_X = 10
CAR_WHEEL_SIZE_Y = 16
MISSILE_INITIAL_VELOCITY = 10000

-- timerid
TIMER_GAMERESULT = 2

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