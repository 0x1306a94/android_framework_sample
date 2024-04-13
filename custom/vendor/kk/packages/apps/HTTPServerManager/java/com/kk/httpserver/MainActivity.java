package com.kk.httpserver;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.kk.api.http.HTTPServerManager;

public class MainActivity extends Activity implements View.OnClickListener {
    private static final String TAG = "HTTPServerManagerApp";
    private Button start_btn, stop_btn, status_btn;
    private TextView textView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.v(TAG, "onCreate ");

        setContentView(R.layout.activity_main);
        start_btn = findViewById(R.id.bt_start_server);
        stop_btn = findViewById(R.id.bt_stop_server);
        status_btn = findViewById(R.id.bt_status_server);
        start_btn.setOnClickListener(this);
        stop_btn.setOnClickListener(this);
        status_btn.setOnClickListener(this);

        textView = findViewById(R.id.txt_server_status);
    }

    @Override
    public void onClick(View view) {
        HTTPServerManager mgr = HTTPServerManager.getInstance();
        if (view == start_btn) {
            Log.v(TAG, "click start server ");
            mgr.start();
        } else if (view == stop_btn) {
            Log.v(TAG, "click stop server ");
            mgr.stop();
        } else if (view == status_btn) {
            Log.v(TAG, "click status server ");
            int ret = mgr.status();
            Log.v(TAG, "status " + ret);
            textView.setText("Current Status: " + ret);
        }
    }
}