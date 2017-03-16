# 小事一桩
Checklist的上架版本(1.0)

基本功能及涉及到的知识点:
* 使用MVC设计模式；
* ~~通过NSUSerDefaults记录用户登录使用信息，判断用户是否为首次登录，如果是的话弹出帮助信息，帮助信息由UIAlertController实现~~ 此功能已删除；
* 主界面使用storyboard建立；
* 使用AutoLayout实现了自动适配多机型；
* 不同controller之间信息的回调采用了delegate的设计模式；
* 数据存储使用NSKeyedArchiver归档为.plist文件实现本地化存储（有时间会更改为SQLite数据库存储）；
* 本地通知使用了iOS10更新的通知方法；
* ~~集成了qq和微信的SDK，可实现分享到qq和微信~~ 此功能已删除；

新增功能（目前还不完善）：
* 计划可设定为重要，被标注为重要的计划会醒目显示；
* 计划详情页显示更多信息（仍在更新中）；
* 界面改版，看起来顺眼了一些；
* 新增侧滑界面；
* 增加了时间线、快速计划、重要计划三个分类；

使用的第三方库（对牛X的作者表示由衷的感谢）：
* [DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet)：非常出名的空页面解决方案；
* ~~[FoldingCell](https://github.com/Ramotion/folding-cell)：一个很炫酷的cell展开动画；~~
* [TableFlip](https://github.com/mergesort/TableFlip)：一个TableView的初始化动画；
* [DateTimePicker](https://github.com/itsmeichigo/DateTimePicker)：一个封装过的DateTimePicker，比原生的好看太多了；
* ~~[SWTableViewCell](https://github.com/CEWendel/SWTableViewCell)：可自定义的cell侧滑功能（库已导入，功能暂未实现）；~~
* [MGSwipeTableCell](https://github.com/MortimerGoro/MGSwipeTableCell)：cell侧滑功能的扩展；
* [TextFieldEffects](https://github.com/raulriera/TextFieldEffects)：UITextField的扩展，增加了一些好看的效果；
* [SWRevealViewController](https://github.com/John-Lluch/SWRevealViewController)：通过简单的步骤实现一个侧滑页面。

还有一些其他的想法，比如启动页，注册登录，实时显示天气等等杂七杂八的功能，再慢慢往上加。
