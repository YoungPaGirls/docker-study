# 02. 도커 컨테이너 배포 

### 학습 목표
- 도커 이미지 생성
- 도커 컨테이너 생성
- 도커 포트 포워딩 기능 사용


## 1. 컨테이너로 애플리케이션 실행하기  
> 도커 이미지: 컨테이너 생성 템플릿. 컨테이너를 구성하는 파일 시스템 + 애플리케이션 설정의 통합체    
> 도커 컨테이너: 파일 시스템과 애플리케이션이 구체화되어 실행되는 상태이다. 이미지를 기반으로 생성된다.    

컨테이너로 애플리케이션을 실행하려면 이미지를 먼저 만들어야 한다.  
도커 이미지를 만들기 위해 Dockerfile을 작성하고, 만든 이미지를 사용해서 도커 컨테이너를 실행한다.  

## 도커 이미지와 도커 컨테이너  

### 이미지 받기
-  `docker image pull {이미지명}`
```shell 
docker image pull gihyodocker/echo:latest 
```

### 이미지로 컨테이너 생성 및 실행하기
- `docker container run`
- (옵션) 터미널 할당하기: `-t` (출력 형식 유지에 도움)
- (옵션) 포트포워딩 적용하기: `-p {호스트 포트}:{컨테이너 포트}`
```shell  
docker container run -t -p 9000:8080 gihyodocker/echo:latest  

# 테스트를 원하면 아래 명령어를 터미널에 입력해보면 된다. 
# curl http://localhost:9000
```  

### 컨테이너 정지하기  
- `docker container stop {컨테이너 id}`  
- 실행 중인 컨테이너 전체 정지: `docker stop $(docker container ls -q)`
  - `docker container ls -q`: 실행 중인 컨테이너 id 출력  

## 간단한 애플리케이션과 도커 이미지 만들기
- 서버 애플리케이션 구현 (main.go)  
- Dockerfile 작성  

### Dockerfile
> 전용 도메인 언어로 이미지의 구성을 정의 한다.    
> 인스트럭션(명령): FROM, RUN 같은 키워드    

```dockerfile
FROM golang:1.9

RUN mkdir /echo
COPY main.go /echo
CMD ("go", "run", "/echo/main.go"]
```
- FROM 인스트럭션
  - `FROM {이미지명}:{태그}`
  - 도커 이미지의 베이스 이미지 지정  
  - Dockerfile 로 이미지 빌드 시 FROM 인스트럭션에 지정된 이미지 내려 받음  
  - 도커 허브(Docker Hub) 라는 레지스트리에 공개된 이미지를 참조한다. 
  - 태그는 이미지 식별자 (ex. 버전) / 고유 해시값이 있지만 인간친화적이지 않아서 태그 사용함  


- RUN 인스트럭션  
  - `RUN {실행 명령}` 
  - 도커 이미지 실행 시, 컨테이너 내부에서 실행할 명령 정의  


- COPY 인스트럭션 
  - `COPY {파일 또는 디렉터리}` 
  - 호스트 머신의 파일 또는 디렉터리를 컨테이너 내부로 복사  


- CMD 인스트럭션  
  - 컨테이너 실행 시, 내부에서 실행할 프로세스 지정 
  - 컨테이너 시작될 때 한번 실행 
  - RUN과 차이점: RUN은 애플리케이션 업데이트 및 배치, CMD는 애플리케이션 실행 명령어  
  - `CMD ["{실행파일}". "{인자1}". "{인자2}"]` 


- 이 외에도 LABEL, ENV, ARG 등의 인스트럭션이 있다.  

## 이미지 빌드 & 컨테이너 실행  
### 이미지 빌드  
```shell
#docker image build -t {이미지명}:{태그명} {Dockerfile 경로} 
docker image build -t example/echo:latest .
```
- `-t`: 이미지명 지정 / 태그명 지정 (생략 가능, 생략 시 latest 자동)  
- 이미지명은 반드시 지정하는 것이 좋음 (구별 용이)
- 위 예시에서 `example` 은 네임스페이스이며, 이미지명 충돌을 방지할 수 있다.

### 컨테이너 실행  
```shell
# docker container run {이미지명}
docker container run -d example/echo:latest
```
- `-d`(선택): 백그라운드 실행 옵션  


### 포트 포워딩  
> 호스트 머신의 포트를 컨테이너 포트와 연결해 컨테이너 밖에서 온 통신을 컨테이너 포트로 전달하는 것  

- `-p {호스트 포트}:{컨테이너 포트}`
- `-p {컨테이너 포트}`와 같이 호스트 포트 생략 가능 (빈 포트 자동 할당)

---

## 2. 도커 이미지 다루기  
> 도커 이미지는 도커 컨테이너를 만들기 위한 템플릿이다.  

- 이미지는 운영 체제로 구성된 파일 시스템, 애플리케이션 등 실행 환경의 설정 정보까지 포함하는 아카이브  
- Dockerfile 를 이미지라고 볼 수 없음  

- `docker image --help` 명령어로 도움말 확인 가능  


### 이미지 빌드  
```shell
 docker image build -f DOckerfile-test -t 이미지명[:태그명] Dockerfile의_경로
```
- `-t` (옵션): 태그 옵션 
- `-f` (옵션): 기본적으로 빌드할 때 Dockerfile 이름으로 파일을 찾음. 다른 이름 쓰려면 -f 옵션으로 이름을 알려줘야 함  
- `--pull`(옵션)
  - `docker image build --pull=true t- example/echo:latest .`
  - 빌드할 때 FROM 절에 지정한 베이스 이미지는 한번 받고 계속 사용함. -> 변경된 부분만 반영해 빌드 (나머지는 캐시)  
  - 그러나 `--pull` 사용하면 매번 새로 받아옴.
  - 속도 느림 / 실무에서는 최신판보다는 태그로 지정한 이미지 사용  

### 이미지 검색 
> 도커 허브: 도커 이미지 레지스트리    
> 깃허브처럼 리포지토리 생성 가능    
> 리포지토리를 사용해 도커 이미지 관리
  
```shell
#docker search [options] 검색_키워드
docker search mysql  
```
- 허브에 등록된 리포지토리 검색
- `--limit` (옵션)
  - 최대 검색 건수 제한   
  - `docker search --limit 5 mysql`
- 검색 결과는 star 순으로 정렬  
- 공식 리포지토리는 네임스페이스 생략 가능  



### 이미지 내려받기  
> 도커 레지스트리에서 도커 이미지를 내려받을 수 있다.  
> 내려받은 이미지로 컨테이너를 생성할 수 있다.  

```shell
#docker image pull [options] 리포지토리명[:태그명]
docker image pull jenkins:latest
```

### 보유한 이미지 목록 보기  
```shell
#docker image ls [options] [리포지토리[:태그]]
docker image ls
```
- 호스트 OS에 저장된 도커 이미지 목록 조회  


### 새로운 태그 부여
```shell
#docker image tag 기반이미지명[:태그] 새이미지명[:태그]
docker image tag example/echo:latest example/echo:0.1.0
```

### 이미지 외부에 공개하기  
> 도커 이미지를 도커 허브 등의 레지스트리에 등록할 수 있다.  

```shell
docker image push [options] 리포지토리명[:태그]
```
- 도커 허브 계정 생성  
- `docker login` 으로 도커 허브 로그인 
- 이미지 네임스페이스를 도커 허브 ID로 변경  
- `docker iamge push` 로 도커 허브에 등록  
