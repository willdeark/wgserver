# wgserver

#### 1、克隆项目到您的本地或服务器

```bash
// 克隆项目
git clone https://github.com/willdeark/wgserver.git

// 进入目录
cd wgserver

// 拷贝 .env
cp .env.example .env
```

#### 2、修改`.env`

```env
SERVER_URL=调度中心接口地址，如：https://c.qishi.vip
SERVER_KEY=调度中心接口KEY
```

#### 3、运行

```bash
docker-compose up -d
```
