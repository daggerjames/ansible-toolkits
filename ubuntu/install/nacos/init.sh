#!/bin/bash

# MySQL 服务器地址
if [ -z "$MYSQL_HOST" ]; then
    MYSQL_HOST="localhost"
fi
# MySQL 管理员用户名
if [ -z "$MYSQL_ROOT_USER" ]; then
    MYSQL_ROOT_USER="root"
fi
# MySQL 管理员密码
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    MYSQL_ROOT_PASSWORD="your_root_password"
fi
# 要创建的新用户
if [ -z "$NEW_USER" ]; then
    NEW_USER="new_user"
fi
# 新用户密码
if [ -z "$NEW_USER_PASSWORD" ]; then
    NEW_USER_PASSWORD="new_user_password"
fi
# 要创建的数据库
if [ -z "$DATABASE_NAME" ]; then
    DATABASE_NAME="new_database"
fi
# 创建用户
mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e "CREATE USER IF NOT EXISTS '$NEW_USER'@'%' IDENTIFIED BY '$NEW_USER_PASSWORD';"

RESULT=$(mysql -u $NEW_USER -p$NEW_USER_PASSWORD -e "SHOW DATABASES LIKE '$DATABASE_NAME';" | grep -w "$DATABASE_NAME")
if [ -z "$RESULT" ]; then
    echo "Database not $DATABASE_TO_CHECK exists."
    # 创建数据库
    mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE $DATABASE_NAME;"

    # 授权新用户对新数据库的权限
    mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO '$NEW_USER'@'%';"

    # 刷新权限
    mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"
    
    # 如果有初始化数据的 SQL 文件，可以在这里执行导入
    mysql -h $MYSQL_HOST -u $NEW_USER -p$NEW_USER_PASSWORD $DATABASE_NAME < /init_data.sql
fi
