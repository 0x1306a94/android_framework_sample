

#include <binder/IPCThreadState.h>
#include <binder/IServiceManager.h>

#include "src/kk_http_server_log.h"
#include "src/kk_http_server_service.hpp"

using namespace android;

int main(int argc __unused, char **argv __unused) {
    KK_SERVER_LOGD("start...");

    sp<ProcessState> proc(ProcessState::self());
    sp<IServiceManager> sm = defaultServiceManager();
    KK_SERVER_LOGI("ServiceManager: %p", sm.get());
    KKHTTPServerService::instantiate();
    KK_SERVER_LOGI("ServiceManager: %p done instantiate", sm.get());
    ProcessState::self()->startThreadPool();
    IPCThreadState::self()->joinThreadPool();
    return 0;
}