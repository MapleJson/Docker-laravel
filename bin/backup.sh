#!/bin/bash
#数据库IP
dbserver='127.0.0.1'
#数据库用户名
dbuser='root'
#数据密码
dbpasswd='123456'
#数据库,如有多个库用空格分开
dbname='dbname'
#备份时间
backtime=`date +%Y%m%d-%H:%M`
#备份输出日志路径
logpath='/home/data/'


echo "################## ${backtime} #############################"
echo "开始备份"
#日志记录头部
echo "" >> ${logpath}/mysqlback.log
echo "-------------------------------------------------" >> ${logpath}/mysqlback.log
echo "备份时间为${backtime},备份数据库 ${dbname} 开始" >> ${logpath}/mysqlback.log
#正式备份数据库
for db in $dbname; do
source=`/usr/local/mysql/bin/mysqldump -h ${dbserver} -u ${dbuser} -p${dbpasswd} ${db} > ${logpath}/dump_${db}_${backtime}.sql` 2>> ${logpath}/mysqlback.log;
#备份成功以下操作
if [ "$?" == 0 ];then
cd ${logpath}
#删除七天前备份，也就是只保存7天内的备份
find $logpath -name "*.sql" -type f -mtime +3 -exec rm -rf {} \; > ${logpath} 2>&1
echo "数据库表 ${dbname} 备份成功!!" >> ${logpath}/mysqlback.log
else
#备份失败则进行以下操作
echo "数据库表 ${dbname} 备份失败!!" >> ${logpath}/mysqlback.log
fi
done
echo "完成备份"
echo "################## ${backtime} #############################"