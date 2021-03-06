小事一桩
==============
### Checklist的上架版本([App Store](https://itunes.apple.com/cn/app/%E5%B0%8F%E4%BA%8B%E4%B8%80%E6%A1%A9/id1209752906)当前版本2.1)

基本功能及涉及到的知识点:
==============
* 使用MVC设计模式；
* ~~通过NSUSerDefaults记录用户登录使用信息，判断用户是否为首次登录，如果是的话弹出帮助信息，帮助信息由UIAlertController实现~~ 此功能已删除；
* 主界面使用storyboard建立；
* 使用AutoLayout实现了自动适配多机型；
* 不同controller之间信息的回调采用了delegate的设计模式；
* 数据存储使用NSKeyedArchiver归档为.plist文件实现本地化存储（有时间会更改为SQLite数据库存储）；
* 本地通知使用了iOS10更新的通知方法；
* ~~集成了qq和微信的SDK，可实现分享到qq和微信~~ 此功能已删除。

新增功能（目前还不完善）：
==============
* ~~计划可设定为重要，被标注为重要的计划会醒目显示（1.0）；~~
* 计划详情页显示更多信息（仍在更新中）（1.0）；
* 界面改版，看起来顺眼了一些（1.0）；
* 新增侧滑界面（1.0）；
* 增加了时间线、快速计划、重要计划三个分类（1.0）；
* 在侧滑界面新增了天气显示，定位服务使用CoreLocation，网络请求使用URLSession，天气信息的接口由[心知天气](https://www.seniverse.com/)提供（1.1）；
* 新增计划或更新计划时会弹出一个HUD视图，提升了用户体验（1.2）；
* 完成计划后新增了删除线，去除了重要计划红色标注，红色标注导致整体不够协调（1.2）；
* 新增了左滑完成计划，点击计划弹出新的ViewController来显示计划详情，使用自定义转场实现（1.2）；
* 新增了将计划添加到系统日历（1.3）；
* 新增了NavigationBanner（2.0）；
* 新增了引导页（2.0）；
* 新增了选择计划类别页面的视察滚动效果（2.0）（感谢[Krishan](https://blog.krishan711.com/)）；
* 新增了成就系统，依据做计划和完成计划的数量达成成就（2.0）；
* 新增了历史上的今天模块，接口由[易源数据](https://www.showapi.com/)提供（2.0）；
* 新增了远程推送，由[极光推送](https://www.jiguang.cn/)提供技术支持（2.1）；
* 新增了应用内反馈，使用LeanCloud的[开源反馈组件](https://leancloud.cn/docs/feedback.html)（2.1）；
* 新增了Icon角标显示未完成计划数（2.1）；
* 历史上的今天加入图片显示（API本身提供），点击进入百度搜索详情（2.2）；

使用的第三方库（对牛X的作者表示由衷的感谢）：
==============
* [DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet)：非常出名的空页面解决方案；
* ~~[FoldingCell](https://github.com/Ramotion/folding-cell)：一个很炫酷的cell展开动画；~~
* [TableFlip](https://github.com/mergesort/TableFlip)：一个TableView的初始化动画；
* [DateTimePicker](https://github.com/itsmeichigo/DateTimePicker)：一个封装过的DateTimePicker，比原生的好看太多了；
* ~~[SWTableViewCell](https://github.com/CEWendel/SWTableViewCell)：可自定义的cell侧滑功能（库已导入，功能暂未实现）；~~
* [MGSwipeTableCell](https://github.com/MortimerGoro/MGSwipeTableCell)：cell侧滑功能的扩展；
* [TextFieldEffects](https://github.com/raulriera/TextFieldEffects)：UITextField的扩展，增加了一些好看的效果；
* [SWRevealViewController](https://github.com/John-Lluch/SWRevealViewController)：通过简单的步骤实现一个侧滑页面；
* [BRYXBanner](https://github.com/bryx-inc/BRYXBanner)：简单易用的NavigationBanner；
* [KSGuideController](https://github.com/skx926/KSGuideController)：基于UIView的一个新手引导页；
* [SwiftNotice](https://github.com/johnlui/SwiftNotice)：一行代码实现一个HUD；
* [KSGuideController](https://github.com/skx926/KSGuideController)：一个漂亮的新手引导库；
* [Alamofire](https://github.com/Alamofire/Alamofire)：这个不用说了，Swift最强大的网络处理库；
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)：Swift下最简单的处理JSON数据的库；
* [Kingfisher](https://github.com/onevcat/Kingfisher)：喵神大大的作品，纯Swift的图片下载和缓存库。

还有一些其他的想法，比如启动页，注册登录等等杂七杂八的功能，再慢慢往上加。
