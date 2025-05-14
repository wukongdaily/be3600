#!/bin/sh
# 定义颜色输出函数
red() { echo -e "\033[31m\033[01m$1\033[0m"; }
green() { echo -e "\033[32m\033[01m$1\033[0m"; }
yellow() { echo -e "\033[33m\033[01m$1\033[0m"; }
blue() { echo -e "\033[34m\033[01m$1\033[0m"; }
light_magenta() { echo -e "\033[95m\033[01m$1\033[0m"; }
light_yellow() { echo -e "\033[93m\033[01m$1\033[0m"; }
cyan() { echo -e "\033[38;2;0;255;255m$1\033[0m"; }
third_party_source="https://istore.linkease.com/repo/all/nas_luci"

# 设置全局命令 be
cp -f "$0" /usr/bin/be
chmod +x /usr/bin/be

setup_base_init() {
	#添加出处信息
	add_author_info
	#添加安卓时间服务器
	add_dhcp_domain
	##设置时区
	uci set system.@system[0].zonename='Asia/Shanghai'
	uci set system.@system[0].timezone='CST-8'
	uci commit system
	/etc/init.d/system reload
	green "安装完毕！请使用8080端口访问luci界面：http://192.168.8.1:8080"
	green "作者更多动态务必收藏：https://tvhelper.cpolar.top/"
}

## 安装应用商店和主题
install_istore_os_style() {
	##设置Argon 紫色主题
	do_install_argon_skin
	#增加终端
	opkg install luci-i18n-ttyd-zh-cn
	#默认安装必备工具SFTP 方便下载文件 比如finalshell等工具可以直接浏览路由器文件
	opkg install openssh-sftp-server
	#默认使用体积很小的文件传输：系统——文件传输
	do_install_filetransfer
	FILE_PATH="/etc/openwrt_release"
	NEW_DESCRIPTION="Openwrt like iStoreOS Style by wukongdaily"
	CONTENT=$(cat $FILE_PATH)
	UPDATED_CONTENT=$(echo "$CONTENT" | sed "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='$NEW_DESCRIPTION'/")
	echo "$UPDATED_CONTENT" >$FILE_PATH
}
# 安装iStore 
do_istore() {
	echo "do_istore method==================>"
	opkg update
	# 定义目标 URL 和本地目录
	URL="https://repo.istoreos.com/repo/all/store/"
	DIR="/tmp/ipk_store"

	# 创建目录
	mkdir -p "$DIR"
	cd "$DIR" || exit 1

	for ipk in $(wget -qO- "$URL" | grep -oE 'href="[^"]+\.ipk"' | cut -d'"' -f2); do
		echo "下载 $ipk"
		wget -q "${URL}${ipk}"
	done

	# 安装所有下载的 .ipk 包
	opkg install ./*.ipk

}


# 判断系统是否为iStoreOS
is_iStoreOS() {
	DISTRIB_ID=$(cat /etc/openwrt_release | grep "DISTRIB_ID" | cut -d "'" -f 2)
	# 检查DISTRIB_ID的值是否等于'iStoreOS'
	if [ "$DISTRIB_ID" = "iStoreOS" ]; then
		return 0 # true
	else
		return 1 # false
	fi
}

## 去除opkg签名
remove_check_signature_option() {
	local opkg_conf="/etc/opkg.conf"
	sed -i '/option check_signature/d' "$opkg_conf"
}

## 添加opkg签名
add_check_signature_option() {
	local opkg_conf="/etc/opkg.conf"
	echo "option check_signature 1" >>"$opkg_conf"
}

#设置第三方软件源
setup_software_source() {
	## 传入0和1 分别代表原始和第三方软件源
	if [ "$1" -eq 0 ]; then
		echo "# add your custom package feeds here" >/etc/opkg/customfeeds.conf
		##如果是iStoreOS系统,还原软件源之后，要添加签名
		if is_iStoreOS; then
			add_check_signature_option
		else
			echo
		fi
		# 还原软件源之后更新
		opkg update
	elif [ "$1" -eq 1 ]; then
		#传入1 代表设置第三方软件源 先要删掉签名
		remove_check_signature_option
		# 先删除再添加以免重复
		echo "# add your custom package feeds here" >/etc/opkg/customfeeds.conf
		echo "src/gz third_party_source $third_party_source" >>/etc/opkg/customfeeds.conf
		# 设置第三方源后要更新
		opkg update
	else
		echo "Invalid option. Please provide 0 or 1."
	fi
}

# 添加主机名映射(解决安卓原生TV首次连不上wifi的问题)
add_dhcp_domain() {
	local domain_name="time.android.com"
	local domain_ip="203.107.6.88"

	# 检查是否存在相同的域名记录
	existing_records=$(uci show dhcp | grep "dhcp.@domain\[[0-9]\+\].name='$domain_name'")
	if [ -z "$existing_records" ]; then
		# 添加新的域名记录
		uci add dhcp domain
		uci set "dhcp.@domain[-1].name=$domain_name"
		uci set "dhcp.@domain[-1].ip=$domain_ip"
		uci commit dhcp
	else
		echo
	fi
}

#添加出处信息
add_author_info() {
	uci set system.@system[0].description='wukongdaily'
	uci set system.@system[0].notes='文档说明:
    https://tvhelper.cpolar.top/'
	uci commit system
}

##获取软路由型号信息
get_router_name() {
	model_info=$(cat /tmp/sysinfo/model)
	echo "$model_info"
}

get_router_hostname() {
	hostname=$(uci get system.@system[0].hostname)
	echo "$hostname 路由器"
}


# 安装体积非常小的文件传输软件 默认上传位置/tmp/upload/
do_install_filetransfer() {
	mkdir -p /tmp/luci-app-filetransfer/
	cd /tmp/luci-app-filetransfer/
	wget -O luci-app-filetransfer_all.ipk "https://cafe.cpolar.top/wkdaily/gl-inet-onescript/raw/branch/master/luci-app-filetransfer/luci-app-filetransfer_all.ipk"
	wget -O luci-lib-fs_1.0-14_all.ipk "https://cafe.cpolar.top/wkdaily/gl-inet-onescript/raw/branch/master/luci-app-filetransfer/luci-lib-fs_1.0-14_all.ipk"
	opkg install *.ipk --force-depends
}
do_install_depends_ipk() {
	wget -O "/tmp/luci-lua-runtime_all.ipk" "https://cafe.cpolar.top/wkdaily/gl-inet-onescript/raw/branch/master/theme/luci-lua-runtime_all.ipk"
	wget -O "/tmp/libopenssl3.ipk" "https://cafe.cpolar.top/wkdaily/gl-inet-onescript/raw/branch/master/theme/libopenssl3.ipk"
	opkg install "/tmp/luci-lua-runtime_all.ipk"
	opkg install "/tmp/libopenssl3.ipk"
}
#单独安装argon主题
do_install_argon_skin() {
	echo "正在尝试安装argon主题......."
	#下载和安装argon的依赖
	do_install_depends_ipk
	# bug fix 由于2.3.1 最新版的luci-argon-theme 登录按钮没有中文匹配,而2.3版本字体不对。
	# 所以这里安装上一个版本2.2.9,考虑到主题皮肤并不需要长期更新，因此固定版本没问题
	opkg update
	opkg install luci-lib-ipkg
	wget -O "/tmp/luci-theme-argon.ipk" "https://cafe.cpolar.top/wkdaily/gl-inet-onescript/raw/branch/master/theme/luci-theme-argon-master_2.2.9.4_all.ipk"
	wget -O "/tmp/luci-app-argon-config.ipk" "https://cafe.cpolar.top/wkdaily/gl-inet-onescript/raw/branch/master/theme/luci-app-argon-config_0.9_all.ipk"
	wget -O "/tmp/luci-i18n-argon-config-zh-cn.ipk" "https://cafe.cpolar.top/wkdaily/gl-inet-onescript/raw/branch/master/theme/luci-i18n-argon-config-zh-cn.ipk"
	cd /tmp/
	opkg install luci-theme-argon.ipk luci-app-argon-config.ipk luci-i18n-argon-config-zh-cn.ipk
	# 检查上一个命令的返回值
	if [ $? -eq 0 ]; then
		echo "argon主题 安装成功"
		# 设置主题和语言
		uci set luci.main.mediaurlbase='/luci-static/argon'
		uci set luci.main.lang='zh_cn'
		uci commit
		echo "重新登录web页面后, 查看新主题 "
	else
		echo "argon主题 安装失败! 建议再执行一次!再给我一个机会!事不过三!"
	fi
}


firstboot() {
    echo "⚠️ 警告：此操作将恢复出厂设置，所有配置将被清除！"
    echo "⚠️ 请确保已备份必要数据。"
    read -p "是否确定执行恢复出厂设置？(yes/[no]): " confirm

    if [ "$confirm" = "yes" ]; then
        echo "正在执行恢复出厂设置..."
        firstboot -y
        echo "操作完成，正在重启设备..."
        reboot
    else
        echo "操作已取消。"
    fi
}


while true; do
	clear
	gl_name=$(get_router_name)
	result="GL-iNet Be3600 一键iStoreOS风格化"
	echo "***********************************************************************"
	echo "*      一键安装工具箱(for gl-inet be3600)  by @wukongdaily        "
	echo "**********************************************************************"
	echo "*******支持的机型列表***************************************************"
	green "*******GL-iNet BE-3600********"
	echo
	light_magenta " 1. $result"
	echo
	light_magenta " 2. 重置路由器"
	echo
	echo " Q. 退出本程序"
	echo
	read -p "请选择一个选项: " choice

	case $choice in

	1)
		#安装iStore风格
		install_istore_os_style
		#基础必备设置
		setup_base_init
		;;
	2)
		firstboot
		;;
	q | Q)
		echo "退出"
		exit 0
		;;
	*)
		echo "无效选项，请重新选择。"
		;;
	esac

	read -p "按 Enter 键继续..."
done
