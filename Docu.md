# 对象说明
---
## 全局
对象的name全部首字母大写
对象的event全部首字母大写
对象的property驼峰式
对象的method全部小写


## 图形化说明
大地图 figure number 100
人的形状 *
车的形状 square

## Timer
系统时钟
- 允许多个时钟同时运行（以不同速度），事件会响应每一个时钟。
- **需要增加** 如果考虑夜晚等问题，那么从timer处发出信号（winter is comming之类的）


## Passenger
- 状态 (invalid %包括没有产生的，放弃的，结束的% , waiting, traveling)
- coor
- timeWait
- cost
- satisfaction



- 在放弃的时候 notify (TripGiveUp) -- 转变成invalid
- 在旅程结束的时候 notify (TripComplete) -- 转变成invalid

### method
- calcsatisfaction



## Driver
- 状态 (fetching, traveling, valid, invalid)
- coor
- salary
- satisfaction
- timeWaste
- mileWaste

## Region
- 路是0 人出现的地方是1 不可逾越不可刷新障碍为2
