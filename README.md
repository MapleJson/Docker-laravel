### 下载
```
cd $HOME

git clone https://github.com/MapleJson/Docker-laravel.git docker
```

### 生成 docker-compose.yml
```
cd $HOME/docker

cp php-laravel/docker-compose.yml.example docker-compose.yml
```
修改 docker-compose.yml 中的各项参数，使之适合自己的环境

### 启动/重启/停止
```
$HOME/docker/bin/docker-server up

$HOME/docker/bin/docker-server restart

$HOME/docker/bin/docker-server stop
```

### 进入容器
```
$HOME/docker/bin/docker-exec 56

$HOME/docker/bin/docker-exec 70

$HOME/docker/bin/docker-exec 71

$HOME/docker/bin/docker-exec 72
```

### 新增站点配置
```
$HOME/docker/bin/docker-addhost example.com project/public
```

### 删除站点配置
```
$HOME/docker/bin/docker-delhost example.com
```

### 重启 nginx
```
$HOME/docker/bin/docker-nginx
```