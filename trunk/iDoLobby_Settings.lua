
class 'iDoLobby_Settings'

---
-- 아이두게임 인트로 스플래시 화면표시 시간 (단위: 초)
-- 0으로 설정하면 인트로 화면표시를 생략하고 곧바로 로비로 진입을 시도한다.
--   [default] 1
iDoLobby_Settings.durationIntroSplash = 0

---
-- 게임가이드 화면표시 생략 여부
-- false이면 규격대로 해당 게임 전적이 없는 사용자에 한해 게임가이드 화면을 표시
-- true이면 무조건 게임가이드 화면을 표시하지 않음
--   [default] false
iDoLobby_Settings.skipGameGuide = false

---
-- 싱글게임으로 연결시킬 수 있는 버튼을 로비에 표시할 지 여부
-- true이면 로비 메인화면에 "싱글게임"이라는 버튼이 표시되고, 
-- 이 버튼을 누르면 iDoLobby_LobbyMainScene:OnbtnSingleGameMouseLClick이 실행된다.
--   [default] false
iDoLobby_Settings.supportSingleGame = false

---
-- 게임로비 입장 요청 후 최대 응답대기시간 (단위: 초)
--   [default] 10
iDoLobby_Settings.timeoutEnterLobby = 10

---
-- 게임방 입장 요청 후 최대 응답대기시간 (단위: 초)
--   [default] 10
iDoLobby_Settings.timeoutEnterRoom = 10   

---
-- 게임방 생성 요청 후 최대 응답대기시간 (단위: 초)
--   [default] 10
iDoLobby_Settings.timeoutCreateRoom = 10

---
-- 방제목 최대 글자수
iDoLobby_Settings.maxRoomTitleLength = 14

---
-- 비밀번호 최대 글자수
iDoLobby_Settings.maxPasswordLength = 8

---
-- 초대수락/거절창 최대 개수
iDoLobby_Settings.maxInviteAcceptDialogCount = 5

---
-- 게임방 생성 시 제공할 방제목 예제
iDoLobby_Settings.defaultRoomTitles = {"기다렸다!이런게임", "대박예감!함께해요!", "우리이겜띄워줘요!", "심심한데 게임한판!", "재미있는 게임한판!", "초보만 들어오세요", "고수만 들어오세요"}

---
-- 알림 메세지
--
iDoLobby_Settings.noticeEnterLobby	= {"게임 로비로 입장합니다.", "잠시만 기다려주세요..."}

-- 
iDoLobby_Settings.noticeKicked		= {"게임방으로부터 강제 퇴장당하였습니다."}

-- 
iDoLobby_Settings.noticeDuplicateLogin		= {"다른 컴퓨터에서 같은 ID로 중복 접속되어 ", "게임을 종료합니다."}

-- 
iDoLobby_Settings.noticeShutdown	= {"점검을 위해 서버가 종료됩니다.", "잠시 후 다시 접속해주시기 바랍니다."}

--
iDoLobby_Settings.noticeBadUser		= {"회원님께서는 불량처벌로 인행 이용정지 되었습니다.", "정지 기간 종료 후 다시 이용해 주시기 바랍니다."}

--
iDoLobby_Settings.noticeKickedFromLobby = {"로비로부터 강제 퇴장당하였습니다."}

--
iDoLobby_Settings.noticeGameURLCopied = {"현재 접속중인 게임 대기실 URL이 복사되었습니다.", 
										"게시판이나 메신저 창에 Ctrl + V 하여 초대해보세요.",
										"초대한 상대방이 복사된 URL 클릭 후 로그인하시면",
										"현재 접속중인 대기실로 바로 입장 가능합니다."}

iDoLobby_Settings.noticeGameURLError = {"게임오븐 또는 아이두게임랩에서 테스트할 때에는 ",
									    "게임초대 URL 복사 기능을 사용하실 수 없습니다."}

--
iDoLobby_Settings.noticeFailEnterInvited = {"초대받은 방이 유효하지 않습니다.", "초대해주신 분에게 확인해주세요."}

---
-- 에러 메세지
--
-- 1) 정원 초과
iDoLobby_Settings.errorExceedCapacity		= {"정원을 초과하여 게임 접속에 실패했습니다.", "잠시 후 다시 시도해주시기 바랍니다."}

-- 2) 서버 무응답
iDoLobby_Settings.errorServerNoResponse		= {"서버 접속이 불안정하여 게임 접속에 실패했습니다.", "잠시 후 다시 시도해주시기 바랍니다."}

-- 3) 서버 접속거부 
iDoLobby_Settings.errorServerRefusal		= {"서버 점검으로 인해 게임 접속에 실패했습니다.", "잠시 후 다시 시도해주시기 바랍니다."}

-- 4) 네트웍 접속 실패 
iDoLobby_Settings.errorNetworkUnreachable	= {"네트웍이 연결되어 있지 않아 게임에 접속할 수 없습니다.", "인터넷 연결 확인 후 다시 시도해주시기 바랍니다."}

-- 5) 알수 없는 "공통" 오류 
iDoLobby_Settings.errorUnknownFailure		= {"일시적인 오류로 게임 접속에 실패했습니다.", "잠시 후 다시 시도해주시기 바랍니다."}

-- 6) 방정원 초과
iDoLobby_Settings.errorExceedRoomCapacity   = {"정원을 초과하여 방 접속에 실패했습니다.", "다른 방으로 접속해주시기 바랍니다."}

-- 7) 중복 접속 (게임방 실행 중)
iDoLobby_Settings.errorDuplicateLogin		= {"같은 ID로 이미 게임을 실행중 입니다.", "게임을 종료합니다."}

-- 
-- 색상 값
--
iDoLobby_Settings.colorNormalText   = MakeColorKey(255, 103, 103, 103)
iDoLobby_Settings.colorSelectedText = MakeColorKey(255, 255, 255, 255)
iDoLobby_Settings.colorSelectedBG   = MakeColorKey(255,  98, 198, 216)
iDoLobby_Settings.colorDisabledText = MakeColorKey(255, 206, 206, 206)
iDoLobby_Settings.colorNoticeText	 = MakeColorKey(255, 255, 50, 10)
iDoLobby_Settings.colorRankUp         = MakeColorKey(255, 255, 68, 31)
iDoLobby_Settings.colorRankDown	   = MakeColorKey(255, 32, 153, 176)

-- 폰트
iDoLobby_Settings.fontNormalText	= FontInfo("돋움", 12, false)
iDoLobby_Settings.fontNormalNum	  = FontInfo("Verdana", 10, false)
--- 
-- 로비와 연결될 GameClient 구현 클래스 
require "uppuRacingGameClient"
iDoLobby_Settings.classGameClient = uppuRacingGameClient

iDoLobby_Settings.Evt_LoadLobbyList = Event(40000)

