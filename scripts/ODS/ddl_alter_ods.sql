脚本名称：ddl_alter_ods.sql
功能说明：ODS层表结构变更维护脚本
1．用途：对ods架构下原始数据表执行结构变更，用于新增字段、调整字段类型/长度，适配源系统表结构迭代；
2．原则：ODS层保持和源系统结构对齐，仅修改表定义，不修改存量业务原始数据；
3．规范：使用COL_LENGTH判断字段是否存在，字段不存在才执行新增；执行前在测试库验证，生产变更前做好数据备份；
4．特点：增量变更脚本，不会重建整张表，支持重复多次执行，用于迭代维护ODS原始层。
当前状态：暂无表结构变更需求，待后续源系统表结构发生变动时，再在此脚本中添加ALTER TABLE语句。
*/
-- 模板示例（暂不启用，需要新增字段时再取消注释并修改表名、字段信息）
/*
IF COL_LENGTH('ods.xxx_table','xxx_col') IS NULL
BEGIN
    ALTER TABLE ods.xxx_table
    ADD xxx_col NVARCHAR(50) NULL;
END
GO
*/
