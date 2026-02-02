-- ========================================
-- LC15 实验1：查看阻塞情况
-- 功能：使用 sp_who 查看进程阻塞情况
-- 执行说明：
-- 1. 在任意SQL Server连接中执行此文件
-- 2. 可以在连接1和连接2执行期间随时执行此文件
-- 3. 用于验证阻塞关系和进程状态
-- ========================================

USE School_Data;
GO

PRINT '========== 查看阻塞情况：使用 sp_who ==========';
PRINT '';

-- 方法1：使用 sp_who 查看所有进程
PRINT '方法1：使用 sp_who 查看所有进程';
PRINT '说明：查看 blk 列，如果值非0，表示该进程被阻塞';
PRINT '';

EXEC sp_who;

PRINT '';
PRINT '===============================================================';
PRINT '结果说明：';
PRINT '- spid：进程ID';
PRINT '- status：进程状态（suspended表示被阻塞）';
PRINT '- blk：阻塞该进程的进程ID（如果为0，表示未被阻塞）';
PRINT '- cmd：命令类型（SELECT、UPDATE等）';
PRINT '- dbname：数据库名称';
PRINT '';
PRINT '示例：如果进程54的blk值为58，说明进程54被进程58阻塞';
PRINT '===============================================================';
PRINT '';

-- 方法2：只查看被阻塞的进程
PRINT '方法2：只查看被阻塞的进程（blk != 0）';
PRINT '';

SELECT 
    spid AS '进程ID',
    status AS '状态',
    loginame AS '登录名',
    hostname AS '主机名',
    blk AS '被阻塞的进程ID',
    dbname AS '数据库',
    cmd AS '命令',
    request_id AS '请求ID'
FROM sys.sysprocesses
WHERE blk != 0;

PRINT '';
PRINT '===============================================================';
PRINT '如果上面的查询返回空结果，说明当前没有进程被阻塞';
PRINT '===============================================================';

-- 方法3：查看阻塞链（哪些进程阻塞了哪些进程）
PRINT '';
PRINT '方法3：查看阻塞链（阻塞关系）';
PRINT '';

SELECT 
    blocking.spid AS '阻塞进程ID',
    blocking.status AS '阻塞进程状态',
    blocking.cmd AS '阻塞进程命令',
    blocked.spid AS '被阻塞进程ID',
    blocked.status AS '被阻塞进程状态',
    blocked.cmd AS '被阻塞进程命令',
    blocked.blk AS '被阻塞进程的blk值'
FROM sys.sysprocesses AS blocking
INNER JOIN sys.sysprocesses AS blocked
    ON blocking.spid = blocked.blk
WHERE blocking.spid != blocked.spid;

PRINT '';
PRINT '===============================================================';
PRINT '如果上面的查询返回空结果，说明当前没有阻塞关系';
PRINT '===============================================================';

