# 03. 컨테이너 실전 구축 및 배포

> 시스템에서 단일 컨테이너의 비중, 이식성을 고려해 도커 친화적인 애플리케이션을 개발하는 방법, 퍼시스턴스 데이터를 다루는 방법, 도커 스웜이나 스택을 이용한 컨테이너 배포 전략에 대해 알아보자.

## 1. 애플리케이션과 시스템 내 단일 컨테이너의 적정 비중

> 도커를 이용한 시스템 구성 = 컨테이너가 서로 협력하는 스택을 구축하는 것  
> 단일 컨테이너의 시스템 내 비중은 어떻게 결정해야 하는가.

### 컨테이너 1개에 대한 프로세스

1. 컨테이너 = 프로세스 1개 일 때

- cron 을 사용하고 싶다면? -> cron 용 컨테이너 1개, 작업용 컨테이너 1개가 필요함
- 컨테이너간 API 호출하는 방식은 복잡함 -> 컨테이너 하나로 cron과 작업 프로세스를 모두 실행하는 방법을 시도하자.

2. 컨테이너 1개에 프로세스 2개 사용하기  
   아래와 같이 파일을 생성하고 도커 이미지를 빌드 및 실행해보자.

```shell
cronjob --- task.sh 
  |- cron-example
  |- Dockerfile
```

```shell
docker image build -t example/cronjob:latest . 
```

```shell
docker container run -d --rm --name cronjob example/cronjob:latest
```

- 실행 중인 컨테이너 `/var/log/cron.log` 에 문자열 추가 중

```shell
docker container exec -it cronjob tail -f /var/log/cron.log
```

3. 요약

- 컨테이너에 1개 이상의 프로세스를 실행하는 것을 허용하는 게 간결하게 형태를 유지할 수 있는 경우가 많다.
- 프로세스를 지나치게 의식하지 말자. 용도에 맞게 프로세스를 사용하면 된다.

### 컨테이너 1개 - 관심사 1개

> 컨테이너는 하나의 관심사에만 집중해야 한다(Each container should have only one concern).  
> -- 도커 공식 문서(Best Practices for writing Dockerfiles) 인용

컨테이너 하나가 한 가지 역할이나 문제에 집중해야 한다는 의미이다.

### 결론

> 애플리케이션과 컨테이너가 전체 시스템에서 차지해야 하는 적정 비중을 고려하면 '각 컨테이너가 맡을 역할을 적절히 나누고, 그 역할에 따라 배치한 컨테이너를 복제해도 전체 구조에 부작용이 일어나지 않는가?' 를
> 따지며 시스템 설게를 해야한다.

## 2. 컨테이너의 이식성

> 이식성(protability)는 도커의 큰 이점이다.  
> 하지만 도커의 이식성은 완벽하지 않다. 일부 예외가 존재한다.

### 커널 및 아키텍처의 차이

- 도커의 컨테이너형 가상화 기술은 호스트 OS와 커널 리소스 공유 -> 호스트가 특정 CPU 아키텍처 (or OS) 사용하는 것이 필수적
- 공식 이미지를 x86_64 아키텍처에서 실행하는 것을 전제로 만듦 -> 다른 아키텍처에서 동일한 실행이 보장 X

### 라이브러리와 동적 링크 문제

- 애플리케이션이 어떤 라이브러리르 사용하느냐에 따라 이식성을 해칠 수 있음
- 대표적인 예가 네이티브 라이브러리를 동적 링크해 사용하는 경우임 -> 실행할 때 라이브러리가 링크 -> 호스트에서 라이브러리를 갖춰야 함
- Dockerfile ADD, COPY 인스트럭션을 이용한 복사 / CI를 사용한 이미지 패키징 등을 고려해볼 수 있다.
    - 문제점: CI와 컨테이너 내부 라이브러리 버전이 다르면 동작 안할 것.

### 결론

> - 도커 컨테이너에서 실행할 애플리케이션을 개발할 때는 되도록 네이티브 라이브러리를 정적 링크해 빌드하자.
> - 도커에서 제시한 해결책(multi-stage builds): 빌드용/실행용 컨테이너 분리하여 사용

## 3. 도커 친화적인 애플리케이션

### 환경 변수 활용

> 이식성을 중시하는 도커 환경에서는 외부에서 동작을 제어할 수 있게 해야 한다.

- 도커 컨테이너에서 실행되는 애플리케이션 제어 방법들
    - 실행 시 인자 사용(CMD/ENTRYPOINT): (장점) 외부에서 값 주입 / (단점) 인자가 많아지면 복잡해지고 관리 어려움
    - 설정 파일(환경에 따라 설정 파일 변경): 루비, java 등 - 설정 변경 시 설정 파일 추가해서 새로 빌드 해야 함
    - 애플리케이션 동작을 환경 변수로 제어(docker-compose.yml 의 env 속성에 정의): (장점) 매번 이미지 빌드 X / (단점) 계층 구조 어려움 - 애플리케이션 매핑 처리 많이해야 함
    - 설정 파일에 환경 변수 포함 (추천)
        ```shell
        db.driverClass=${DB_DRIVER_CLASS:com.mysql.jdbc.Driver}
        db.jdbcUrl=${DB_JDBC_URL}
        db.user=$(DB_USER}
        db.password=${DB_PASSWORD} 
        db.initialSize=${DB_INITIAL_SIZE:10} 
        db.maxActive=${DB_MAX_ACTIVE:50}
        ```

## 4. 퍼시스턴스 데이터를 다루는 방법

> 도커 실행 중 생성되거나 수정된 파일은 컨테이너랑 같이 소멸됨.  
> 새로운 버전 컨테이너가 파일과 디렉터리를 그대로 가져가고 싶다면? -> 데이터 볼륨(data volume) 을 이용하자.

1) 컨테이너 - 호스트 공유 형태
2) 데이터 볼륨 컨테이너 (퍼시스턴스 데이터를 위한 컨테이너)

### 데이터 볼륨

> 도커 컨테이너 안의 디렉터리를 디스크에 퍼시스턴스 데이터로 남기기 위한 메커니즘  
> 호스트-컨테이너 사이 디렉터리 공유 및 재사용 기능 제공

1. 데이터 볼륨 생성 방법 (-v 옵션)

```shell
docker container run [options] -v 호스트_디렉터리:컨테이너_디렉터리 리포지토리명[:태그] [명령] [명령인자]
```

2. 컨테이너에서 생성된 파일을 호스트에서 참조하는 경우

- 실습: 컨테이너안의 /workspace 디렉터리는 환경변수 ${PWD}가 나타내는 디렉터리(현재 작업 디렉터리)에 마운트

```shell
docker container run -v ${PWD}:/workspace gihyodocker/imagemagick:latest convert -size 100x100 xc:#000000 /workspace/gihyo.jpg
```

3. 정리

- (장점) 컨테이너 안의 설정 파일 쉽게 수정 가능
- (단점) 호스트 안의 특정 경로에 의존성 생김 - 호스트 쪽에서 잘못 다루면 애플리케이션에 영향

### 데이터 볼륨 컨테이너

> 데이터 볼륨 컨테이너: 디스크에 저장된 컨테이너가 갖는 퍼시스턴스 데이터를 볼륨으로 만들어 다른 컨테이너에 공유하는 컨테이너  
> 데이터 볼륨 컨테이너는 데이터 퍼시스턴스 기법으로 추천된다.   
> 컨테이너간 디렉터리를 공유함.

1. 특징

- 동일하게 호스트 머신 스토리지에 저장.
- 데이터 볼륨 컨테이너의 볼륨은 도커에서 관리하는 영역에 위치 (호스트 머신의 `/var/lib/docer/volumes/`)
- 도커가 관리하는 디렉터리 영역에만 영향을 미치기 때문에, 호스트 머신이 컨테이너에 미치는 영향을 최소화함
- 디렉터리를 제공하는 데이터 볼륨 컨테이너만 지정하면 됨
- 데이터 볼륨이 데이터 볼륨 컨테이너 안에 캡슐화 됨 -> 호스트 정보 몰라도 데이터 볼륨 사용 O
- 애플리케이션과 데이터의 결합 느슨함 -> 교체 용이

2. 데이터 볼륨에 MySQL 데이터 저장

- cf) busybox: 경량 운영 체제
- 데이터 볼륨 컨테이너는 작은 이미지를 사용하는 것이 효과적

```shell
docker image build -t example/mysql-data:latest .
```

- 아래 컨테이너는 데이터 볼륨 컨테이너로 실행됨 CMD 인스트럭션에서 셸 실행 후 컨테이너 종료됨

```shell
docker container run -d --name mysql-data example/mysql-data:latest
```

- mysql 동작 컨테이너 실행

```shell
docker run -d --rm --name mysql \
  -e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" \
  -e "MYSQL_DATABASE=volume_test" \
  -e "MYSQL_USER=example" \
  -e "MYSQL_PASSWORD=example" \
  --volumes-from mysql-data \
  mysql:8 # 5.7 버전은 arm64 지원 안함  
```

```shell
docker container exec -it mysql mysql -u root -p volume_test
```

- 테스트용 쿼리

```sql
CREATE TABLE user
(
    id   int primary key auto_increment,
    name varchar(255)
) ENGINE=InnoDB default charset utf8mb4 collate utf8mb4_unicode_ci;

INSERT INTO user (name)
VALUES ('gihyo'),
       ('docker'),
       ('Solomon Hykes');
```

- mysql 컨테이너 정지 후 데이터 확인

```shell
docker container stop mysql 
```

```shell
docker run -d --rm --name mysql \
  -e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" \
  -e "MYSQL_DATABASE=volume_test" \
  -e "MYSQL_USER=example" \
  -e "MYSQL_PASSWORD=example" \
  --volumes-from mysql-data \
  mysql:8

docker container exec -it mysql mysql -u root -p volume_test
```

```SQL
SELECT *
FROM user;
```

### 데이터 익스포트 및 복원

> 데이터 익스포트 후 호스트로 꺼내기

```shell
docker container run -v ${PWD}:/tmp \
  --volumes-from mysql-data \
  busybox \
  tar cvzf /tmp/mysql-backup.tar.gz /var/lib/mysql
```

## 5. 컨테이너 배치 전략

> 많은 트래픽을 처리할 수 있는 실용적인 시스템 -> 대부분 여러 컨테이너가 각기 다른 호스트에 배치  
> 컨테이너 배치 방법, 다수의 도커 호스트를 다룰 때는 다양한 사항을 고려해야함.

### 도커 스웜(Docker Swarm)

> 여러 도커 호스트를 클러스터로 묶어주는 컨테이너 오케스트레이션 도구의 종류.  
> 오케스트레이션 도구를 도입하면 컨테이너간 조율이 용이하고 클러스터를 투명하게 다룰 수 있다는 이점이 있음

| 이름  | 역할                                  |     대응 명령어     | 
|:---:|:------------------------------------|:--------------:|
| 컴포즈 | 여러 컨테이너로 구성된 도커 애플리케이션을 관리 (단일 호스트) | docker-compose |
| 스웜  | 클러스터 구축 및 관리 (멀티 호스트)               |  docker swarm  |
| 서비스 | 스웜에서 클러스터 안의 서비스(컨테이너 집합)를 관리       | docker service |
| 스택  | 스웜에서 여러 개의 서비스를 합한 전체 애플리케이션을 관리    |  docker stack  |


**1. 여러 대의 도커 호스트로 스웜 클러스터 구성하기**  
  - 클라우드 서비스, 도커 머신즈(Docker Machines), 가상화 소프트웨어 를 이용하여 여러 대의 도커 호스트를 이용할 수 있지만 번거롭거나 일부 문제가 있다.
  - 도커 인  도커(Docker in Docker, dind)라는 기능을 사용하면 도커 컨테이너 안에서 도커 호스트를 실행할 수 있다.  


- dind를 사용해 도커 스웜 클러스터를 구축해보자.
  - 컨테이너 5개를 이용하자(registry, manager, worker 3개)
  - registry: 도커 레지스트리 역할 컨테이너
    - manager, worker 컨테이너가 사용 
    - dind 환경에서는 외부 도커 데몬에서 빌드된 도커 이미지 사용 불가 -> registry 컨테이너에 이미지를 저장하고 manager, worker 컨테이너가 사용  
    - 실무에서는 도커 허브 or 사전 구축한 인하우스 레지스트리 사용
    - registry 컨테이너 데이터는 퍼시스턴시를 위해 호스트에 마운트  
  - manager: 스웜 클러스터 전체 제어 역할. worker 에 서비스가 담긴 컨테이너를 적절히 배치  

- docker-compose.yml 작성 
  - 모든 manager, worker 컨테이너는 registry 컨테이너 의존 
  - 레지스트리에는 일반적으로 https 를 통해 접근  
    - http 사용 시 불가 (command 요소에 `--insecure-registry registry:5000`값을 줘 http로 이미지 내려받을 수 있게 함)

- 실행 (여러 컨테이너를 실행한 상태. 아직 클러스터 X)
```shell
docker-compose up -d
docker container ls
```

- 호스트에서 manager 역할 부여 (docker swarm init)
  - manager 마킹 및 스웜 모드 활성화 
  - join 토큰 생성되어 터미널에 출력됨 -> worker 등록 시 필요  
```shell
docker container exec -it manager docker swarm init 
```

- 스웜 클러스터에 worker 등록하기
```shell
#전체 노드에 다 수행해야 함 
docker container exec -it worker01 docker swarm join \
--token SWMTKN-1-24vlkrplm8yz0q3g4x8pxxwh1y3jy1p0zp72ubrelg30o2mldd-12th71n9m95m88p3c7xiyr91y manager:2377
```
```shell
docker container exec -it manager docker node ls
```

**2. 도커 레지스트리에 이미지 등록하기** 
> 외부 도커에서 빌드한 이미지는 레지스트리를 통해서만 안쪽 도커에서 사용 가능  

- 이미지를 레지스트리에 등록하기 
  - 태그 포맷 `[레지스트리_호스트/]리포지토리명[:태그]`
```shell
docker image tag example/echo:latest localhost:5001/example/echo:latest
```
```shell
# docker image push [레지스트리_호스트/]리포지토리명[:태그]
docker image push localhost:5001/example/echo:latest 
```
- worker 컨테이너가 registry 컨테이너에서 도커 이미지를 받을 수 있는지 테스트
```shell
#docker image pull [레지스트리_호스트/]리포지토리명[:태그]
docker container exec -it worker01 docker image pull registry:5000/example/echo:latest
```
```shell
docker container exec -it worker01 docker image ls
```

### 서비스 
> 서비스: 애플리케이션을 구성하는 일부 컨테이너를 제어하기 위한 단위

- 서비스 생성
```shell
docker container exec -it manager \
docker service create --replicas 1 --publish 8000:8080 --name echo registry:5000/example/echo:latest
```
```shell
docker container exec -it manager docker service ls 
```

- 서비스가 제어하는 레플리카 늘리기 (docker service scale)
```shell
docker container exec -it manager docker service scale echo=6
```
```shell
docker container exec -it manager docker service ps echo | grep Running
```
- 서비스 삭제하기 
```shell
docker container exec -it manager docker service rm echo
```

### 스택 
> 하나 이상의 서비스를 묶은 단위. 애플리케이션 전체 구성 정의  

- 스택을 사용하면 여러 서비슬르 함께 다룰 수 있다.  
- 스택이 다루는 애플리케이션의 규모는 컴포즈와 같음. -> 스웜에서 동작하는 스케일 인, 스케일 아웃, 제약 조건 부여 가능한 컴포즈  
- docker stack 하위 명령으로 조작  
- 스택을 사용해 배포된 서비스 그룹은 overlay 네트워크에 속함  
  - overlay 네트워크: 여러 도커 호스트에 걸쳐 배포된 컨테이너 그룹을 같은 네트워크에 배치하기 위한 기술  
  - 클라이언트와 대상 서비스가 같은 overlay 네트워크에 있어야 함  
- manager 컨테이너에서 조작 

1. 네트워크 구성  
```shell
docker container exec -it manager docker network create --driver=overlay --attachable ch03  
```

2. docker stack 하위 명령어
- deploy: 스택을 새로 배포 또는 업데이트
- ls: 배포된 스택 목록 출력 
- ps: 스택에 의해 배포된 컨테이너 목록 출력
- rm: 삭제
- services: 스택에 포함된 서비스 목록 출력  

3. 스택 배포하기
```shell
# docker stack deploy [options] 스택명 -c 스택_정의파일_경로
docker container exec -it manager docker stack deploy -c /stack/ch03-webapi.yml echo
```

4. 배포된 스택 확인
```shell
# docker stack services [options] 스택명 
docker container exec -it manager docker stack services echo 
```

5. 스택에 배포된 컨테이너 확인하기  
```shell
# docker stack ps [options] 스택명 
docker container exec -it manager docker stack ps echo 
```

6. visualizer 를 사용해 컨테이너 배치 시각화
- dockersamples/visualizer 이미지 이용하면 됨  
```shell
docker container exec -it manager docker stack deploy -c /stack/visualizer.yml visualizer 
```

7. 스택 삭제하기 
```shell
# docker stack rm [options] 스택명 
docker container exec -it manager docker stack rm echo 
```

### 스웜 클러스터 외부에서 서비스 사용하기  
> 서비스 클러스터 외부에서 오는 트래픽을 목적하는 서비스로 보내주는 프록시 서버 이용하기.  
> HAProxy  를 이용해 스웜 클러스터 외부에서 echo_nginx 서비스에 접근할 수 있게 해보자.  

- 배포  
```shell
docker container exec -it manager docker stack deploy -c /stack/ch03-webapi.yml echo
docker container exec -it manager docker stack deploy -c /stack/ch03-ingress.yml ingress
```

- 서비스 배치 현황 확인   
```shell
docker container exec -it manager docker service ls 
```

### 정리 
- 서비스는 레플리카 수를 조절해 컨테이너를 쉽게 복제할 수 있다. 그리고 여러 노드에 레플리카를 배치할 수 있기 때문에 스케일 아웃에 유리하다.  
- 서비스로 고간리되는 레플리카는 서비스명으로 네임 레졸루션되므로 서비스에 대한 트래픽이 각 레플리카로 분산된다.  
- 스웜 클러스터 외부에서 스웜에 배포된 서비스를 이용하려면 서비스에 트래픽을 분산시키기 위한 프록시를 갖춰야 한다.   
- 스택은 하나 이상의 서비스를 그룹으로 묶을 수 있으며, 여러 서비스로 구성된 애플리케이션을 배포할 때 유용하다.  



