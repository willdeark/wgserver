# wgserver

#### 1、克隆项目到您的本地或服务器

```bash
// 克隆项目
git clone https://github.com/willdeark/wgserver.git

// 进入目录
cd wgserver

// 拷贝 config.json
cp config.example config.json
```

#### 2、修改`config.json`

```json
{
  "console": {
    "url": "",    //调度中心接口地址，如：https://c.qishi.vip
    "key": ""     //调度中心接口KEY
  },
  "wireguard": [
    {
      "name": "wgserver1",      //wg服务名称
      "server_ip": "auto",      //wg服务IP，留空或填写auto自动获取
      "server_port": 11801,     //wg服务端口
      "http_prot": 8801         //wg服务api端口
    },
    //......
  ]
}
```

#### 3、运行

```bash
./cmd up -d
```


#### 4、已知问题及解决方案

```
# 提示1
jq： command not found

# 解决
#Ubuntu
sudo apt install jq -y  
#CentOS
sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum repolist
sudo yum install jq -y 

```