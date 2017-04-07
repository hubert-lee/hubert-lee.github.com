---
layout: entry
title: scala - WordCount
author: 이동훈
author-email: voidtype@gmail.com
description: spark에서 scala를 이용하여 wordcount를 해보는 예제를 정리해보려고 합니다.
publish: false
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

예제는 [apache github][2]에 있는 예제를 사용한다.

```scala

```


[1]: http://spark.apache.org/docs/latest/api/python
[2]: https://github.com/apache/spark/tree/branch-1.6/examples
