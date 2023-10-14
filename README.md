# Welcome to Chuck Park

## Get started

블로그용 jekyll docker 실행
```
docker run --rm \
--volume="$PWD:/srv/jekyll" \
--publish 4000:4000 \
jekyll/jekyll jekyll serve
```

터미널 접속
```
docker run --rm \
--volume="$PWD:/srv/jekyll" \
--publish 4000:4000 \
-it jekyll/jekyll /bin/bash
```