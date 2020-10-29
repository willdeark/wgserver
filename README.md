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
      "name": "wgserver1",            //wg服务名称
      "server_ip": "100.100.100.101", //wg服务IP
      "server_port": 11801,           //wg服务端口
      "http_prot": 8801               //wg服务api端口
    },
    //......
  ]
}
```

#### 3、运行

```bash
./cmd up -d
```
