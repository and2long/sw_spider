import 'package:dio/dio.dart';
import 'package:swspider/network/interceptors.dart';

class XHttp {
  XHttp._internal();

  /// 网络请求配置
  static final Dio instance = Dio();

  /// 初始化dio
  static init() {
    //添加拦截器
    instance.interceptors.add(CustomInterceptors());
    instance.options.responseType = ResponseType.plain;
    instance.options.headers = {
      "User-Agent":
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36"
    };
  }
}
