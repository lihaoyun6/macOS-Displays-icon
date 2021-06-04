#!/bin/sh
version=0.4.3
localtext_zh_CN() {
cat <<EOF


                       -- MonitorFace --
                     v$version © lihaoyun6 2021
                自动识别并安装符合显示器真实外观的图标
              本项目基于本人维护的显示器个性化图标数据库
 欢迎向 👉https://github.com/lihaoyun6/macOS-Displays-icon 提交图标


EOF
	welcome="欢迎向 👉https://github.com/lihaoyun6/macOS-Displays-icon 提交图标"
	checkdisplay="正在检测显示器数据..."
	finded="共找到 "
	displays=" 台显示器"
	checkdatabase="正在搜索数据库..."
	text1="第 "
	text2=" 台显示器: "
	text3=" 的图标已找到"
	text4=" 为Apple显示器, 无需安装图标"
	downloading="正在下载图标数据..."
	installing="正在安装图标..."
	remounting="正在解除写保护..."
	ntext3=" 的图标未找到"
	displayname="显示器名称: "
	displayvid=", 显示器VID: "
	displaypid=", 显示器PID: "
	alldone="所有显示器图标已安装完成. 重启或重新拔插显示器即可看到效果."
	remounting="正在解除写保护..."
	checksip="正在检测SIP状态..."
	disablesip="为了保证正常写入系统文件夹, 请关闭SIP保护."
	hr="=================================================================="
}
localtext_en_US() {
cat <<EOF


                       -- MonitorFace --
                     v$version © lihaoyun6 2018
            Automatically identify the monitor model
      and install icon file that shows how the monitor looks
Share your icon 👉https://github.com/lihaoyun6/macOS-Displays-icon


EOF
	welcome="Share your icon 👉https://github.com/lihaoyun6/macOS-Displays-icon"
	checkdisplay="Checking monitor(s) info..."
	finded=""
	displays=" monitor(s) found"
	checkdatabase="Searching from database..."
	text1="The icon of monitor "
	text2=" ("
	text3=") has been found"
	text4=") is an Apple Display"
	downloading="Downloading icon file..."
	installing="Installing icon file..."
	remounting="Remounting filesystem writeable..."
	ntext3=") cannot be found"
	displayname="Monitor: "
	displayvid=", VendorID: "
	displaypid=", ProductID: "
	alldone="All icon files have been installed. Please replug your monitor."
	remounting="Remounting filesystem writeable..."
	checksip="Checking SIP status..."
	disablesip="We need write system folders, so please disable SIP."
	hr="=================================================================="
}
icon() {
	echo $checkdisplay
	AS=$(sysctl -n machdep.cpu.brand_string|grep Apple|wc -l)
	if [ $AS = "1" ];then
		vids=$(printf "%x\n" $(ioreg -l|grep -i "DisplayAttributes"|grep -Eo "\"LegacyManufacturerID\"=\d*"|awk -F'=' '{print $NF}'))
		pids=$(printf "%x\n" $(ioreg -l|grep -i "DisplayAttributes"|grep -Eo "\"ProductID\"=\d*"|awk -F'=' '{print $NF}'))
		names=$(ioreg -l|grep -i "DisplayAttributes"|grep -Eo "\"ProductName\"=\"[^\"]*"|awk -F'="' '{print $NF}')
		num=$(echo $vids|awk '{print NF}')
	else
		edids=$(ioreg -lw0|grep IODisplayEDID|grep -o "<.*>"|sed "s/[<>]//g")
		vids=$(printf "%x\n" $(ioreg -l | grep "DisplayVendorID"|awk '{print $NF}'))
		pids=$(printf "%x\n" $(ioreg -l | grep "DisplayProductID"|awk '{print $NF}'))
		num=$(echo $vids|awk '{print NF}')
	fi
	echo $finded$num$displays
	echo $checkdatabase
	echo $hr
	for i in $(seq 1 $num);do
		vid=$(printf "$vids\n"|sed -n "${i}p")
		pid=$(printf "$pids\n"|sed -n "${i}p")
		if [ $AS == "1" ];then
			name=$(echo "$names"|sed -n ''$i'p')
		else
			name=$(printf "$edids\n"|sed -n "${i}p"|grep -Eo "fc00.*?0a"|sed "s/^fc00//g"|xxd -r -p)
		fi
		index=$(curl -s $url/${vid}/${vid}.pid)
		valid=$(echo "$index"|awk -F':' '{print $1}'|grep -m 1 "${pid}"|awk -F',' '{print $1}')
		if [ ! -z "$valid" ];then
			echo $text1$i$text2$name$text3
			echo $displayname$name$displayvid$vid$displaypid$pid
			echo $downloading
			mkdir -p $1/DisplayVendorID-${vid}
			rm -rf $1/Icons.plist 2>/dev/null
			cp /System/Library/Displays/Contents/Resources/Overrides/Icons.plist $1/Icons.plist
			/usr/libexec/PlistBuddy -c "Add :vendors:${vid}:products:${pid}:display-icon string" $1/Icons.plist 2>/dev/null
			/usr/libexec/PlistBuddy -c "Set :vendors:${vid}:products:${pid}:display-icon $1/DisplayVendorID-${vid}/DisplayProductID-${pid}.icns" $1/Icons.plist 2>/dev/null
			if [[ $valid =~ "*" ]];then
				valid=$(echo $valid|tr -d '*')
				curl -s ${url}/${vid}/tiff/${valid}.tiff > $1/DisplayVendorID-${vid}/DisplayProductID-${pid}.tiff
				read h w x y <<< $(curl -s $url/${vid}/tiff/preview.txt|grep $valid|awk -F':' '{print $2}')
				/usr/libexec/PlistBuddy -c "Add :vendors:${vid}:products:${pid}:display-resolution-preview-icon string" $1/Icons.plist 2>/dev/null
				/usr/libexec/PlistBuddy -c "Add :vendors:${vid}:products:${pid}:resolution-preview-height integer" $1/Icons.plist 2>/dev/null
				/usr/libexec/PlistBuddy -c "Add :vendors:${vid}:products:${pid}:resolution-preview-width integer" $1/Icons.plist 2>/dev/null
				/usr/libexec/PlistBuddy -c "Add :vendors:${vid}:products:${pid}:resolution-preview-x integer" $1/Icons.plist 2>/dev/null
				/usr/libexec/PlistBuddy -c "Add :vendors:${vid}:products:${pid}:resolution-preview-y integer" $1/Icons.plist 2>/dev/null
				/usr/libexec/PlistBuddy -c "Set :vendors:${vid}:products:${pid}:display-resolution-preview-icon $1/DisplayVendorID-${vid}/DisplayProductID-${pid}.tiff" $1/Icons.plist 2>/dev/null
				/usr/libexec/PlistBuddy -c "Set :vendors:${vid}:products:${pid}:resolution-preview-height $h" $1/Icons.plist 2>/dev/null
				/usr/libexec/PlistBuddy -c "Set :vendors:${vid}:products:${pid}:resolution-preview-width $w" $1/Icons.plist 2>/dev/null
				/usr/libexec/PlistBuddy -c "Set :vendors:${vid}:products:${pid}:resolution-preview-x $x" $1/Icons.plist 2>/dev/null
				/usr/libexec/PlistBuddy -c "Set :vendors:${vid}:products:${pid}:resolution-preview-y $y" $1/Icons.plist 2>/dev/null
			fi
			curl -s ${url}/${vid}/${valid}.png > /tmp/DisplayProductID-${pid}.png
			echo $installing
			rm -R /tmp/icon.iconset 2>/dev/null
			mkdir /tmp/icon.iconset
			sips -z 16 16 /tmp/DisplayProductID-${pid}.png --out /tmp/icon.iconset/icon_16x16.png >/dev/null 2>&1
			sips -z 32 32 /tmp/DisplayProductID-${pid}.png --out /tmp/icon.iconset/icon_16x16@2x.png >/dev/null 2>&1
			sips -z 32 32 /tmp/DisplayProductID-${pid}.png --out /tmp/icon.iconset/icon_32x32.png >/dev/null 2>&1
			sips -z 64 64 /tmp/DisplayProductID-${pid}.png --out /tmp/icon.iconset/icon_32x32@2x.png >/dev/null 2>&1
			sips -z 128 128 /tmp/DisplayProductID-${pid}.png --out /tmp/icon.iconset/icon_128x128.png >/dev/null 2>&1
			sips -z 256 256 /tmp/DisplayProductID-${pid}.png --out /tmp/icon.iconset/icon_128x128@2x.png >/dev/null 2>&1
			sips -z 256 256 /tmp/DisplayProductID-${pid}.png --out /tmp/icon.iconset/icon_256x256.png >/dev/null 2>&1
			sips -z 512 512 /tmp/DisplayProductID-${pid}.png --out /tmp/icon.iconset/icon_256x256@2x.png >/dev/null 2>&1
			sips -z 512 512 /tmp/DisplayProductID-${pid}.png --out /tmp/icon.iconset/icon_512x512.png >/dev/null 2>&1
			cp /tmp/DisplayProductID-${pid}.png /tmp/icon.iconset/icon_512x512@2x.png
			iconutil -c icns -o $1/DisplayVendorID-${vid}/DisplayProductID-${pid}.icns /tmp/icon.iconset
			rm -R /tmp/icon.iconset 2>/dev/null
			#mv -f /tmp/DisplayProductID-${pid}.png $1/DisplayVendorID-${vid}/
			echo $hr
		elif [ x"$valid" != x"${pid}:" -a "$vid" != "610" ];then
			echo $text1$i$text2$name$ntext3
			echo $displayname$name$displayvid$vid$displaypid$pid
			echo $welcome
			echo $hr
		else
			echo $text1$i$text2$name$text4
			echo $displayname$name$displayvid$vid$displaypid$pid
			echo $hr
		fi
	done
	echo $alldone
}

add=$(/usr/bin/curl -s cip.cc|grep -o -m1 "中国")
if [ x"$add" = x"中国" ];then
	url="https://gitee.com/lihaoyun/macOS-Displays-icon/raw/master"
else
	url="https://raw.githubusercontent.com/lihaoyun6/macOS-Displays-icon/master"
fi
lang=$(osascript -e 'user locale of (get system info)')
#lang=qqq
if [ x"$lang" = x"zh_CN" ];then
	localtext_zh_CN
else
	localtext_en_US
fi

sys=$(sw_vers -buildVersion|grep -Eo "^\d+")
if [ "$sys" -ge 20 ];then
	icon "/Library/Displays/Contents/Resources/Overrides"
elif [ "$sys" -ge 15 ];then
	echo $checksip
	sip=$(csrutil status|awk '{print $NF}'|sed 's/\.//g')
	sip2=$(csrutil status|grep "Filesystem Protections"|awk '{print $NF}')
	if [ "$sip" = "disabled" -o "$sip2" = "disabled" ];then
		echo $remounting
		mount -o rw /
		icon "/System/Library/Displays/Contents/Resources/Overrides"
	else
		echo $disablesip
	fi
else
	icon "/System/Library/Displays/Overrides"
fi
