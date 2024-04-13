package com.kk.http.api;

import android.os.RemoteException;
import android.os.IBinder;
import android.os.ServiceManager;

import com.kk.http.IHTTPServerService;

/**
 * @hide
 */
public class HTTPServerManager {
    private static HTTPServerManager mInstance = null;
    private static String SERVICE_NAME = "com.kk.http.server";

    public static HTTPServerManager getInstance() {
        synchronized (HTTPServerManager.class) {
            if (null == mInstance) {
                try {
                    IBinder b = ServiceManager.getServiceOrThrow(HTTPServerManager.SERVICE_NAME);
                    mInstance = new HTTPServerManager(IHTTPServerService.Stub.asInterface(b));
                } catch (ServiceManager.ServiceNotFoundException e) {
                    throw new IllegalStateException(e);
                }
            }
            return mInstance;
        }
    }

    private IHTTPServerService mService = null;

    private HTTPServerManager(IHTTPServerService service) {
        mService = service;
    }

    public void start() {
        try {
            mService.start();
        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }

    public void stop() {
        try {
            mService.stop();
        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }

    public int status() {
        int ret = -1;
        try {
            ret = mService.status();
        } catch (RemoteException e) {
            e.printStackTrace();
        }
        return ret;
    }
}