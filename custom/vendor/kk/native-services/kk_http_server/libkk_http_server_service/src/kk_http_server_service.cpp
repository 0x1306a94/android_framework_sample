#include "kk_http_server_service.hpp"

#include "kk_http_server_log.h"

#include <hv/HttpServer.h>
#include <hv/hlog.h>

// #include <chrono>

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
    KK_SERVER_LOGD("destory %p", this);
}

char const *KKHTTPServerService::getServiceName() {
    return "com.kk.http.server";
}

void KKHTTPServerService::binderDied(const wp<IBinder> &who) {
    KK_SERVER_LOGE("%s: Java client's binder died, removing it from the list of active clients， who=%p",
                     __FUNCTION__, &who);
}

binder::Status KKHTTPServerService::start() {
    KK_SERVER_LOGD("start");
    startServer();
    return binder::Status::ok();
}

binder::Status KKHTTPServerService::stop() {
    KK_SERVER_LOGD("stop");
    stopServer();
    return binder::Status::ok();
}

binder::Status KKHTTPServerService::status(int32_t *_aidl_return) {
    KK_SERVER_LOGD("status");
    if (m_runing) {
        *_aidl_return = 1;
    } else {
        *_aidl_return = 0;
    }
    return binder::Status::ok();
}

void KKHTTPServerService::setupRouter() {
    m_router->GET("/ping", [](HttpRequest *req, HttpResponse *resp) {
        return resp->String("pong");
    });

    m_router->GET("/data", [](HttpRequest *req, HttpResponse *resp) {
        static char data[] = "0123456789";
        return resp->Data(data, 10);
    });

    m_router->GET("/get", [](HttpRequest *req, HttpResponse *resp) {
        resp->json["origin"] = req->client_addr.ip;
        resp->json["url"] = req->url;
        resp->json["args"] = req->query_params;
        resp->json["headers"] = req->headers;
        return 200;
    });

    m_router->POST("/echo", [](const HttpContextPtr &ctx) {
        return ctx->send(ctx->body(), ctx->type());
    });

    m_router->GET("/paths", [&](HttpRequest *req, HttpResponse *resp) {
        return resp->Json(this->m_router->Paths());
    });
}

void KKHTTPServerService::startServer() {
    if (m_thread || m_runing) {
        return;
    }

    hlog_set_handler(libhv_log_handler);

    m_server->registerHttpService(m_router.get());
    m_server->setPort(8888);
    m_server->setThreadNum(4);
    m_thread = std::make_shared<std::thread>([&] {
        // KK_SERVER_LOGD("sleep 10s");
        // std::this_thread::sleep_for(std::chrono::seconds(10));
        KK_SERVER_LOGD("start server");
        this->m_runing = true;
        int code = this->m_server->run();
        KK_SERVER_LOGD("stop server %d", code);
        this->m_runing = false;

        this->m_thread.reset();
    });
    m_thread->detach();
}

void KKHTTPServerService::stopServer() {
    if (!m_thread || !m_runing) {
        return;
    }
    m_server->stop();
    if (m_thread->joinable()) {
        m_thread->join();
    }
    m_thread.reset();
}

};  // namespace android