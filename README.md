# wireguard-server

## 1. Clone the project to your local or server

```bash
// Clone project
git clone https://github.com/willdeark/wgserver.git

// Enter the catalog
cd wgserver

// Copy config.json
cp config.example config.json
```

## 2. Modify `config.json`

```json
{
  "console": {
    "url": "",    //Dispatching center interface address
    "key": ""     //Dispatching center interface KEY
  },
  "wireguard": [
    {
      "name": "wgserver1",      //Wireguard service name
      "server_ip": "auto",      //Wireguard service IP, leave it blank or fill in `auto` to get it automatically
      "server_port": 11801,     //Wireguard service port
      "http_prot": 8801         //Wireguard service api port
    },
    //......
  ]
}
```

## 3. Run

```bash
./cmd up -d
```


## Issues: Known issues and solutions

```bash
# Error 1
jq： command not found

# Solve 1
#Ubuntu
sudo apt install jq -y  
#CentOS
sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum repolist
sudo yum install jq -y 

```