## 도커란?

- **컨테이너 기술**을 활용하여 각각의 프로그램을 **분리된 환경**에서 실행할 수 있게 해주는 플랫폼

---

## 컨테이너란?

- 마치 **하나의 컴퓨터 안에서 또 다른 컴퓨터를 만든 것**과 같은 독립된 환경
- 예를 들어, 윈도우에서 여러 사용자를 나눠 쓰는 것처럼 각각의 컨테이너는 서로 다른 사용자 공간처럼 동작

### 컨테이너의 독립성

- **디스크**: A 컨테이너에서 B 컨테이너 내부 파일에 접근할 수 없음
- **네트워크**: 각 컨테이너는 고유한 IP와 포트를 가짐

---

## 이미지(Image)

- 프로그램 실행에 필요한 설치 과정, 설정, 버전 정보 등을 포함하는 **실행 패키지**
- 닌텐도 칩처럼 복잡한 설치 없이 실행 가능

```bash
# 이미지 다운로드
$ docker pull {이미지명}

# 특정 태그 버전으로 다운로드
$ docker pull {이미지명}:{태그명}  # 태그 생략 시 latest 다운로드

# 이미지 목록 확인
$ docker image ls

# 이미지 삭제
$ docker image rm {IMAGE ID}           # 일부 ID만 적어도 됨
$ docker image rm -f {IMAGE ID}        # 강제 삭제
$ docker image rm $(docker images -q)  # 사용하지 않는 이미지 일괄 삭제
$ docker image rm -f $(docker images -q)  # 중단된 이미지까지 모두 삭제
```

- **이미지 저장소**: Docker Hub

---

## 컨테이너(Container)

- 이미지를 기반으로 만들어진 **미니 컴퓨터 환경**

```bash
# 컨테이너 생성
$ docker create nginx

# 컨테이너 생성 및 실행 (포그라운드)
$ docker run nginx

# 백그라운드 실행
$ docker run -d nginx

# 이름 지정하여 실행
$ docker run -d --name my-web-server nginx

# 포트 연결
$ docker run -d -p 4000:80 nginx  # 호스트:컨테이너
```

---

## 컨테이너 명령어 정리

```bash
# 실행 중인 컨테이너 확인
$ docker ps

# 전체 컨테이너 확인 (중지 포함)
$ docker ps -a

# 컨테이너 시작
$ docker start {container_id}

# 컨테이너 중지
$ docker stop {container_id}

# 컨테이너 강제 종료
$ docker kill {container_id}

# 컨테이너 삭제
$ docker rm {container_id}
$ docker rm -f {container_id}  # 실행 중도 강제 삭제
$ docker rm $(docker ps -qa)   # 모든 컨테이너 삭제
```

---

## 컨테이너 로그 확인

```bash
# 기본 로그 확인
$ docker logs {컨테이너명}

# 마지막 10줄만 보기
$ docker logs --tail 10 {컨테이너명}

# 실시간 로그 보기
$ docker logs -f {컨테이너명}

# 기존 로그 없이 실시간 보기
$ docker logs --tail 0 -f {컨테이너명}
```

---

## 컨테이너 내부 접속

```bash
# bash 쉘로 접속
$ docker exec -it {컨테이너 ID} bash

# 접속 종료
$ exit
```
