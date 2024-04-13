package com.kk.api.http;

import android.os.RemoteException;
import android.os.IBinder;
import android.os.ServiceManager;
import android.util.Log;

import com.kk.http.IHTTPServerService;

public class HTTPServerManager {
    private static HTTPServerManager mInstance = null;
    private static String SERVICE_NAME = "com.kk.http.server";
    private static final String TAG = "HTTPServerManagerApp";

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
            Log.e(TAG, Log.getStackTraceString(e));
        }
    }

    public void stop() {
        try {
            mService.stop();
        } catch (RemoteException e) {
            Log.e(TAG, Log.getStackTraceString(e));
        }
    }

    public int status() {
        int ret = -1;
        try {
            ret = mService.status();
        } catch (RemoteException e) {
            Log.e(TAG, Log.getStackTraceString(e));
        }
        return ret;
    }
}