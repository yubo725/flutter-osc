# FlutterOSC
- 基于Google Flutter的开源中国客户端，支持Android和iOS。
- [关于Google Flutter](https://flutter.io/)

# Android扫码下载APK
- 请使用手机浏览器扫码下载，不要使用微信或者qq扫码
- <img src='./screenshots/flutter_osc_qrcode.png'>

# 功能
- [x] 登录（使用osc账号）
- [x] 查看资讯（未登录即可查看）
- [x] 查看、回复、发表、评论动弹（需要登录）
- [x] 动弹小黑屋（需要登录）
- [x] “发现”部分的功能基本上都是用H5实现
- [x] 资讯列表、动弹列表、评论列表支持下拉刷新或分页加载
- [x] 支持主题切换（入口在侧滑菜单-设置-切换主题）
- [ ] 动弹中的图片预览暂未实现
- [ ] 摇一摇、“我的”页面功能暂时没完成

# 说明
1. ~~由于开源中国的openapi只提供了基于webview或浏览器的oauth认证方式，故该项目登录界面使用webview加载OSChina三方认证页面，请放心使用开源中国的账号和密码登录~~目前该项目支持原生登录页面和WebView方式登录
2. 受开源中国openapi的限制，获取动弹数据需要登录，由于openapi的资讯接口提供的数据比较简单，故资讯部分采用python爬取的网页数据
3. 本项目纯属个人兴趣爱好而写，不是开源中国官方版本，源代码仅供学习交流，实际使用请下载安装开源中国[官方APP](https://www.oschina.net/app)

# 截图
#### iOS
<div>
    <img src='./screenshots/ios-theme-01.png' width=280>
    <img src='./screenshots/ios-theme-02.png' width=280>
    <img src='./screenshots/ios-theme-03.png' width=280>
</div>
<div>
    <img src='./screenshots/ios01.png' width=280>
    <img src='./screenshots/ios02.png' width=280>
    <img src='./screenshots/ios10.png' width=280>
</div>
<div>
    <img src='./screenshots/ios04.png' width=280>
    <img src='./screenshots/ios05.png' width=280>
    <img src='./screenshots/ios06.png' width=280>
</div>
<div>
    <img src='./screenshots/ios07.png' width=280>
    <img src='./screenshots/ios08.png' width=280>
    <img src='./screenshots/ios09.png' width=280>
</div>

#### Android
<div>
    <img src='./screenshots/android01.jpg' width=280>
    <img src='./screenshots/android02.jpg' width=280>
    <img src='./screenshots/android03.jpg' width=280>
</div>
<div>
    <img src='./screenshots/android04.jpg' width=280>
    <img src='./screenshots/android05.jpg' width=280>
    <img src='./screenshots/android06.jpg' width=280>
</div>
<div>
    <img src='./screenshots/android07.jpg' width=280>
    <img src='./screenshots/android08.jpg' width=280>
    <img src='./screenshots/android09.jpg' width=280>
</div>

# LICENSE
The MIT License (MIT)

Copyright (c) 2018 yubo_725

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
