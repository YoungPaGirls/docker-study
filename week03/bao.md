# 도커 컨테이너 다루기

## 도커의 생애주기

- 실행중, 정지, 파기의 3가지 상태를 가짐

### 실행 중 상태

- `docker container run` 명령의 인자로 지정된 도커 이미지를 기반으로 컨테이너가 생성되면 이 애플리케이션이 실행중인 상태가 컨테이너의 실행 중 상태가 된다.
  
### 정지 상태

- 컨테이너를 사용자가 명시적으로 정지하거나 컨테이너에서 실행된 애플리케이션이 정상/오류 여부를 막론하고 종료된 경우
- 컨테이너를 정지시키면 가상 환경으로서는 더 이상 동작하지 않지만 , 디스크에 컨테이너가 종료되던
시점의 상태가 저장돼 남는다. 그러므로 정지시킨 컨테이너를 다시 실행할 수 있다.

### 파기 상태

- 정지 상태의 컨테이너는 명시적으로 파기하지 않는 이상 디스크에 그대로 남아 있다
- 한 번 파기한 컨테이너는 다시 실행할 수 없다

## `docker container run` - 컨테이너 생성 및 실행

`docker container run -d -p 9000:8080 example/echo:latest`

- -p 옵션으로 포트 9000 을 8080 으로 포트 포워딩 했기 때문에 밑에처럼 http 요청을 컨테이너에 전달할 수 있다.
  
`curl http://localhost:9000/`

## `docker container run` 명령의 인자

- `docker container run` 명령에 명령 인자를 전달하면 Dockerfile 에서 정의했던 CMD 인스트럭션을 오버라이드 할 수 있다

## 컨테이너에 이름 붙이기

- docker container ls 로 확인하면 NAMES 칼럼에 무작정으로 이름이 지어진 걸 볼 수 있다
- --name 옵션을 사용하면 컨테이너에 원하는 이름을 붙일 수 있다.
- `docker container run --name [컨테이너명] [이미지명]:[태그]`   
  `docker container run -t -d --name gihyo-echo example/echo:latest`
- 이름 붙인 컨테이너는 보통 운영 환경에서는 사용되지 않는다
  - 새로 실행하려면 같은 이름을 갖는 기존의 컨테이너늘 삭제해야 하기 때문이다.

## docker container ls - 도커 컨테이너 목록 보기

- 목록 확인이 가능하도록 2개의 컨테이너를 실행하고 docker container ls 명령을 실행하면 컨테이너 목록이 출력된다.
- CONTAINER ID
  - 컨테이너를 만들기 위한 유일 식별자
- IMAGE
  - 컨테이너를 만드는 데 사용된 도커 이미지
- COMMAND
  - 컨테이너에서 실행되는 애플리케이션 프로세스
- CREATED
  - 컨테이너 생성 후 경과된 시간
- STATUS
  - Up(실행 중), EXITED(종료) 등 컨테이너의 실행 상태
- PORTS
  - 호스트 포트와 컨테이너 포트의 연결 관계 (포트 포워딩)
- NAMES
  - 컨테이너의 이름

### 컨테이너 ID 만 추출하기

- docker container ls -q

### 컨테이너 목록 필터링하기

- docker container ls --filter "필터명=값"
- 컨테이너명 기준으로 보려면 name 필터
  - `docker container ls --filter "name=echo1"`
- 이미지 기준으로 보려면 ancestor 필터
  - `docker container ls --filter "ancestor-example/echo"`

### 종료된 컨테이너 목록 보기

- -a 옵션을 사용해서 종료된 컨테이너 포함한 전체를 볼 수 있음
- docker container ls -a

## docker container stop - 컨테이너 정지하기

- docker container stop 컨테이너ID_혹은_컨테이너명
- `docker container run -d -p 9000:8080 example/echo:latest`
- `docker container stop a7afc1df60ac`
- 이름 붙인 컨테이너라면 그냥 이름을 붙이면 됨

## docker container restart - 컨테이너 재시작하기

- docker container restart 컨테이너ID_혹은_컨테이너명

## docker container rm - 컨테이너 파기하기

- docker container rm 컨테이너ID_혹은_컨테이너명
- 개발 업무 중 컨테이너 실행 및 정지를 반복하다 보면 정지된 컨테이너가 여럿 보인다
- 정지된 상태에서도 디스크에 남아 있다.
- 그것들은 용량을 차지하고, 또한 이름이 겹치면 안 되기 때문에 삭제해 주는 것이 좋다.
- **먼저 stop 시키고 삭제해야 된다**
  - 아니었음. 실행 중인 거 삭제하려면 -f 사용하면 됨

### docker container run --rm 을 사용해 컨테이너 정지 시 함께 삭제하기

- 일일이 삭제해 주는 게 귀찮다면 --rm 옵션을 붙인다
- --rm 은 --name 과 함께 사용하는 경우가 많다. 
  - 같은 이름으로 컨테이너 실행하려고 하면 이름이 충돌해 오류가 발생하기 때문
  - 따라서 이름이 붙은 컨테이너를 자주 생성하고 정지해야 한다면 --rm 옵션을 사용하는 것이 편하다

## docker container logs - 표준 출력 연결하기

- -f 옵션을 사용하면 새로 출력되는 표준 출력 내용을 계속 보여준다
- `docker run -d --name jenkins-container -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts` 으로 실행
- `docker container logs -f $(docker container ls --filter "ancestor=jenkins/jenkins:lts" -q)` 으로 출력

## docker container exec - 실행 중인 컨테이너에서 명령 실행하기

- docker container exec [option] 컨테이너ID_또는_컨테이너명 컨테이너에서_실행할_명령
- `docker container run -t -d --name echo --rm example/echo:latest` 컨테이너 하나 실행
- `docker container exec echo pwd` pwd 명령어 실행
- 마치 ssh 로 로그인한 것처럼 컨테이너 내부를 조작할 수 있따
- -it 옵션을 통해서 컨테이너 셸을 통해 다룰 수 있다
  - 이게 그때 컨트롤+c 가 동작하게 한 그 옵션인데

## docker container cp - 파일 복사하기

- Dockerfile 에서의 COPY 는 이미지를 빌드할 때 호스트에서 복사해 올 파일을 정의
- docker container cp 는 실행 중인 컨테이너와 파일을 주고받기 위한 명령
- `docker container cp [options] 컨테이너 ID_또는_ 컨테이너명:원본파일 대상파일`
- `docker container cp [options 호스트_원본파일 컨테이너ID_또는_컨테이너명:대상파일`
- `docker container cp echo:/echo/main.go .` 컨테이너 안에 있는 /echo/main.go 파일을 현재 작업 디렉터리로 복사
- `docker container cp ./week03/bao/dummy.txt  echo:/tmp` 반대로 복사

# 운영과 관리를 위한 명령

## prune - 컨테이너 및 이미지 파기 

### docker container prune

- 도커를 오래 사용하다 보면 디스크에 저장된 컨테이너와 이미지가 점점 늘어나는데, prune 으로 필요없는 이미지, 컨테이너를 일괄 삭제할 수 있다
- 실행 중이 아닌 모든 컨테이너를 삭제한다

### docker image prune

- 태그가 붙지 않은 모든 이미지를 사용한다

### docker system prune

- 도커 이미지 및 컨테이너, 볼륨, 네트워크 등 모든 도커 리소스를 일괄적으로 삭제한다

## docker container stats - 사용 현황 확인하기

- `docker container stats [options] [ 대상_컨테이너 ID ...]`

# 도커 컴포즈로 여러 컨테이너 실행하기

- 시스템은 일반적으로 단일 애플리케이션이나 미들웨어만으로 구성되는 것이 아니다.
- 웹 애플리케이션은 리버스 프록시 역할을 하는 웹 서버를 프론트엔드에 배치하고 그 뒤로 비즈니스 로직이 담긴 애플리케이션 서버가 위치해 데이터 스토어 등과 통신하는 구조로 완성된다.
- 도커 컨테이너 = 단일 애플리케이션이라고 봐도 무방하다
- 도커 컨테이너로 시스템을 구축하면 하나 이상의 컨테이너가 서로 통신하며, 그 사이에 의존관계가 생긴다.
- 환경 변수를 어떻게 전달할지, 포트 포워딩을 어떻게 설정해야 하는지 등의 요소를 적절히 관리해야 한다

## docker-compose 명령으로 컨테이너 실행하기

- Compose 는 yaml 포맷으로 기술된 설정 파일로, 여러 컨테이너의 실행을 한번에 관리할 수 있다
- 여러 컨테이너를 한꺼번에 시작하려면 docker-compose up 명령을 사용하면 된다.
- 컴포즈를 사용하면 이미 존재하는 도커 이미지 뿐만 아니라 docker-compose up 명령을 실행하면서 이미지를 함께 빌드해 새로 생성한 이미지를 실행할 수도 있다
- docker-compose.yml  파일에서 image 속성을 지정하는 대신, build 속성해 Dockerfile 이 위치한 상대 경로를 지정한다
- --build 옶션을 사용하면 이미지를 강제로 다시 빌드하게 할 수 있다. 이미지가 자주 수정될 떄 사용하는 것이 좋다

# 컴포즈로 여러 컨테이너 실행하기

## 젠킨스 컨테이너 실행하기

- volumes 는 호스트와 컨테이너 사이에 파일을 복사하는 것이 아니라 파일을 공유할 수 있는 매커니즘이다
- 젠킨스 공식 이미지는 /var/jenkins_home 아래에 데이터가 저장된다
- 따라서 컴포즈로 실행한 젠킨스 컨테이너를 종료했다가 재시작해도 초기 설정이 유지된다.

### 근데 이거 설치가 fail남

- 찾아 보니 젠킨스 버전이 낮아서 그렇다길래 image 를 latest 로 변경함
- 근데 또 관리자 비번이 없어가지고
  - `docker exec -it master cat /var/jenkins_home/secrets/initialAdminPassword`
    - 이렇게 해서 비번 찾고
    - admin / 위에서 나온 결과 치면 됨

## 마스터 젠킨스용 ssh 생성

- 관리 기능이나 작업 실행 지시는 마스터 인스턴스가 맡고, 실제 작업 진행은 슬레이브 인스턴스가 담당한다.
- 첫번째 컨테이너가 마스터 젠킨스 역할을 하게 된다.
- `docker container exec -it master ssh-keygen -t rsa -C ""`
- 이렇게 만든 id_rsa 파일은 마스터 젠킨스가 슬레이브 젠킨스에 접속할 때 사용할 키다

## 슬레이브 젠킨스 컨테이너 생성

- 슬레이브 컨테이너는 slabe01 이름을 붙인다

### ssh 접속 허용 설정

- ssh 로 접속하는 슬레이브 용도로 구성된 도커 이미지 jenkinsci/ssh-slave 를 사용한다
- 환경 변수 JENKINS_SLAVE_SSH_PUBKEY 는 이 키를 보고 마스터 젠킨스임을 식별하게 된다
- 외부 환경 변수로 받아오게 해야 한다

### ssh 접속 대상 설정

- 마스터 컨테이너가 어떻게 슬레이브 컨테이너를 찾아 추가할 것인가 하는 문제가 남아있다.
- 컴포즈를 사용하면 links 요소를 사용해 다른 services 그룹에 해당하는 다른 컨테이너와 통신하면 된다.

지금까지 진행한 과정은

1. 마스터 컨테이너를 먼저 생성한 다음 마스터 ssh 공개키를 생성
2. docker-compose.yml 파일에 슬레이브 컨테이너를 추가하고, 앞에서 만든 마스터의 ssh 공개키를 환경 변수에 설정
3. links 요소를 활용해 마스터 컨테이너가 슬레이브 컨테이너로 통신할 수 있게 설정

### 마지막 설정

- 신규 노드 생성 항목에서 slave01 을 추가한다