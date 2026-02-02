# LC15 锁争夺与死锁实验

## 文件说明

本实验包含以下SQL文件：

### 实验1：锁争夺演示

1. **connection1_lock_contention.sql** - 连接1
   - 功能：更新事务（不提交），保持锁定状态
   - 执行：在第一个SQL Server连接中执行
   - 注意：执行后不要提交或回滚事务，保持锁定状态

2. **connection2_lock_contention.sql** - 连接2
   - 功能：查询事务（被阻塞），然后使用lock_timeout解决阻塞
   - 执行：在第二个SQL Server连接中执行
   - 步骤：
     - 先执行步骤1，观察阻塞现象
     - 取消查询后，执行步骤2，使用lock_timeout

3. **check_blocking.sql** - 查看阻塞情况
   - 功能：使用 sp_who 查看进程阻塞情况
   - 执行：在任意连接中执行，可在实验过程中随时执行

### 实验2：死锁演示

4. **connection1_deadlock.sql** - 连接1
   - 功能：执行死锁演示代码（连接1）
   - 执行：在第一个SQL Server连接中执行

5. **connection2_deadlock.sql** - 连接2
   - 功能：执行死锁演示代码（连接2）
   - 执行：在第二个SQL Server连接中执行
   - 注意：需要与连接1同时（或几乎同时）执行

## 实验步骤

### 实验1：锁争夺演示

1. 打开第一个SQL Server连接，执行 `connection1_lock_contention.sql`
   - 事务会开始但不会提交，保持锁定状态
   - 保持此连接打开

2. 打开第二个SQL Server连接，执行 `connection2_lock_contention.sql`
   - 步骤1：查询会被阻塞，一直等待
   - 取消查询后，执行步骤2：使用lock_timeout，会返回错误1222

3. （可选）在任意连接中执行 `check_blocking.sql` 查看阻塞情况

4. 实验完成后，在连接1中执行 `COMMIT TRAN;` 或 `ROLLBACK TRAN;`

### 实验2：死锁演示

1. 打开第一个SQL Server连接，准备执行 `connection1_deadlock.sql`

2. 打开第二个SQL Server连接，准备执行 `connection2_deadlock.sql`

3. 同时（或几乎同时）在两个连接中执行各自的SQL文件

4. 观察结果：
   - 一个连接会成功执行并更新数据
   - 另一个连接会返回错误1205（死锁牺牲品）

## 测试数据

实验使用以下学生数据：
- sid: 800001216
- sname: gfxrgs
- email: hhce4@qhldj.gov
- grade: 1992

## 预期结果

### 实验1：锁争夺
- 连接2的查询会被阻塞
- 使用lock_timeout后，会返回错误1222（锁超时）

### 实验2：死锁
- 一个连接成功，另一个连接返回错误1205（死锁）
- 成功的事务会更新数据
- 失败的事务会自动回滚

## 注意事项

1. 确保使用正确的数据库（School_Data）
2. 实验需要多个独立的SQL Server连接
3. 死锁实验需要两个连接同时执行
4. 实验完成后记得提交或回滚未完成的事务

