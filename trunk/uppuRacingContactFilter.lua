class 'uppuRacingContactFilter' (b2ContactFilter)

function uppuRacingContactFilter:__init() super()
end

function uppuRacingContactFilter:ShouldCollide( shape1, shape2 )
	local filter1 = shape1:GetFilterData()
	local filter2 = shape2:GetFilterData()
	local body1 = shape1:GetBody()
	local body2 = shape2:GetBody()
	local object1 = body1:GetUserData()
	local object2 = body2:GetUserData()


	-- 두 모양의 groupIndex가 세팅되어 있고, 같을 경우
	if filter1.groupIndex == filter2.groupIndex and filter1.groupIndex ~= 0 then
		return filter1.groupIndex > 0
	end

	-- 두 모양의 필터 데이터를 비교해서 결과를 리턴한다.
	local collide = Bit.And( filter1.maskBits, filter2.categoryBits) ~= 0 and
					Bit.And( filter1.categoryBits, filter2.maskBits ) ~= 0

	-- missile의 경우 owner가 같으면 충돌아님.
	if collide then
		if ((filter1.categoryBits == COLLISION_FILTER_CATEGORY_MISSILE and filter2.categoryBits == COLLISION_FILTER_CATEGORY_CAR )
			or (filter2.categoryBits == COLLISION_FILTER_CATEGORY_MISSILE and filter1.categoryBits == COLLISION_FILTER_CATEGORY_CAR ))
			and object1.owner == object2.owner -- playerno 비교
		then
			return false
		end
	end

	--print (string.format("collide: filter1[%d][%d], filter2[%d][%d]", filter1.categoryBits, filter1.maskBits, filter2.categoryBits, filter2.maskBits))
	return collide
end