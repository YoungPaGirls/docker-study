#!/bin/bash

# 1️⃣ MacOS와 Linux에서 호스트 IP 가져오기
if [[ "$OSTYPE" == "darwin"* ]]; then
  HOST_IP=$(ipconfig getifaddr en0)
else
  HOST_IP=$(hostname -I | awk '{print $1}')
fi

# 2️⃣ Swarm 초기화 (이미 활성화되어 있으면 스킵)
if ! docker container exec -it manager docker info | grep -q "Swarm: active"; then
  echo "🛠️ Swarm이 비활성화됨. 초기화 진행..."
  docker container exec -it manager docker swarm init --advertise-addr $HOST_IP
fi

# Swarm이 정상적으로 활성화되었는지 확인
if ! docker container exec -it manager docker info | grep -q "Swarm: active"; then
  echo "❌ Swarm 초기화 실패!"
  exit 1
fi

echo "✅ Swarm이 활성화됨!"

# 3️⃣ 기존에 남아 있는 Worker 정리 (기존에 조인된 Worker가 있으면 삭제)
echo "🛠️ 기존 Worker 정리 중..."
EXISTING_NODES=$(docker container exec -it manager docker node ls --format "{{.Hostname}}")

for node in worker01 worker02 worker03; do
  if echo "$EXISTING_NODES" | grep -q "$node"; then
    echo "🛠️ $node 제거 중..."
    docker container exec -it manager docker node rm --force $node
  fi
done

# 4️⃣ Worker 노드가 이미 Swarm에 남아 있으면 강제 탈퇴
for worker in worker01 worker02 worker03; do
  if docker container exec -it $worker docker info | grep -q "Swarm: active"; then
    echo "🛠️ $worker Swarm 탈퇴 중..."
    docker container exec -it $worker docker swarm leave --force
  fi
done

# 5️⃣ Swarm Join Token 강제 재생성
echo "🔄 Worker Join Token을 다시 생성합니다..."
docker container exec -it manager docker swarm join-token worker --rotate > /dev/null
WORKER_JOIN_TOKEN=$(docker container exec -it manager docker swarm join-token worker -q | tr -d '\r' | tr -d '\n')

if [ -z "$WORKER_JOIN_TOKEN" ]; then
  echo "❌ Worker Join 토큰을 가져올 수 없음!"
  exit 1
fi

echo "🔑 Worker Join Token: $WORKER_JOIN_TOKEN"

# 6️⃣ Worker 노드 자동 Join
for worker in worker01 worker02 worker03; do
  echo "🚀 $worker Swarm에 참여 중..."
  echo "docker container exec -it $worker docker swarm join --token $WORKER_JOIN_TOKEN manager:2377"
  docker container exec -it $worker docker swarm join --token $WORKER_JOIN_TOKEN manager:2377 || echo "❌ $worker Join 실패"
done

echo "✅ 모든 Worker가 Swarm에 참여 완료!"