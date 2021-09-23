import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import 'retry_interceptor_options.dart';

/// An interceptor that will try to send failed request again
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final Logger logger;
  RetryOptions options;

  RetryInterceptor(
      {required this.dio,
      required this.logger,
      this.options = const RetryOptions()});

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    final shouldRetry =
        options.retries > 0 && await options.retryEvaluator(err);
    if (shouldRetry) {
      if (options.retryInterval.inMilliseconds > 0) {
        await Future.delayed(options.retryInterval);
      }

      // Update options to decrease retry count before new try
      options = options.copyWith(retries: options.retries - 1);
      err.requestOptions.extra = err.requestOptions.extra
        ..addAll(options.toExtra());

      try {
        logger.warning(
            '[${err.requestOptions.uri}] An error occured during request, trying a again (remaining tries: ${options.retries}, error: ${err.error})');
        // We retry with the updated options

        final _options = Options(
            contentType: err.requestOptions.contentType,
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            extra: err.requestOptions.extra,
            validateStatus: err.requestOptions.validateStatus);

        await dio.request(
          err.requestOptions.path,
          cancelToken: err.requestOptions.cancelToken,
          data: err.requestOptions.data,
          onReceiveProgress: err.requestOptions.onReceiveProgress,
          onSendProgress: err.requestOptions.onSendProgress,
          queryParameters: err.requestOptions.queryParameters,
          options: _options,
        );
      } catch (e) {
        rethrow;
      }
    }

    return super.onError(err, handler);
  }
}
