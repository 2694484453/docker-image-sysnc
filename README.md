## 项目名称：docker-image-sync
>   简介：docker多版本镜像同步工具


## 配置说明
> 1.config/auth-config.json      
> docker主机域名地址、认证信息auth为base64(用户名:密码)的字符串

> 2.config/images-config.json 
> name为镜像原始名称、versions为需要同步的版本字符串数组、sync-list是需要打tag的名称；namespace为仓库空间名称；host仓库主机地址

## 运行条件
> 列出运行该项目所必须的条件和相关依赖  
* 条件一 ：docker环境
* 条件二 ：安装jq的json解析工具
* 条件三 ：需要同步到的仓库在auth-config.json配置齐



## 运行说明
> 说明如何运行和使用你的项目，建议给出具体的步骤说明
* 操作一 ：给sync.sh脚本赋权
* 操作二 ：执行./sync.sh
* 操作三  



## 测试说明
> 如果有测试相关内容需要说明，请填写在这里  



## 技术架构
> docker、shell  


## 协作者
> gaopuguang(2694484453@qq.com)
