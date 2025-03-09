FROM ubuntu:16.04

RUN apt update
RUN apt install -y cron

COPY task.sh /usr/local/bin/
COPY cron-example /etc/cron.d/
RUN chmod 0644 /etc/cron.d/cron-example
RUN echo >> /etc/cron.d/cron-example  # 빈 줄 추가 (EOF 오류 방지)

# 미리 로그 파일 생성하고 권한 설정하기
# RUN touch /var/log/cron.log && chmod 666 /var/log/cron.log

CMD ["cron", "-f"]

# 한번에 도커 정지, 삭제, 실행까지
# docker stop cronjob && docker rm cronjob && docker build -t cronjob .  && docker run -d --name cronjob cronjob    