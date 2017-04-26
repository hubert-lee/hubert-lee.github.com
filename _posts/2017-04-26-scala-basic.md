---
layout: entry
title: scala - Basic
author: 이동훈
author-email: voidtype@gmail.com
description: spark+scala 조합으로 기본적인 데이터 다루는 방법에 대해서 정리합니다.
publish: true
categories : scala
tags : ['spark','scala']
---


## 들어가며...
어떤 시스템에서 남기는 로그가 있고, 그 형식은 보통 탭을 구분자로 해서 문자열로 남겨 놓습니다. 이런 형식의 로그를 분석하는 방법에 대해서 정리합니다. spark+scala를 이용하여 분석하는 방법을 설명할 것이고, 동작 가능한 전체 코드는 아니지만, 스칼라를 공부하면서 사용했던 주요 코드만 적습니다.

## 입력데이터 형식
검색시스템을 예로 들자면, 다음과 같이 사용자로 받은 입력쿼리와, 이 쿼리에 대한 부가정보를 로그로 남길 수 있습니다. 가장 간단하게 3개의 필드로 구성된 데이터를 분석한다고 가정하고 설명할 것입니다.
```
query   disp_code extra_info
```


## "query"필드만 추출해서 카운트 하기
``` scala
/*
 ./log.txt 파일을 읽어서 String으로 구성된 RDD를 리턴합니다.
 */
val inputRDD: RDD[String]  = sc.textFile("./log.txt")

/*
 최종 수행이 완료된 RDD는 String과 Int로 구성된 Tuple입니다.
 */
val outRDD: RDD[(String, Int)] = inputRDD
                // 입력 문자열을 탭을 기준으로 분리합니다. 
                .map(_.split("\t"))
                // split()의결과는 Array[String]이므로, (0)번째 query와 1을 Tuple로 만듭니다.
                .map(x => Tuple2(x(0),1))
                // query필드를 기준으로, wordcount를 계산합니다.
                .reduceByKey(_ + _)
                // 두번째 필드인 빈도수를 기준으로 내림차순(false)정렬 합니다.
                .sortBy(_._2, false)
/*
 최종 파일은 log.txt.out으로 저장되고,
 파일내용은 (쿼리,100) 과 같은 내용이 됩니다.
 */
outRDD.saveAsTextFile("./log.txt.out")
```


## 두개의 파일을 읽어서 조인하기
동일한 쿼리에 대해서, 노출로그에는 유입된 정보가, 클릭로그에는 유입된 이후, 유저의 클릭이 발생한 경우 정보가 저장됩니다. 동일한 쿼리를 기준으로 노출(유입)카운트와 클릭카운트를 서로 조인해서 구해보는 방법을 정리합니다. 조인은 여러가지 방법이 있지만 여기서 사용한 방법은 Left join을 사용합니다.


``` scala
/*
disp_log.txt : "(query, disp_cnt)"
clk_log.txt : "(query, clk_cnt)"
output : query, disp_cnt, clk_cnt
*/


val dispRDD: RDD[(String,Int)] = sc.textFile("disp_log.txt")
                .map(_.replaceAll("[()]","")
                .map(_.split(","))
                .map(x => Tuple2(x(0),x(1).toInt))
                

val clkRDD: RDD[(String,Int)] = sc.textFile("clk_log.txt")
                .map(_.replaceAll("[()]","")
                .map(_.split(","))
                .map(x => Tuple2(x(0),x(1).toInt))

val outRDD: RDD[String] = dispRDD.join(clkRDD)
                // join후 RDD type은 [(String,(Int,Int))]가 된다.
                // 이것을 풀어서 탭구분자를 갖는 스트링으로 변경한다.
                .map(_.1+"\t"+_.2_._1+"\t"+_.2._2)

```

## 마무리...
많이는 안써봤지만, 조금 사용하다보니 어느정도 패턴이 생기게 되고, 곧 익숙해졌습니다. 이런 로그데이터를 분석 할때는 보통 projection(원하는 필드만 타겟팅)후, counting이나 gorupby, join과 같이원하는 오퍼레이션을 수행합니다. 그리고 수행후 결과에 filtering을 해서 원하는 데이터만 추출하고, 출력결과물을 생성하는 것입니다.

projection은 보통 문자열을 ``split``하고 나서 원하는 필드만 골라서 튜플이나, 리스트로 만들어서 사용하게 됩니다.

1) split 이후 튜플로 만들기
```scala
    inputRDD.map(split("\t")).map(x => Tuple2(x(0),x(1))
```
2) split 이후 리스트로 만들기
```scala
    inputRDD.map(split("\t")).map(x => x(0) :: x(1) :: List())
            .map(_.mkString(","))
```
``reduceByKey``나 ``groupByKey``와 같은 연산을 사용해야 하는 경우 tuple2로 변환해서 사용하면 편리하고, 리스트로 변경하는 경우에는 ``mkString``함수를 사용해서 간단히 원하는 포맷으로 변경해서 출력할 수 있습니다. 위의 2)예제에서는 탭으로 구분된 데이터를 다시 콤마로 구분된 포맷으로 변경하게 됩니다.


## 문제해결
이런 분석을 하다보면, 처음에는 로컬에서 작은 셋으로 개발해서 로직을 점검한 다음, 큰 용량의 데이터로 확대하는 형식으로 개발합니다. 보면, 작은 데이터셋에서는 잘 돌던 코드가 큰 용량의 입력을 주게 되면 수행이 잘 안되는 경우가 많은데요.

이런 문제는 보통 메모리문제인 경우가 대부분입니다. MR-job에서는 mapper가 사용할 수 있는 최대 메모리가 JVM에 의해서 결정되는데 이 것을 넘어가버리면 문제가 발생하는 것이지요.

spark의 경우에는 ``spark-submit``명령어로 수행을 시작하는데요, 다음과 같은 옵션으로 executor가 사용할 수 있는 최대 메모리를 할당해줄 수 있습니다.
```
function extracting()
{
    input=$1
    output=$2
    package="빌드된 jar 패키지 이름"

    dp-hadoop fs -test -d ${output} && dp-hadoop fs -rm -r -skipTrash ${output} \
                                    || echo "create output directory."
    ${SPARK_HOME}/bin/spark-submit  \
        --master yarn-client  \    # hadoop mode로 실행
        --num-executors 100 \      # 최대 executors 개수 설정
        --executor-memory 8G \     # executor가 사용할 수 있는 메모리 설정
         "target/scala-2.10/${package}" \
         ${input} \
         ${output}
}
```




