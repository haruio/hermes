# Hermes
```
./build_umbrella.sh

./start_umbrella.sh
```
**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add  to your list of dependencies in `mix.exs`:

        def deps do
          [{:, "~> 0.0.1"}]
        end

  2. Ensure  is started before your application:

        def application do
          [applications: [:]]
        end

## TODO List
1. hermes-api
	2. **API 개발**
		3. push
			4. [x] 즉시 발송
			5. [ ] 예약 발송
			6. [ ] 예약 수정
			7. [ ] 예약 삭제
			6. [ ] 발송 내역 조회
			6. [ ] 발송 통계 조회
		4. mail
			5. [ ] 즉시 발송
			6. [ ] 예약 발송
			7. [ ] 예약 수정
			8. [ ] 예약 삭제
			9. [ ] 발송 내역 조회
			10. [ ] 발송 통계 조회
			11. [ ] 템플릿 추가
			12. [ ] 템플릿 삭제
			13. [ ] 템플릿 수정
			14. [ ] 템플릿 조회
		15. service
			16. [ ] 서비스 추가
			17. [ ] 서비스 삭제
			18. [ ] 서비스 수정
			19. [ ] 서비스 조회
			20. [ ] 유저 추가
		16. user
			17. [ ] 회원 가입
			18. [ ] 회원 탈퇴
			19. [ ] 로그인
			20. [ ] 로그아웃
			21. [ ] 회원 정보 수정
		22. options
			23. [ ] 옵션 수정
	22. **추가 개발**
		23. [ ] 로컬 캐쉬 추가
		24. [ ] 분산 환경 추가
2. hermes-mail
	3. **기능**
		4. [ ] 메일 발송
	5. **추가 개발**
		6. [ ] 분산 환경 추가
3. hermes-push
	4. **기능**
		5. [ ] 푸시 발송
	6. **추가 개발**
		7. [ ] 분산 환경 추가
4. hermes-queue
	5. **기능**
		6. [x] 큐
	7. **추가 개발**
		8. [ ] 클러스터링 추가
5. hermes-scheduler
	6. **기능**
		7. [ ] 작업 예약
		8. [ ] 예약 작업 삭제
		9. [ ] 예약 작업 수정
		10. [ ] 예약 작업 실행
	7. **추가 개발**
		8. [ ] 분산 환경 추가
6. hermes-web
	7. **화면 개발**
		8. [ ] 홈 화면
		9. [ ] 회원 가입 페이지
		10. [ ] 푸시 발송 페이지
		11. [ ] 푸시 발송 내역 리스트 페이지
		12. [ ] 푸시 발송 내역 상세 페이지
		13. [ ] 메일 발송 페이지
		14. [ ] 메일 발송 내역 리스트 페이지
		15. [ ] 메일 발송 내역 상세 페이지
		16. [ ] 서비스 등록 페이지
		17. [ ] 서비스 목록 페이지
		18. [ ] 서비스 수정 페이지
19. hermes-feedback
	20. **기능**
		21. feedback 메세지 수신
