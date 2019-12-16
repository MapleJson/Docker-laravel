### 下载
```
cd $HOME

git clone https://github.com/MapleJson/Docker-laravel.git docker
```

### 生成 docker-compose.yml
```
cd $HOME/docker

cp php-laravel/docker-compose.yml.example php-laravel/docker-compose.yml
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

### 目录结构
```
.
├── README.md
├── bin
│   ├── centos7-square-script.sh
│   ├── centos7_mysql57_install.sh
│   ├── centos_square_config.ini
│   ├── docker-addhost
│   ├── docker-delhost
│   ├── docker-exec
│   ├── docker-nginx
│   ├── docker-release
│   ├── docker-server
│   ├── git-clone
│   ├── git-pull
│   └── mac-services
├── docker-files
│   ├── web-nginx-php56
│   │   ├── Dockerfile
│   │   ├── nginx.conf
│   │   ├── start.sh
│   │   ├── supervisord.conf
│   │   └── web.conf
│   ......
├── ini
│   ├── 56
│   │   └── php.ini
│   ......
├── mysql57
│   ├── all
│   │   └── data
│   └── conf.d
│       └── mysqld.cnf
├── nginx
│   ├── conf.d
│   ├── nginx.conf.notcache
│   ├── ssl
│   │   └── options-ssl-nginx.cnf
│   ├── template-ssl.conf
│   └── template.conf
├── php-laravel
│   ├── docker-compose.yml
│   └── docker-compose.yml.example
└── www

```