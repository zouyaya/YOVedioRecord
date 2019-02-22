# YOVedioRecord
iOS视频录制的三种方式实现

 1，本人利用工作之余，自我实践了iOS视频录制的三种方式分别是UIImagePickerViewController,AVCaptureSession + AVCaptureMovieFileOut,
 以及AVCaptureSession+AVASSetWriter,
 
 
三种方式的实现不同
1，UIImagePickerViewController 主要是系统自带的，从而设置媒体类型是vidio，从而进行录制以及从本地相册中只选择视频
2，AVCaptureSession + AVCaptureMovieFileOut的实现过程
   ///0. 初始化捕捉会话，数据的采集都在会话中处理
     ///1. 设置视频的输入
     ///2. 设置音频的输入
     ///3.添加写入文件的fileoutput
     ///4. 视频的预览层
     ///5. 开始采集画面
     /// 6. 将采集的数据写入文件（用户点击按钮即可将采集到的数据写入文件）
     /// 7. 增加聚焦功能（可有可无）
     //此方式可以防止抖动，
     //视频防抖 是在 iOS 6 和 iPhone 4S 发布时引入的功能。到了 iPhone 6，增加了更强劲和流畅的防抖模式，
     被称为影院级的视频防抖动。相关的 API 也有所改动 (目前为止并没有在文档中反映出来，不过可以查看头文件）。
     防抖并不是在捕获设备上配置的，而是在 AVCaptureConnection 上设置。由于不是所有的设备格式都支持全部的防抖模式，
     所以在实际应用中应事先确认具体的防抖模式是否支持：
  3，AVCaptureSession+AVASSetWriter//实现过程
      ///1. 初始化捕捉会话，数据的采集都在会话中处理
      ///2. 设置视频的输入输出
      ///3. 设置音频的输入输出
      ///4. 视频的预览层
      ///5. 开始采集画面
      /// 6. 初始化writer， 用writer 把数据写入文件
