# 스톡옥션 (StockAuction)
중고 혹은 안쓰는 제품을 경매를 통해 사고 팔 수 있는 거래 플랫폼 앱

## 프로젝트 기간
- 2024.09.20 ~ 2024.10.04 (2주)

## 팀원 및 담당 파트
### 정원교 (팀장)
- 경매 관련 기능
  - 경매 게시물 목록
  - 경매 상세 기능
  - 경매 추가 기능
  - 경매 수정 및 삭제 기능
- FCM 푸시 서버 로직
- 시연 영상 촬영 및 나레이션

### 고규화 (팀원)
- 로그인 관련 기능
- 댓글 및 좋아요 기능
- 내 입찰 목록 기능
- 좋아요 목록 기능
- 현재 입찰 시세 목록 기능
- 검색 기능

### 조정현 (팀원)
- 채팅 관련 기능
  - 갤러리, 카메라를 사용한 이미지 전송 기능
  - 거래 확정 메시지 보내기 기능
  - 채팅방 목록
- 나의 구매, 판매 목록 기능
- 사용자 프로필 기능
- 사용자가 판매중인, 판매완료 목록 기능
- 낙찰된 경매 목록 기능
- 앱 아이콘, 유저 기본 프로필 이미지 생성
- 시연 영상 촬영 및 편집
 
### 최지희 (팀원)
- 마이페이지 UI
- 홈 화면 UI
- 프로필 사진 변경 기능
- 회원 정보 수정 기능
- 로그아웃, 회원 탈퇴 기능
- 다크모드 전환 기능

## 주요 기능
### 1.유저 기능
- 로그인, 회원가입
- 비밀번호 변경
- 계정 정보 변경 및 탈퇴
- 사용자가 좋아요 누른 목록 확인
- 유저 프로필 확인

### 2. 경매 기능
- 물건 등록
- 입찰
- 실시간 낙찰
- 현재 입찰가, 입찰 기록, 입찰자 확인
- 댓글 작성, 수정, 삭제 및 작성자 프로필 확인
- 입찰, 낙찰 시 푸쉬 알림

### 3. 채팅 기능
- 실시간 채팅
- 채팅방 푸쉬 알림
- 거래 확정 버튼 전송
- 갤러리에 저장된 사진 및 카메라로 찍은 사진 전송

### 4. 마이페이지 기능
- 회원 정보 수정
- 계정 정보 변경 및 탈퇴
- 현재 나의 판매중, 판매 완료 물품 목록 확인
- 내가 구매한 물품 목록 확인
- 내가 입찰중인 목록 확인
- 일반/다크 모드 테마 변경


## 기술 스택
### Frontend
- Flutter
- Provider (상태 관리)
- Firebase UI

### Backend
- Firebase
  - Authentication
  - Cloud Firestore
  - Cloud Storage
  - Cloud Functions
  - Cloud Messaging (FCM)
- Firebase App Check
- 보안 규칙 적용

### 인증
- 이메일/비밀번호

## 환경 설정
### 필수 요구사항
- Flutter SDK
- Firebase CLI
- Node.js
- Xcode (iOS 빌드용)
- Android Studio (Android 빌드용)

## 시연 영상
[![StockAuction 시연영상](https://postfiles.pstatic.net/MjAyNTAzMDVfMSAg/MDAxNzQxMTYyNDYwOTg2.WnEdAeRfkfKZcizqLKZMCFc3gSlh1Ey_MpQXa7gV_CAg.wl0x29w7jIKtap9fxwdS0-yMfvezl2Dht2H__M2hrn0g.PNG/%EC%8A%A4%ED%86%A1%EC%98%A5%EC%85%98.PNG?type=w966)](https://www.youtube.com/watch?v=NTRIucfXQ2I)

## 저장소
[GitHub 저장소](https://github.com/JeongHyeon-Jo/Travel-On/tree/main)
