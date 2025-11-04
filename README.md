<img alt="GitHub License" src="https://img.shields.io/github/license/wukongdaily/be3600?labelColor=%23FF4500&color=black">  <img src="https://badges.toozhao.com/badges/01JDKPTDXFQYYWHEPS32QSD4XT/orange.svg" /> [![Bilibili](https://img.shields.io/badge/Bilibili-123456?logo=bilibili&logoColor=fff&labelColor=fb7299)](https://www.bilibili.com/video/BV1J4J3zAEDz) [![YouTube](https://img.shields.io/badge/YouTube-123456?logo=youtube&labelColor=ff0000)](https://youtu.be/WhtPERoU7PY)
# be3600 <img alt="Static Badge" src="https://img.shields.io/badge/GL--BE3600-0?style=flat-square&logoColor=8A2BE2&label=%E5%9E%8B%E5%8F%B7&labelColor=000000&color=2828FF"> 
Make your GL-BE3600 look like iStoreOS in one step<br>
- ✅ 一键iStoreOS风格化([32位](https://youtu.be/TImSMeurR84)和64位)
- ✅ 目前[64位固件下](https://github.com/wukongdaily/be3600/releases/tag/0515) 可完美使用iStore商店安装软件
- ✅ 同时软件包下支持直接安装app-meta-开头的app
- ✅ 支持单独安装iStore 方便用户恢复系统备份
- ✅ 支持单独安装Argon紫色主题
- ✅ 支持一键重置路由器
- ✅ Tips 实测在iStore——【维护】里可将系统完整备份和恢复
- ✅ 脚本运行后各类ssh工具就支持文件上传下载了 譬如finalshell/MobaXterm
- ✅ 该脚本仅在应用层安装app 并不影响原厂系统功能和界面
- ✅ 自定义风扇启动的温度
- ✅ 一键启用/关闭 AdguardHome 广告拦截
- ✅ 新增`个性化辅助UI插件的安装` 🆕
 
- 未来可能支持待发布GL.iNET Flint 3 (GL-BE9300、BE6500)  理论上目前也可兼容


> 其他机型:[GL-MT3000/6000/2500 在这里](https://github.com/wukongdaily/gl-inet-onescript/)
# 一键命令

```bash
sh -c "$(curl -fsSL https://mt3000.netlify.app/be3600.sh)"
```

### 不刷机方案下的使用指南

- 【4.7.2 在64位系统下演示 】https://youtu.be/WhtPERoU7PY   和 https://www.bilibili.com/video/BV1J4J3zAEDz<br>

[![赞助我](https://img.shields.io/badge/赞助用爱发电的我-支持作者的项目-orange?logo=github)](https://wkdaily.cpolar.top/01)<br>

### 更新新版iStoreOS风格的首页

<img width="3840" height="4297" alt="FireShot Capture 003 - GL-BE3600 - LuCI -  192 168 8 1" src="https://github.com/user-attachments/assets/7eb5c18f-8e46-4314-8c84-42cffb8a6fff" />

## ⚠️⚠️⚠️ 软件源注意事项
luci首页【软件源配置】这个按钮  这个功能是给iStoreOS 用的。<br>
现在我们的系统是GL原厂系统 不是iStoreOS，如果你点了这按钮 就会把软件源弄乱。<br>
变成一个错误的软件源地址。各位别点这个按钮。如果不小心点了 你再换回原厂软件源就行 方法如下<br>
进入luci界面——系统——软件包——OPKG配置，最后一个输入框(`/etc/opkg/distfeeds.conf`)，替换为原厂的软件源

```
src/gz glinet_core https://fw.gl-inet.cn/releases/qsdk_v12.5/kmod-4.7/be3600-ipq53xx
src/gz glinet_gli_pub https://fw.gl-inet.cn/releases/qsdk_v12.5/packages-4.x/ipq53xx/be9300/glinet
src/gz opnwrt_packages https://fw.gl-inet.cn/releases/qsdk_v12.5/packages-4.x/ipq53xx/be9300/packages
```
