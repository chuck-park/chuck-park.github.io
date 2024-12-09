---
title: Maria DB의 JSON Data Type
categories: dev
tags:
  - Database
  - MariaDB
  - MySQL
---
> MariaDB에서 JSON type은 사실 LONGTEXT 이다.

### Introduction

MariaDB는 MySQL이 Oracle에 인수된 이후에 라이센스 문제로 인해 fork하여 출발한 오픈소스 RDBMS인데 버전이 올라감에 따라 점점 차이가 커지고 있다. 오늘은 큰 차이점 중에 하나인 JSON type에 대해서 알아보자.

### 정의

MariaDB에서 JSON data type은 LONGTEXT COLLATE utf8mb4_bin의 별명(alias)이다.

MySQL은 JSON document를 바이너리 객체로 저장하지만 MariaDB는 문자열로 저장한다.

MariaDB에 JSON data type은 10.2 이후 버전부터 지원되며 MySQL에서 MariaDB로 statement based replication을 할 때 MySQL의 JSON 컬럼도 가능하게하고, MariaDB가 MySQL의 mysqldumps를 읽을 수 있게 하는 등 MySQL의 JSON data type에 대응하기 위해 추가됐다.

### JSON function

MySQL과 MariaDB 모두 JSON 데이터의 검색 및 저장을 지원한다.

MariaDB는 JSON alias type에 대해 [JSON 관련 함수](https://mariadb.com/kb/en/json-functions/)를 사용할 수 있음(인덱싱은 안됨).

MariaDB 10.4.3 이후부터는 valid한 json인지 확인하기 위해 사용하는 JSON_VALID 함수가 CHECK constraint에 default로 적용되어있음.

### Replicating JSON Data Between MySQL and MariaDB

MySQL의 JSON type은 JSON object이고 MariaDB에서는 LONGTEXT이기 때문에 JSON type에 대해서 MySQL에서 MariaDB로의 row based replication이 불가능하다.

### MySQL과 MariaDB에서 JSON string의 차이

MySQL에서의 JSON data type은 json 값에 대응되는 object 인데 MariaDB에서는 JSON_EXTRACT()를 할 때를 제외하고는 일반적인 string이다.

### References

- [JSON Data Type - MariaDB](https://mariadb.com/kb/en/json-data-type/)
- [MariaDB와 MySQL의 차이점은 무엇인가요? - AWS](https://aws.amazon.com/ko/compare/the-difference-between-mariadb-vs-mysql/)