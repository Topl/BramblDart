part of 'package:brambldart/client.dart';

class ApiKeyAuthInterceptor extends AuthInterceptor {
  final Map<String, String> apiKeys = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final authInfo = getAuthInfo(options, 'apiKey');
    for (final info in authInfo) {
      final authName = info['name'] as String;
      final authKeyName = info['keyName'] as String;
      final authWhere = info['where'] as String;
      final apiKey = apiKeys[authName];
      if (apiKey != null) {
        if (authWhere == 'query') {
          options.queryParameters[authKeyName] = apiKey;
        } else {
          options.headers[authKeyName] = apiKey;
        }
      }
    }
    super.onRequest(options, handler);
  }
}

abstract class AuthInterceptor extends Interceptor {
  /// Get auth information on given route for the given type.
  /// Can return an empty list if type is not present on auth data or
  /// if route doesn't need authentication.
  List<Map<String, dynamic>> getAuthInfo(RequestOptions route, String type) {
    if (route.extra.containsKey('secure')) {
      final auth = route.extra['secure'] as List<Map<String, String>>;
      final results = <Map<String, dynamic>>[];
      for (final info in auth) {
        if (info['type'] == type) {
          results.add(info);
        }
      }
      return results;
    }
    return [];
  }
}

typedef RetryEvaluator = FutureOr<bool> Function(DioError error);

class RetryOptions {
  /// The number of retry in case of an error
  final int retries;

  /// The interval before a retry.
  final Duration retryInterval;

  /// Evaluating if a retry is necessary.regarding the error.
  ///
  /// It can be a good candidate for additional operations too, like
  /// updating authentication token in case of a unauthorized error (be careful
  /// with concurrency though).
  ///
  /// Defaults to [defaultRetryEvaluator].
  RetryEvaluator get retryEvaluator => _retryEvaluator;

  final RetryEvaluator _retryEvaluator;

  const RetryOptions(
      {this.retries = 3,
      RetryEvaluator retryEvaluator = defaultRetryEvaluator,
      this.retryInterval = const Duration(seconds: 1)})
      : _retryEvaluator = retryEvaluator;

  factory RetryOptions.noRetry() {
    return const RetryOptions(
      retries: 0,
    );
  }

  static const extraKey = 'cache_retry_request';

  /// Returns [bool] = true only if the response hasn't been cancelled or got
  /// a bas status code.
  static FutureOr<bool> defaultRetryEvaluator(DioError error) {
    return error.type != DioErrorType.cancel &&
        error.type != DioErrorType.response;
  }

  factory RetryOptions.fromExtra(RequestOptions request) {
    return request.extra[extraKey] as RetryOptions;
  }

  RetryOptions copyWith({
    int? retries,
    Duration? retryInterval,
  }) =>
      RetryOptions(
        retries: retries ?? this.retries,
        retryInterval: retryInterval ?? this.retryInterval,
      );

  Map<String, dynamic> toExtra() {
    return {
      extraKey: this,
    };
  }

  Options toOptions() {
    return Options(extra: toExtra());
  }

  Options mergeIn(Options options) {
    return Options(
        extra: <String, dynamic>{}
          ..addAll(options.extra ?? {})
          ..addAll(toExtra()));
  }
}

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
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
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
      } on Exception {
        rethrow;
      }
    }

    return super.onError(err, handler);
  }
}
