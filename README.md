# macOS-Displays-icon
[English Version](./en.md)  
## 关于此项目 
本项目是一个显示器设备图标数据库. 用于在macOS系统的"关于本机" > "显示器"界面中显示真实的设备显示器外观图标.

## 图标样式规则
1. 图标尺寸为 1024\*1024 
2. 请使用您能找到到的最清晰的显示器外观图片
3. 显示器外观图像背景干净, 轮廓清晰, 无水印
4. 使用项目中的 "Screen.jpg" 作为显示器的显示内容
5. 需要为显示器基座添加适当的阴影
6. 位置坐标得体适中(正中偏下)

## 文件命名规则
1. 将显示器图标文件以显示器接口的PID值命名, 例如: "a0be.icns"
2. 将图标文件放在以显示器制造商VID值命名的文件夹中, 例如: "10ac/a0be.icns"
3. 将图标的PID值添加入VID文件夹下的"{VID}.pid"文件中, 格式为: "PID值:显示器型号", 例如: "a0be:DELL P2415Q"

### 样例:
![img](https://raw.githubusercontent.com/lihaoyun6/macOS-Displays-icon/master/10ac/a0be.icns)
