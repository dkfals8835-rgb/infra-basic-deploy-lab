#!/bin/bash
# deploy.sh — Spring Boot 자동 배포 스크립트
# 사용법: ./deploy.sh [브랜치명]  (기본: main)
set -euo pipefail

# 설정 변수

# 깃허브 레파지토리 루트 경로
REPO_DIR="/home/ubuntu/infra-basic-deploy-lab"

# 앱 루트경로
APP_DIR="/home/ubuntu/infra-basic-deploy-lab/infra-basic-deploy-lab"

# 빌드 결과(아티팩트)
JAR_PATTERN="infra-basic-deploy-lab-*.jar"

# 앱 실행 결과
LOG_FILE="/home/ubuntu/infra-basic-deploy-lab/app.log"

# 배포 과정 결과 로그
DEPLOY_LOG="/home/ubuntu/infra-basic-deploy-lab/deploy.log"

# 인자 없다면 main 브랜치 기준
BRANCH="${1:-main}"
PORT=8080
HEALTH_URL="http://localhost:${PORT}/api/backend"

# 헬스체크 최대 대기(초)
MAX_WAIT=30

# 로그 함수
log() {
    local MSG="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$MSG" | tee -a "$DEPLOY_LOG"
}

# 1) Git Pull
pull_latest() {
    log "=== 배포 시작: branch=$BRANCH ==="

    # [힌트] git clone된 루트 폴더로 이동
    cd "$REPO_DIR" 
    # [힌트] git fetch origin
    git fetch origin
    # [힌트] $BRANCH 로 checkout
    git checkout "$BRANCH"
    # [힌트] $BRANCH 를 pull
    git pull origin "$BRANCH"
    # ?

    log "Git pull 완료"
}

# 2) Maven 빌드
build_jar() {
    log "Maven 빌드 시작..."

    # [힌트] $APP_DIR 로 이동 (pom.xml 위치)
    cd "$APP_DIR"
    # [힌트] Step 2에서 서버 빌드할 때 쓴 명령어 사용 (테스트 스킵, -q 옵션 추가)
    # ?
    mvn clean package -DskipTests -q

    log "빌드 완료: $(ls target/$JAR_PATTERN)"
}

# 3) 기존 프로세스 종료
stop_app() {
    local PID
    PID=$(pgrep -f "$JAR_PATTERN" || true)

    # [힌트] $PID 가 비어있지 않으면 (-n) 종료 처리
    #         kill 후 최대 10초 대기하며 프로세스가 사라졌는지 확인
    #         비어있으면 "실행 중인 프로세스 없음" 로그 출력
    # ?
    if [ -n "$PID" ]; then
        log "기존 프로세스 종료 : PID=$PID"
        kill "$PID" 
        # 10초 대기하며 프로세스가 실제 종료되었는지 확인하는 루프 
        for i in {1..10}; do
            if  ! pgrep -f "$JAR_PATTERN" > /dev/null; then
                log "프로세스 종료 확인"
                break;
            fi 
        done
    else 
        echo "실행 중인 프로세스 없음"
    fi
}

# 4) 앱 시작
start_app() {
    local JAR
    JAR=$(ls "$APP_DIR"/target/$JAR_PATTERN | head -1)

    log "앱 시작 : $JAR"
    # [힌트] $APP_DIR 로 이동
    cd "$APP_DIR" || { log "폴더 이동 실패: $APP_DIR"; exit 1; }
    # [힌트] nohup 으로 $JAR 백그라운드 실행
    #         stdout/stderr 는 $LOG_FILE 로 저장
    # ?
    nohup java -jar "$JAR" > "$LOG_FILE" 2>&1 &
    log "PID: $!"
}

# 5) 헬스 체크
health_check() {
    log "헬스 체크 대기 중 (최대 ${MAX_WAIT}초)..."

    # [힌트] 1초 간격으로 $MAX_WAIT 회 반복
    #         curl -sf 로 $HEALTH_URL 에 요청
    #         성공하면 "배포 성공" 로그 출력 후 return 0
    #         반복이 끝날 때까지 응답 없으면 아래 return 1 실행
    # ?
    for i in $(seq 1 $MAX_WAIT); do
        if curl -sf "$HEALTH_URL" > /dev/null 2>&1; then
            log "배포 성공: ${HEALTH_URL} 응답 확인 (${i}초 소요)"
            return 0
        fi
        sleep 1
    done

    log "배포 실패: ${MAX_WAIT}초 내 응답 없음"
    return 1
}

# 메인 실행
pull_latest
build_jar
stop_app
start_app
health_check

log "=== 전체 배포 완료 ==="
