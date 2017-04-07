---
layout: entry
title: scala - WordCount
author: 이동훈
author-email: voidtype@gmail.com
description: spark에서 scala를 이용하여 wordcount를 해보는 예제를 정리해보려고 합니다.
publish: true
categories : scala
tags : ['spark','scala']
---


## 들어가며...
사내에 있는 하둡에 로그 데이터가 있는데 이것을 가공해야할 일이 생겼다. 다음과 같은 방법이 떠올랐는데...
1. 파이썬으로 MR 로직을 작성하고 hadoop streaming으로 처리하기
2. pig를 이용해서 처리하기
3. spark을 이용해서 처리하기

1,2번은 예전부터 많이 사용해왔던 방법이라서 다른 방법을 사용해보고 싶은 생각이 들었다. spark이 코드도 간단하고 빠르다는 이야기를 들은 것이 있어서 이번에는 spark으로 해보려고 한다. 그런데 spark도 [pyspark][1]을 통해서 파이썬으로도 개발 가능하다고 한다. 이왕 새로운 방법을 접하기로 한거 언어도 scala로 처음 사용해보고자 한다.

## WordCount
어떤 프로그래밍 언어를 접할 때, 가장 기본이 되는 예제를 "hello world"예제라고 한다면, Map-Reduce 작업에서 가장 기본이 되는 예제가 "word count"일 것이다. 결국 하둡에 있는 로그를 대상으로 작업을 해야할 것이므로, scala로 되어있는 WordCount 예제를 분석해보기로 한다.

예제는 [apache github][2]에도 있는데, WordCount예제는 streaming방식으로만 있어서 [api example page][3]에 있는 내용을 사용한다. 그리고 [익명함수][5]는 reduceByKey 문법을 보는데 참고한다.


```scala
/*
 * SparkConf()는 spark의 환경설정 정보를 담고 있는 객체이다.
 **/
val conf = new SparkConf().setAppName("WordCount Example")

/*
 *sparkContext는 메인 엔트리포인트로서 spark클러스터 관리, RDD생성 등 역할을 수행한다.
 **/
val sc = new SparkContext(conf)

/*
 *hdfs또는 localhost에 있는 파일을 읽어들여서 RDD를 생성한다.
 *RDD[String] 형태로 리턴된다.
 **/
val textFile = sc.textFile("hdfs://...")

/*
 *flatMap은 여러컬럼으로 구성된 형태를 행으로 펼치는 역할을 수행한다.
 *textFile은 String 열 하나를 가지고 있는데, 이것을 문장이라고 하면, 문장을
 *공백으로 분리한다음 이것을 flatMap하게 되면 한 단어가 한행이 되는 형태로 
 *펼쳐지게 된다.
 *
 *여기에 map을 적용하는데, map은 모든 엔트리마다 특정 연산을 적용하는 기능이다.
 *문장을 공백기준으로 단어로 분리한 다음, 각 단어를 한 행으로 만들고, 각 행마다 
 *해당단어와 빈도1을 갖는 튜플로 변환한다.
 *
 *reduceByKey는 (key,value)를 갖는 튜플을 입력받아서 첫번재 엘리먼트를 키로
 *사용한다. 실제 형식은 다음과 같다.
 *reduceByKey( (sum,count) => sum + count )   -->  reduceByKey(_+_)
 *
 *sum과 count는 함수 전체에서 동일한 모양으로 사용하므로 "_"로 대체한다.
 **/
val counts = textFile.flatMap(line => line.split(" "))
                 .map(word => (word, 1))
                 .reduceByKey(_ + _)

/*
 *저장하게 되면 (key, freq) 튜플의 형태로 저장하게 된다. 
 **/
counts.saveAsTextFile("hdfs://...")
```


[1]: http://spark.apache.org/docs/latest/api/python
[2]: https://github.com/apache/spark/tree/branch-1.6/examples
[3]: http://spark.apache.org/examples.html
[4]: https://spark.apache.org/docs/latest/api.html
[5]: http://docs.scala-lang.org/ko/tutorials/tour/anonymous-function-syntax.html

## reference
<http://docs.scala-lang.org/ko/tutorials/scala-for-java-programmers.html>
<https://twitter.github.io/scala_school/ko/basics.html>
<http://yehongj.tistory.com/14>
<http://grokbase.com/t/gg/scala-korea/141add95pc/%EC%8A%A4%EC%B9%BC%EB%9D%BC100-8-tuple>

## 마무리
처음 보는 언어라 많이 생소했는데, 그래도 자꾸 보니까 많이 익숙해졌다.
아직 scala만의 장점은 잘 모르겠지만, 계속 연습해봐야겠다는 생각을 해본다.
