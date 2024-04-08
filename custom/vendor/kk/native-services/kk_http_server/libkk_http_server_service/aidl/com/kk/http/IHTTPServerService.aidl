package com.kk.http;

interface IHTTPServerService {
    void start();
    void stop();
    int status();
}