# 02. 도커 컨테이너 배포  


## 3. 도커 컨테이너 다루기  
> 도커 컨테이너 = 가상 환경 = 파일 시스템, 애플리케이션을 함께 담는 박스  

### 도커 컨테이너의 생애주기  
> 도커 컨테이너의 3가지 상태(생애주기): 실행 중, 정지, 파기  

같은 이미지로 생성해도 별개의 상태를 가진다.  

1. 실행 중 상태   
- docker container run 명령으로 컨테이너가 생성되면 Dockerfile 내 CMD/ENTRYPOINT 인스트럭션에 정의된 애플리케이션 실행 
- 애플리케이션이 실행 중인 상태 = 컨테이너의 실행 중 상태

2. 정지 상태  
- docker container stop 등과 같이 사용자가 명시적으로 정지한 경우 / 애플리케이션이 어떠한 이유로 종료된 경우 정지 상태로 전환  
- 디스크에 컨테이너 종료 시점 상태가 저장 됨 (다시 실행 가능)  

3. 파기 상태  
- 명시적으로 파기하지 않으면 컨테이너가 디스크에 남아있다.  
- 불필요한 컨테이너 제거 필요  

### 컨테이너 명령  

1. 컨테이너 생성 및 실행
```shell
# docker container run [option] 이미지명[:태그] [명령] [명령 인자...]
docker container run -d -p 9000:8080 example/echo:latest  
```

- docker container run 명령에 인자 전달 시, Dockerfile 내 CMD 인스트럭션 오버라이드  
    ```shell
    docker container run -it alpine:3.7 uname -a  
    ```

- `--name` 옵션으로 컨테이너에 이름 붙이기  
  - 개발용으론 자주 사용되지만, 운영 환경에서는 자주 사용 X (반복적인 컨테이너 생성 및 삭제 과정 때문에) 
  ```shell
  docker container run --name [컨테이너명] [이미지명]:[태그]
  ```


2. 도커 컨테이너 목록 보기  
```shell
docker container ls [options]
```

- 컨테이너 ID  추출은 `-q`옵션 
    ```shell
    docker container ls -q 
    ```

- 컨테이너 목록 필터링하기  
    ```shell
    docker container ls --filter "필터명=값"
    ```

- 종료된 컨테이너 목록보기 (전체 컨테이너 목록)
    ```shell
    docker container ls -a 
    ```

3. 컨테이너 정지하기 
```shell
docker container stop 컨테이너ID_또는_컨테이너명
```

4. 컨테이너 재시작하기  
```shell
docker container restart 컨테이너ID_또는_컨테이너명 
```

5. 컨테이너 파기하기  
```shell
docker container rm 컨테이너ID_또는_컨테이너명
```

- 현재 실행 중인 컨테이너 삭제 시 `-f` 옵션 사용 
```shell
docker container rm -f 컨테이너ID_또는_컨테이너명
```

6. 표준 출력 연결하기 
```shell
docker container logs [options] 컨테이너ID_또는_컨테이너명
```
- `-f` 옵션 사용 시 출력 내용 계속 볼 수 있음  

7. 실행 중인 컨테이너에서 명령 실행하기 
```shell
docker container exec [options] 컨테이너ID_또는_컨테이너명 컨테이너에서_실행할_명령  
```
- `-it` 옵션 (i, t): 표준 입력 연결 유지 & 유사 터미널 할당   


8. 파일 복사하기
> 실행 중인 컨테이너와 파일을 주고 받기 위한 명령  

- 컨테이너간 파일 복사 
```shell
docker container cp [options] 컨테이너ID_또는_컨테이너명:원본파일 대상파일
```

- 컨테이너와 호스트 간 파일 복사 
```shell
docker container cp [options] 호스트_원본파일 컨테이너ID_또는_컨테이너명:대상파일
```

## 4. 운영과 관리를 위한 명령 
### prune - 컨테이너 및 이미지 파기
> 필요없는 이미지나 컨테이너를 일괄 삭제


- 실행 중이 아닌 모든 컨테이너 삭제
```shell
docker container prune [options]
```


- 태그가 붙지 않은 모든 이미지 삭제 (dangling)
```shell
docker image prune [options]
```

- 도커 리소스 일괄 삭제 (이미지, 컨테이너, 볼륨 등)  
```shell
docker system prune 
```

### 사용 현황 확인
```shell
docker container stats [options] [컨테이너ID ...]
```

## 5. 도커 컴포즈로 여러 컨테이너 실행하기  
> 도커는 애플리케이션 배포에 특화된 컨테이너이다.  
> 도커 컨테이너로 시스템을 구축하면 하나 이상의 컨테이너가 서로 통신하며, 그 사이에 의존관계가 생긴다.  
> 그렇기 때문에 컨테이너간 의존관계를 적절하게 관리해야 한다.  

### docker-compose 
> 도커 컴포즈(Docker Compose): yaml 포맷으로 기술된 설정 파일  

- docker compose 버전 확인
```shell
docker compose version
```

1. docker compose로 컨테이너 실행  
- docker-compose.yml 작성 
```yml
version: "3" # 컴포즈 파일 해석을 위한 문법 버전 
services:
  echo: # 컨테이너 이름
    image: example/echo:latest # 실행 대상 이미지 
    ports:
      - 9000:8080 # 포트포워딩 설정 지정  
```
- 여러 컨테이너 한번에 시작 
```shell
docker-compose up -d 
```

- yml 파일에 정의한 모든 컨테이너 종료 
```shell
docker-compose down 
```

- 이미지를 생성하면서 컨테이너 시작하기
  - docker-compose.yml 에 Dockerfile이 위치한 상대 경로를 `build` 속성에 명시   
  - 이미 빌드한 적 있으면 빌드 생략
    ```yml
    version: "3"
    services:
      echo:
        build: .
    #    image: example/echo:latest
        ports:
          - 9000:8080
    ```
    ```shell
    docker-compose up -d --build 
    ```
    
## 6. 컴포즈로 여러 컨테이너 실행하기  

### 젠킨스 컨테이너 실행하기
- docker-compose.yml 파일 작성 
```yml
version: "3"
services:
  master:
    container_name: master
    image: jenkins/jenkins:2.142-slim
    ports:
      - 8080:8080
    volumes: # 호스트-컨테이너 사이에 파일을 공유할 수 있는 메커니즘  
      - ./jenkins_home:/var/jenkins_home
```

- 컴포즈 실행 (`-d` 옵션 사용 X - 패스워드 때문에 포어그라운드로 실행) 
```shell
docker-compose up 
```

- 터미널에 출력되는 내용에서 비밀번호 복사해놓기
```shell
master  | Jenkins initial setup is required. An admin user has been created and a password generated.
master  | Please use the following password to proceed to installation:
master  | 
master  | {비밀번호 부분}
master  | 
master  | This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
```

- localhost:8080 에 접속하여 패스워드 입력

### 마스터 젠킨스 용 SSH 키 생성  
> 슬레이브 젠킨스 컨테이너를 추가해보자.   
> 마스터: 작업 실행 지시 입력 받음 / 슬레이브: 작업 수행

이 부분 내용은 현재 공식 방법이 변경되어 깃허브 이슈에 남겨두었다 (#1). 

