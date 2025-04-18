## 도커 볼륨(Docker Volume)  
> 도커 컨테이너에서 데이터를 영속적으로 저장하기 위한 방법

컨테이너로 띄우는 프로그램에 변경사항이 생기면 docker는 새로운 컨테이너로 갈아끼운다.  
-> 효율적이지만 컨테이너 내 데이터도 삭제되는 문제 발생  
-> 이 때 사용할 수 있는 것이 볼륨이다.  

```
$ docker run -v [호스트의 디렉토리 절대경로]:[컨테이너의 디렉토리 절대경로] [이미지명]:[태그명]
```

- 호스트 디렉토리 존재 O -> 컨테이너에 복사  
- 호스트 디렉토리 존재 X -> 호스트에 디렉토리 생성하고 컨테이너 데이터 복사


### 실습   
```
$ docker run -e MYSQL_ROOT_PASSWORD=password123 -p 3306:3306 -d mysql
```
- run 명령어 사용하면 이미지 pull 과정 생략 가능
- `-e` 옵션은 컨테이너 환경 변수 설정 옵션
- 이미지를 사용할 때 도커허브에서 공식문서 꼭 참고하기 (필수로 해줘야하는 작업들 명시되어 있음)


## Dockerfile  
> Docker 이미지를 만들게 해주는 파일

### FROM  
- 베이스 이미지를 생성하는 역할(초기 이미지)
```
FROM [이미지명]
FROM [이미지명]:[태그명]
```

- 종료된 컨테이너에서 디버깅하고 싶을 때 아래 명령어 추가해서 꼼수로 볼 수 있음  
```
ENTRYPOINT ["/bin/bash", "-c", "sleep 500"]
```

### COPY 
> 호스트 컴퓨터에 있는 파일을 복사해서 컨테이너로 전달

```
COPY [호스트 컴퓨터에 있는 복사할 파일의 경로] [컨테이너에서 파일이 위치할 경로]
```

- dockerignore : `.dockerignore` 로 생성해서 gitignore 처럼 사용  

### ENTRYPOINT
> 컨테이너가 시작할 때 실행되는 명령어

```
ENTRYPOINT ["명령문1", "명령문2"]
```


### RUN 
```
RUN [명령문]
```

- run vs entrypoint
- 이미지 생성 과정에서 명령 실행(run), 컨테이너 생성 직후 실행(entrypoint) 차이


### WORKDIR 
> 작업 디렉토리를 지정  

사용 안해도 되는데, 파일 정리 목적으로 사용함  
```
WORKDIR [작업 디렉토리로 사용할 절대 경로]
```

### EXPOSE 
> dockerfile 내에서 문서화가 필요할 때 사용 (선택적임). 보통 포트 명시함   


 
