---
layout: docs
title: qrsync 命令行同步工具
---


- [简介](#overview)
- [下载](#download)
- [用法](#usage)


<a id="overview"></a>
## 简介

qrsync 是一个根据七牛云存储API实现的简易命令行辅助上传同步工具，支持断点续上传，增量同步，它可将用户本地的某目录的文件同步到七牛云存储中，同步或上传几百GB甚至上TB的文件毫无鸭梨。

**注意：被同步的文件名和路径必须是utf8编码，非utf8的文件名和路径将会同步失败**

<a id="download"></a>
## 下载

qrsync 命令行辅助同步工具下载地址：

- Mac OS: <http://devtools.qiniu.io/qiniu-devtools-darwin_amd64-current.tar.gz>
- Linux 64bits: <http://devtools.qiniu.io/qiniu-devtools-linux_amd64-current.tar.gz>
- Linux 32bits: <http://devtools.qiniu.io/qiniu-devtools-linux_386-current.tar.gz>
- Linux ARMv6: <http://devtools.qiniu.io/qiniu-devtools-linux_arm-current.tar.gz>
- Windows 32bits: <http://devtools.qiniu.io/qiniu-devtools-windows_386-current.zip>
- Windows 64bits: <http://devtools.qiniu.io/qiniu-devtools-windows_amd64-current.zip>

<a id="usage"></a>
## 用法

先建立一个配置文件（[JSON格式](http://json.org/json-zh.html)），比如叫`conf.json`，内容如下：

```
{
    "access_key":               "<AccessKey>",
    "secret_key":               "<SecretKey>",

    "bucket":                   "<目标空间>",
    "sync_dir":                 "<本地源目录路径>",
    "persistent_ops":           "<异步转码规格列表>",
    "persistent_notify_url":    "<异步转码结果通知接收URL>",
    "debug_level":              1
}
```

其中，`AccessKey` 和 `SecretKey` 需要在七牛云存储平台上申请。步骤如下：

1. [开通七牛开发者帐号](https://portal.qiniu.com/signup)
2. [登录七牛管理控制台，查看 Access Key 和 Secret Key](https://portal.qiniu.com/setting/key)

参数名称   | 必填 | 说明
:--------- | :--- | :------
`bucket`   | 是   | ● 目标空间<br>是你在七牛云存储上希望保存数据的Bucket名称，选择一个合适的名字即可，要求是只能由字母、数字、下划线等组成。<br>可以先在[七牛管理控制台](https://portal.qiniu.com/)上创建。
`sync_dir` | 是   | ● 本地源目录路径<br>是本地需要同步上传目录的完整的绝对路径。这个目录中的所有内容会被同步到指定的 `bucket` 中。<br>注意：Windows 平台上路径的表示格式为：`盘符:/目录`，比如 E 盘下的目录 data 表示为：`e:/data` 。
`persistent_ops`        |      | ● 资源上传成功后触发执行的预转持久化处理指令列表<br>每个指令是一个API规格字符串，多个指令用“;”分隔。<br>请参看[详解](../api/reference/security/put-policy.html#put-policy-persistent-ops-explanation)与[示例](../api/reference/security/put-policy.html#put-policy-samples-persisntent-ops)。
`persistent_notify_url` |      | ● 接收预转持久化结果通知的URL<br>必须是公网上可以正常进行POST请求并能响应`HTTP/1.1 200 OK`的有效URL。如设置`persistenOps`字段，则本字段必须同时设置（未来可能转为可选项）。
`debug_level`           | 是   | ● 日志输出等级<br>通常设置1，只输出必要的日志。<br>当上传过程发生问题时，设置为0可以得到详细日志。

注意：切勿将配置文件保存在被同步的目录中，否则会带来泄露SecretKey的风险。

可以在 [七牛云存储开发者网站后台](https://portal.qiniu.com/) 进行相应的域名绑定操作，域名绑定成功后，若您将 bucket 设为公用（public）属性，则可以用如下方式对上传的文件进行访问：

    http://<绑定域名>/<key>

`key` 即是 `sync_dir` 里边文件名或文件的相对路径，`key` 可以包含斜杠但不能以斜杠开头。比如 `sync_dir` 存在文件 `a.txt` 和 `a/b/c.txt`，且绑定的域名为 `foo.qiniudn.com`，那么即可用如下路径访问：

    http://foo.qiniudn.com/a.txt
    http://foo.qiniudn.com/a/b/c.txt

在建立完 conf.json 配置文件后，就可以运行 qrsync 程序进行同步。

Unix/Linux/MacOS 系统可以用如下命令行：

    $ qrsync /path/to/your-conf.json

以上命令会将 `sync_dir` 目录中所有的文件包括软链接全部同步到 conf.json 配置文件指定的 `bucket` 中。也可以通过加上 `-skipsym` 选项来忽略软链接。

    $ qrsync -skipsym /path/to/your-conf.json

Windows 系统用户在 [开始] 菜单栏选择 [运行] 输入 `cmd` 回车即可打开 DOS 命令行窗口，然后切换到 qrsync.exe 的所在磁盘路径。假设你的 qrsync.exe 存放在 `d:/tools/qrsync.exe`，那么如下几行命令可以切换到 qrsync.exe 存放的目录：

    > d:
    > cd tools

进入到 qrsync.exe 所在目录后运行如下命令即可：

    > qrsync.exe /path/to/your-conf.json

需要注意的是，qrsync 是增量同步的，如果你上一次同步成功后修改了部分文件，那么再次运行 qrsync 时只同步新增的和被修改的文件。当然，如果上一次同步过程出错了，也可以重新运行 qrsync 程序继续同步。

### ignore 文件与规则

`qrsync` 支持使用 ignore 文件来忽略某些不需要上传的文件，详见[ ignore 规则](/docs/v6/tools/ignore-rules.html)。  
