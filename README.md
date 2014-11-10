VORefresh
=========
在MJRefresh基础上修改的
1. 支持上,下,左,右拉动加载
2. 支持竖屏,横屏
3. 支持自定义刷新文字,自定义子控件(默认为我之前发布的VORingIndicator和VORingProgressView)
   a. 自定义刷新文字支持NSString,NSAttributedString
   b. 刷新文字可现实2行,使用 \n 换行
   c. 设置刷新文字可使用NSArray, 也可以单独设置每一种状态的文字.
   d. 左右拉动时,竖排文字方向目前只是将UILabel进行了旋转(至于文字方向,等研究研究再说, 今天尝试了使用 \n 换行的方式,全是中文或者全是英文时没问题,一旦混排会很丑...直接放弃了,估计得使用coreText)
   e. 没有文字时,子控件会自动调整到中间.有文字在显示在1/4宽度或者1/4高度位置.
   f. activityView(默认为VORingIndicator) 如果支持startAnimating 和 stopAnimating方法,会自动调用
   h. progressView(默认为VOringProgressVIew) 如果有progress或者moveDistance属性,会自动设置这2个属性,达到拉动时的动画效果,可以看演示动画中使用的UIProgressView
   i. 自定义状态文字使用NSAttributedString可以实现文字的颜色显示.
 
 代码中有很多不足之处,希望大家提出意见~
