# Welcome to Chuck Park

## Get started

docker로 터미널 접속
```
docker run --rm \
--volume="$PWD:/srv/jekyll" \
--publish 4000:4000 \
-it jekyll/jekyll /bin/bash
```

## jekyll commands

로컬 서버 실행
```
jekyll serve 
```