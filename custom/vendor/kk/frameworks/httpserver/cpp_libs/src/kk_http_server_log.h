#ifndef __kk_http_server_log_h__
#define __kk_http_server_log_h__

#include <android/log.h>

#define KK_SERVER_LOG_TAG "KKHTTPServer"
#define KK_SERVER_LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, KK_SERVER_LOG_TAG, __VA_ARGS__)
#define KK_SERVER_LOGE(...) __android_log_print(ANDROID_LOG_ERROR, KK_SERVER_LOG_TAG, __VA_ARGS__)
#define KK_SERVER_LOGI(...) __android_log_print(ANDROID_LOG_INFO, KK_SERVER_LOG_TAG, __VA_ARGS__)
#define KK_SERVER_LOGW(...) __android_log_print(ANDROID_LOG_WARN, KK_SERVER_LOG_TAG, __VA_ARGS__)
#define KK_SERVER_LOGF(...) __android_log_print(ANDROID_LOG_FATAL, KK_SERVER_LOG_TAG, __VA_ARGS__)

#endif /* __kk_http_server_log_h__ */