---
title: DGS - Getting Started
# last_modified_at: 2022-07-02T01:08:00-09:00
categories: DGS 한글 문서
layout: archive
tags:
  - DGS
---

# Getting Started

## 새로운 Spring Boot 어플리케이션을 만들어봅시다

DGS 프레임워크는 Spring Boot을 기반으로 합니다, 그래니 아직 진행 중인 프로젝트가 없다면 Spring Boot 어플리케이션을 만들면서 시작해봅시다. Spring Initializr는 이런 경우에 쉽게 시작하는 것을 도와주는 도구입니다. Gradle이나 Maven 중에 하나를 선택하고, Java 8 이상의 최신 버전 또는 Kotlin을 선택하세요. 우리는 아주 멋진 [code generation plugin](https://netflix.github.io/dgs/generating-code-from-schema)을 제공하기 때문에 Gradle을 권장합니다.

유일하게 필요한 하나의 Spring dependency는 Spring Web입니다.

![initializr](assets/initializr.png)

IDE에서 프로젝트를 여세요 (Intellij를 권장합니다)

## DGS Framework Dependency 추가하기
Gradle 또는 Maven configuration에 플랫폼 종속성을 추가하세요. `com.netflix.graphql.dgs:graphql-dgs-platform-dependencies dependency`는 [platform/BOM](https://netflix.github.io/dgs/advanced/platform-bom/)으로, 프레임워크의 개별 모듈 및 전이 종속성(transitive dependencies)의 버전을 정렬합니다. `com.netflix.graphql.dgs:graphql-dgs-spring-boot-starter`는 DGS를 시작하는 데 필요한 모든 것을 포함하는 Spring Boot 스타터입니다. WebFlux를 기반으로 작업하는 경우 `com.netflix.graphql.dgs:graphql-dgs-webflux-starter`를 대신 사용하세요.

Gradle
```gradle
repositories {
    mavenCentral()
}

dependencies {
    implementation(platform("com.netflix.graphql.dgs:graphql-dgs-platform-dependencies:latest.release"))
    implementation "com.netflix.graphql.dgs:graphql-dgs-spring-boot-starter"
}
```

Gradle Kotlin
```kotlin
repositories {
    mavenCentral()
}

dependencies {
    implementation(platform("com.netflix.graphql.dgs:graphql-dgs-platform-dependencies:latest.release"))
    implementation("com.netflix.graphql.dgs:graphql-dgs-spring-boot-starter")
}
```

Maven
```maven
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.netflix.graphql.dgs</groupId>
            <artifactId>graphql-dgs-platform-dependencies</artifactId>
            <!-- The DGS BOM/platform dependency. This is the only place you set version of DGS -->
            <version>4.9.16</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <dependency>
        <groupId>com.netflix.graphql.dgs</groupId>
        <artifactId>graphql-dgs-spring-boot-starter</artifactId>
    </dependency>

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

Important
DGS 프레임워크는 Kotlin 1.5. 버전을 사용합니다. 여러분이 만약 [Spring Boot Gradle Plugin 2.3](https://docs.spring.io/spring-boot/docs/2.3.10.RELEASE/gradle-plugin/reference/html/)를 사용하신다면, 사용하는 Kotlin 버전이 사용 가능한 버전인지 명확하게 확인하시길 바랍니다. 이 플러그인은 전이 의존성인 1.5 버전의 Kotlin을 1.3으로 다운그레이드 시킬겁니다. 아래 처럼 Gradle의 extensions를 통해서 버전을 명시적으로 설정할 수 있습니다.

Gradle
```gradle
ext['kotlin.version'] = '1.4.31'
```
Gradle Kotlin
```kotlin
extra["kotlin.version"] = "1.4.31"
```

## Schema 만들기
DGS 프레임워크는 schema 우선 개발(schema first development)을 위해 설계 되었습니다. 프레임워크는 `src/main/resources/schema` 폴더에서 schema 파일을 찾습니다. `src/main/resources/schema/schema.graphqls`에 schema 파일을 생성하세요.

```graphql
type Query {
    shows(titleFilter: String): [Show]
}

type Show {
    title: String
    releaseYear: Int
}
```
이 schema는 선택적으로 title로 필터링 할 수 있는 show의 리스트를 query 할 수 있게합니다.

## Data Fetcher 구현하기
Data Fetcher는 query에 대한 데이터를 반환할 책임을 가집니다. `example.ShowsDataFetcher`와 `Show`라는 이름의 새로운 클래스를 생성하고 아래의 코드를 추가해주세요.
이 가이드에서는 수동으로 클래스를 생성하고 있지만, 이 작업을 자동으로 해줄 [Codegen plugin](https://netflix.github.io/dgs/generating-code-from-schema)이 있다는 것을 참고하세요.

Java
```java
@DgsComponent
public class ShowsDatafetcher {

    private final List<Show> shows = List.of(
            new Show("Stranger Things", 2016),
            new Show("Ozark", 2017),
            new Show("The Crown", 2016),
            new Show("Dead to Me", 2019),
            new Show("Orange is the New Black", 2013)
    );

    @DgsQuery
    public List<Show> shows(@InputArgument String titleFilter) {
        if(titleFilter == null) {
            return shows;
        }

        return shows.stream().filter(s -> s.getTitle().contains(titleFilter)).collect(Collectors.toList());
    }
}

public class Show {
    private final String title;
    private final Integer releaseYear;

    public Show(String title, Integer releaseYear) {
        this.title = title;
        this.releaseYear = releaseYear;
    }

    public String getTitle() {
        return title;
    }

    public Integer getReleaseYear() {
        return releaseYear;
    }
}
```

Kotlin
```kotlin
@DgsComponent
class ShowsDataFetcher {
    private val shows = listOf(
        Show("Stranger Things", 2016),
        Show("Ozark", 2017),
        Show("The Crown", 2016),
        Show("Dead to Me", 2019),
        Show("Orange is the New Black", 2013))

    @DgsQuery
    fun shows(@InputArgument titleFilter : String?): List<Show> {
        return if(titleFilter != null) {
            shows.filter { it.title.contains(titleFilter) }
        } else {
            shows
        }
    }

    data class Show(val title: String, val releaseYear: Int)
}
```

## GraphiQL로 앱 테스트하기
브라우저를 열고 http://localhost:8080/graphiql로 접속해서 어플리케이션을 시작해봅시다. GraphiQL은 DGS 프레임워크에 함께 포함되어있는 query 편집기 입니다. 아래의 query를 작성하고 결과를 테스트해봅시다.
```graphql endpoint
{
    shows {
        title
        releaseYear
    }
}
```

참고로, REST와는 다르게 query로부터 어떤 field들의 데이터를 받을 것인지 명시해주어야합니다.

GraphiQL 편집기는 그저 여러분의 서비스의 /graphql 앤드포인트를 사용하는  단순한 UI 입니다. 여러분이 원한다면 이제 [React와 Apollo Client](https://www.apollographql.com/docs/react/)와 같은 다른 UI와 여러분의 backend을 연결할 수 있습니다.

## Intellij 플러그인 설치하기
만약 여러분이 Intellij를 사용하신다면, DGS를 위한 플러그인이 있습니다. 이 플러그인은 schema 파일과 코드를 네비게이션 할 수 있도록해주고, 다양한 힌트와 빠른 코드 수정 기능(quick fixes)를 지원합니다. 이 플러그인은 [Jetbrains plugin repository](https://plugins.jetbrains.com/plugin/17852-dgs)에서 설치할 수 있습니다.

## 다음 단계
이제 여러분이 만든 첫번째 GraphQL 서비스가 동작하게 됐습니다. 아래의 내용을 따라하면서 서비스를 더 개선시키길 추천드립니다.

- DGS 프레임워크 dependencies를 정렬하기 위해 [DGS Platform BOM 사용하기](https://netflix.github.io/dgs/advanced/platform-bom/)
- [datafetchers](https://netflix.github.io/dgs/datafetching)에 대해 더 알아보기
- [Gradle CodeGen 플러그인](https://netflix.github.io/dgs/generating-code-from-schema) 사용하기 - data type들을 생성해줍니다.
- JUnit에서 [query 테스트](https://netflix.github.io/dgs/query-execution-testing) 작성하기
- [예제 프로젝트](https://netflix.github.io/dgs/examples) 보기