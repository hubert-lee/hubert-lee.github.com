---
layout: entry
title: scala - hello world
author: 이동훈
author-email: voidtype@gmail.com
description: 한번도 접해보지 않았던 스칼라를 시작해보려고 한다. 언제나 그렇듯 "hello world"부터...
publish: false
categories : scala
tags : ['scala']
---


## 들어가며...
사내에 있는 하둡에 로그 데이터가 있는데 이것을 가공해야할 일이 생겼다. 다음과 같은 방법이 떠올랐는데...
1. 파이썬으로 MR 로직을 작성하고 hadoop streaming으로 처리하기
2. pig를 이용해서 처리하기
3. spark을 이용해서 처리하기
1,2번은 예전부터 많이 사용해왔던 방법이라서 다른 방법을 사용해보고 싶은 생각이 들었다. spark이 코드도 간단하고 빠르다는 이야기를 들은 것이 있어서 이번에는 spark으로 해보려고 한다. 그런데 spark도 [pyspark][1]







[1]: http://spark.apache.org/docs/latest/api/python/
