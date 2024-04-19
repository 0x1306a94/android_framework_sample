#include "kk_http_server_service.hpp"
#include "kk_http_properties.h"

#include <android-base/properties.h>
#include <cutils/properties.h>

#include <hv/HttpServer.h>
#include <hv/hlog.h>

#include "kk_http_server_log.h"

// #include <chrono>
#include <mutex>

static std::mutex g_mutex;

namespace android {
void libhv_log_handler(int loglevel, const char *buf, int len) {
    if (len == 0) {
        return;
    }
    switch (loglevel) {
        case LOG_LEVEL_DEBUG: {
            KK_SERVER_LOGD("%s", buf);
            break;
        }
        case LOG_LEVEL_INFO: {
            KK_SERVER_LOGI("%s", buf);
            break;
        }
        case LOG_LEVEL_WARN: {
            KK_SERVER_LOGW("%s", buf);
            break;
        }
        case LOG_LEVEL_ERROR: {
            KK_SERVER_LOGE("%s", buf);
            break;
        }
        case LOG_LEVEL_FATAL: {
            KK_SERVER_LOGF("%s", buf);
            break;
        }
    }
}
KKHTTPServerService::KKHTTPServerService()
    : m_server(std::make_unique<hv::HttpServer>())
    , m_router(std::make_unique<hv::HttpService>())
    , m_thread(nullptr) {
    KK_SERVER_LOGD("create %p", this);
    setupRouter();
    startServer();
}

KKHTTPServerService::~KKHTTPServerService() {
    std::lock_guard<std::mutex> lock(g_mutex);
    stopServer();
    KK_SERVER_LOGD("destory %p", this);
}

char const *KKHTTPServerService::getServiceName() { return "com.kk.http.server"; }

void KKHTTPServerService::binderDied(const wp<IBinder> &who) {
    KK_SERVER_LOGE("%s: Java client's binder died, removing it from the list of active clients， who=%p", __FUNCTION__,
                   &who);
}

binder::Status KKHTTPServerService::start() {
    std::lock_guard<std::mutex> lock(g_mutex);
    KK_SERVER_LOGD("binder call start");
    startServer();
    return binder::Status::ok();
}

binder::Status KKHTTPServerService::stop() {
    std::lock_guard<std::mutex> lock(g_mutex);
    KK_SERVER_LOGD("binder call stop");
    stopServer();
    return binder::Status::ok();
}

binder::Status KKHTTPServerService::status(int32_t *_aidl_return) {
    std::lock_guard<std::mutex> lock(g_mutex);
    KK_SERVER_LOGD("binder call status");
    if (m_runing) {
        *_aidl_return = 1;
    } else {
        *_aidl_return = 0;
    }
    return binder::Status::ok();
}

#define KKHTTP_DEFAULT_WEB_ROOT "/data/kkhttpserver/www/html"
void KKHTTPServerService::setupRouter() {
    std::string pro_doc_root = base::GetProperty(KKHTTP_PROPERTY_WEB_ROOT, "");
    if (pro_doc_root.empty()) {
        pro_doc_root = base::GetProperty(KKHTTP_PROPERTY_PERSIST_WEB_ROOT, KKHTTP_DEFAULT_WEB_ROOT);
    }

    KK_SERVER_LOGI("document_root: %s", pro_doc_root.c_str());
    m_router->document_root = pro_doc_root;
    m_router->GET("/api/ping", [](HttpRequest *req, HttpResponse *resp) { return resp->String("pong"); });

    m_router->GET("/api/data", [](HttpRequest *req, HttpResponse *resp) {
        static char data[] = "0123456789";
        return resp->Data(data, 10);
    });

    m_router->GET("/api/get", [](HttpRequest *req, HttpResponse *resp) {
        resp->json["origin"] = req->client_addr.ip;
        resp->json["url"] = req->url;
        resp->json["args"] = req->query_params;
        resp->json["headers"] = req->headers;
        return 200;
    });

    m_router->POST("/api/echo", [](const HttpContextPtr &ctx) { return ctx->send(ctx->body(), ctx->type()); });

    m_router->GET("/api/paths", [&](HttpRequest *req, HttpResponse *resp) { return resp->Json(this->m_router->Paths()); });
}

void KKHTTPServerService::startServer() {
    if (m_thread || m_runing) {
        return;
    }

    KK_SERVER_LOGD("start server ...");
    hlog_set_handler(libhv_log_handler);

    std::string pro_port = base::GetProperty(KKHTTP_PROPERTY_PORT, "");
    if (pro_port.empty()) {
        pro_port = base::GetProperty(KKHTTP_PROPERTY_PERSIST_PORT, "8087");
    }

    m_server->registerHttpService(m_router.get());
    m_server->setPort(std::atoi(pro_port.c_str()));
    m_server->setThreadNum(4);
    m_thread = std::make_unique<std::thread>([this, pro_port] {
        // KK_SERVER_LOGD("sleep 10s");
        // std::this_thread::sleep_for(std::chrono::seconds(10));
        KK_SERVER_LOGD("start server port: %s", pro_port.c_str());
        this->m_runing = true;
        int code = this->m_server->run();
        KK_SERVER_LOGD("stop server port: %s code: %d", pro_port.c_str(), code);
        this->m_runing = false;
    });
}

void KKHTTPServerService::stopServer() {
    if (!m_runing) {
        return;
    }
    m_server->stop();
    if (m_thread) {
        KK_SERVER_LOGD("thread join ....");
        m_thread->join();
    }
    m_thread.reset();
    KK_SERVER_LOGD("stop finish");
}

};  // namespace android