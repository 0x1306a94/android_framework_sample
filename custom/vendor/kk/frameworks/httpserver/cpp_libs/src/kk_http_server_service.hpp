#ifndef __kk_http_server_service_hpp__
#define __kk_http_server_service_hpp__

#include <com/kk/http/BnHTTPServerService.h>

#include <binder/BinderService.h>

#include <atomic>
#include <memory>
#include <thread>

namespace hv {
class HttpServer;
struct HttpService;
};  // namespace hv

namespace android {
class KKHTTPServerService : public BinderService<KKHTTPServerService>,
                                   public virtual ::com::kk::http::BnHTTPServerService,
                                   public virtual IBinder::DeathRecipient {
  public:
    // Implementation of BinderService<T>
    static char const *getServiceName();

    // IBinder::DeathRecipient implementation
    virtual void binderDied(const wp<IBinder> &who);

    KKHTTPServerService();
    ~KKHTTPServerService();

    virtual binder::Status start();
    virtual binder::Status stop();
    virtual binder::Status status(int32_t *_aidl_return);

  private:
    void setupRouter();
    void startServer();
    void stopServer();

  private:
    std::unique_ptr<hv::HttpServer> m_server;
    std::unique_ptr<hv::HttpService> m_router;
    std::shared_ptr<std::thread> m_thread;
    std::atomic<bool> m_runing{false};
};
};  // namespace android
#endif /* __kk_http_server_service_hpp__ */