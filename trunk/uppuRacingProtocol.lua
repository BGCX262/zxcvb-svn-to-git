-- Protocol
Noti_EnterPlayer = Event(1)
Noti_EnterPlayer.key = { no = 1, nick = 2, age = 3, gender = 4, hostno = 5, mapNo = 6, }

Noti_LeavePlayer = Event(2)
Noti_LeavePlayer.key = { no = 1 }

Object_Create = Event(100)
-- n=owner no, R=vr, X=vx, Y=vy, o=object id, c=class type
Object_Create.key={n=1,x=2,y=3,r=4,R=5,o=6,X=7,Y=8,c=9}

Object_Lock = Event(103)
Object_Lock.key = { no = 1, oid = 2 }

Object_NPO_List = Event(104)
Object_NPO_List.key = { list = 1 } -- n1 = 1, n2 = 2, n3 = 3, n4 = 4, n5 = 5, n6 = 6, n7 = 7, n8 = 8, n9 = 9, n10 = 10 }

Object_Sync = Event(101)
-- n=owner no, R=vr, X=vx, Y=vy, o=object id, c=class type
Object_Sync.key={n=1,x=2,y=3,r=4,R=5,o=6,X=7,Y=8,c=9}

Object_Delete = Event(102)
-- n=owner no, R=vr, X=vx, Y=vy, o=object id, c=class type
Object_Delete.key={n=1,x=2,y=3,r=4,R=5,o=6,X=7,Y=8,c=9}

Object_Force = Event(105)
Object_Force.key = { srcoid = 1, tgtoid = 2, fx = 3, fy = 4, x = 5, y = 6 }

Effect_Sync = Event(201)
Effect_Sync.key = { no = 1, oid = 2, effect = 3 }

RTT_Check = Event(999)
RTT_Check.key = { servertime = 1 }

RTT_Broadcast = Event(998)
RTT_Broadcast.key = { rtt1 = 1, rtt2 = 2, rtt3 = 3, rtt4 = 4 }

Noti_PlayerReady = Event(11)
Noti_PlayerReady.key = { no = 1 }

Noti_GameReady = Event(52)

Noti_Chat = Event(17)
Noti_Chat.key = { no = 1, chatText = 2 }

Noti_GameStart = Event(12)

Noti_ChangeCarType = Event(15)
Noti_ChangeCarType.key = { no = 1, carType = 2 }

Noti_ChangeHost = Event(51)
Noti_ChangeHost.key = { hostno = 1 }

Noti_ChangeMap = Event(53)
Noti_ChangeMap.key = { no = 1, }

-- map 로딩 완료 후, 게임 시작 가능함을 서버로 알림
Noti_LoadingCompleted = Event(13)

-- 모든 client가 LoadingCompleted이면, ReadyGo를 broadcast
Noti_GoCountDown = Event(18)
Noti_GoCountDown.key = { count = 1 }

Noti_ReadyGo = Event(14)

-- client -> server, 결승점 통과했음을 서버로 알림
Game_CutFinish = Event(501)
Game_CutFinish.key = { retire = 1, time = 2 }

-- server -> client, 서버가 순위를 판단해서 결과를 client로 알림
Game_CutFinishResult = Event(502)
Game_CutFinishResult.key = { no = 1, rank = 2, retire = 3 }

-- server -> client, 최종 결과를 client로 알림
Game_Result = Event(503)
Game_Result.key = { no1 = 1, no2 = 2, no3 = 3, no4 = 4, retireRank = 5 }

-- server -> client, 해당 map의 best record를 내려줌
Game_MapRecord = Event(504)
Game_MapRecord.key = { record = 1 }

-------------------
-- State Changes --
-------------------

Noti_ChangeRoomState = Event(1000)
Noti_ChangeRoomState.key = {
	stateFlag = 1,
}

Noti_ChangeGameState = Event(1001)
Noti_ChangeGameState.key = {
	stateFlag = 1,
}

Noti_ChangeUserState = Event(1002)
Noti_ChangeUserState.key = {
	stateFlag = 1,
	userNo = 2,
	isPlayer = 3,
}
