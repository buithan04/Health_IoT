#ifndef WEB_INTERFACE_H
#define WEB_INTERFACE_H

#include <Arduino.h>

const char html_page[] PROGMEM = R"=====(
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>Cấu Hình Thiết Bị Y Tế IoT</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #009688;       /* Teal Y tế */
            --primary-dark: #00796b;
            --accent: #FF5252;        /* Màu đỏ cho cảnh báo/nhịp tim */
            --bg: #F4F7F6;
            --card: #FFFFFF;
            --text: #37474F;
            --text-light: #90A4AE;
            --border-radius: 16px;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Roboto', sans-serif; }
        
        body {
            background-color: var(--bg);
            color: var(--text);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            background: var(--card);
            width: 100%;
            max-width: 420px;
            padding: 40px 30px;
            border-radius: var(--border-radius);
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
            text-align: center;
            border-top: 5px solid var(--primary);
        }

        /* Header Area */
        .header { margin-bottom: 30px; }
        .icon-heart {
            font-size: 40px; color: var(--accent);
            animation: heartbeat 1.5s infinite;
            display: inline-block; margin-bottom: 10px;
        }
        @keyframes heartbeat {
            0% { transform: scale(1); }
            15% { transform: scale(1.3); }
            30% { transform: scale(1); }
            45% { transform: scale(1.15); }
            60% { transform: scale(1); }
        }
        h2 { color: var(--primary); font-weight: 700; text-transform: uppercase; letter-spacing: 1px; font-size: 22px; }
        p.subtitle { color: var(--text-light); font-size: 14px; margin-top: 5px; }

        /* Form Elements */
        .form-group { margin-bottom: 20px; text-align: left; }
        label { display: block; margin-bottom: 8px; font-weight: 500; font-size: 14px; color: var(--text); }
        
        select, input {
            width: 100%; padding: 14px 16px;
            border: 2px solid #ECEFF1;
            border-radius: 10px;
            font-size: 15px;
            color: #455A64;
            background: #FAFAFA;
            transition: all 0.3s ease;
            outline: none;
        }
        select:focus, input:focus { border-color: var(--primary); background: #fff; box-shadow: 0 0 0 4px rgba(0, 150, 136, 0.1); }
        
        /* Buttons */
        .btn-group { display: flex; gap: 10px; margin-top: 30px; }
        button {
            flex: 1; padding: 14px; border: none; border-radius: 10px;
            font-size: 15px; font-weight: 600; cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            display: flex; justify-content: center; align-items: center; gap: 8px;
        }
        .btn-save { background: var(--primary); color: white; box-shadow: 0 4px 10px rgba(0, 150, 136, 0.3); }
        .btn-save:hover { background: var(--primary-dark); transform: translateY(-2px); }
        .btn-scan { background: #E0F2F1; color: var(--primary-dark); }
        .btn-scan:hover { background: #B2DFDB; }

        /* Loader & Messages */
        .loader {
            border: 3px solid #f3f3f3; border-top: 3px solid var(--primary);
            border-radius: 50%; width: 18px; height: 18px;
            animation: spin 1s linear infinite; display: none;
        }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }

        #msg-box { margin-top: 20px; padding: 15px; border-radius: 10px; display: none; font-size: 14px; line-height: 1.5; }
        .msg-success { background: #E8F5E9; color: #2E7D32; border: 1px solid #C8E6C9; }
        .msg-error { background: #FFEBEE; color: #C62828; border: 1px solid #FFCDD2; }
        .msg-info { background: #E3F2FD; color: #1565C0; border: 1px solid #BBDEFB; }

        .footer { margin-top: 30px; font-size: 12px; color: #B0BEC5; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="icon-heart">♥</div>
            <h2>Medical IoT Setup</h2>
            <p class="subtitle">Kết nối thiết bị với hệ thống giám sát</p>
        </div>
        
        <div class="form-group">
            <label>Mạng WiFi <span id="wifi-count" style="font-weight:normal; color:#90A4AE; font-size:12px;"></span> <div class="loader" id="scan-loader"></div></label>
            <select id="ssid" onchange="checkSecurity()">
                <option disabled selected>Đang khởi tạo...</option>
            </select>
        </div>
        
        <div class="form-group">
            <label>Mật Khẩu WiFi</label>
            <input type="password" id="pass" placeholder="Nhập mật khẩu...">
        </div>
        
        <div class="form-group">
            <label>MQTT Broker (Server)</label>
            <input type="text" id="mqtt" value="7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud">
        </div>

        <div class="btn-group">
            <button class="btn-scan" onclick="scanWifi()">Quét Lại</button>
            <button class="btn-save" onclick="saveConfig()">
                Lưu Cấu Hình <div class="loader" id="save-loader"></div>
            </button>
        </div>
        
        <div id="msg-box"></div>
        <div class="footer">Smart Health Device v3.1</div>
    </div>

    <script>
        window.onload = function() {
            setTimeout(scanWifi, 500); // Đợi 0.5s cho ổn định rồi quét
        };

        function showMsg(text, type) {
            var box = document.getElementById('msg-box');
            box.style.display = 'block';
            box.className = type;
            box.innerHTML = text;
        }

        function scanWifi() {
            var sel = document.getElementById('ssid');
            var ld = document.getElementById('scan-loader');
            var countLabel = document.getElementById('wifi-count');
            
            ld.style.display = 'inline-block';
            sel.innerHTML = "<option>Đang quét...</option>";
            sel.disabled = true;
            
            fetch('/scan').then(res => res.json()).then(data => {
                ld.style.display = 'none';
                sel.disabled = false;
                sel.innerHTML = "";
                
                if(data.length === 0) {
                    sel.add(new Option("Không tìm thấy WiFi nào", ""));
                    return;
                }

                countLabel.innerText = `(Tìm thấy ${data.length} mạng)`;
                sel.add(new Option("-- Chọn mạng WiFi --", ""));

                let unique = [];
                let seen = new Set();
                data.forEach(item => {
                    if(!seen.has(item.ssid)){
                        unique.push(item);
                        seen.add(item.ssid);
                    }
                });

                unique.forEach(item => {
                    let securityIcon = item.secure === 'open' ? '🔓' : '🔒';
                    let bars = item.rssi > -60 ? 'llll' : (item.rssi > -70 ? 'lll' : (item.rssi > -80 ? 'll' : 'l'));
                    
                    let text = `${item.ssid} ${securityIcon} [${bars}]`;
                    let opt = new Option(text, item.ssid);
                    opt.setAttribute('data-sec', item.secure);
                    sel.add(opt);
                });
            }).catch(() => {
                ld.style.display = 'none';
                sel.disabled = false;
                sel.innerHTML = "<option>Lỗi khi quét</option>";
                showMsg("Không thể quét WiFi. Vui lòng thử lại.", "msg-error");
            });
        }

        function checkSecurity() {
            var sel = document.getElementById('ssid');
            var passInput = document.getElementById('pass');
            if(sel.selectedIndex < 0) return;

            var selectedOpt = sel.options[sel.selectedIndex];
            var isOpen = selectedOpt.getAttribute('data-sec') === 'open';

            if(isOpen) {
                passInput.value = "";
                passInput.placeholder = "Mạng mở (Không cần mật khẩu)";
                passInput.disabled = true;
                passInput.style.backgroundColor = "#E0E0E0";
            } else {
                passInput.placeholder = "Nhập mật khẩu WiFi...";
                passInput.disabled = false;
                passInput.style.backgroundColor = "#FAFAFA";
                passInput.focus();
            }
        }

        function saveConfig() {
            var ssid = document.getElementById('ssid').value;
            var pass = document.getElementById('pass').value;
            var mqtt = document.getElementById('mqtt').value;
            var ld = document.getElementById('save-loader');
            
            if(!ssid || ssid.includes("Chọn mạng") || ssid.includes("Đang quét")) {
                showMsg("Vui lòng chọn một mạng WiFi từ danh sách!", "msg-error");
                return;
            }

            ld.style.display = 'inline-block';
            showMsg("Đang kiểm tra kết nối...<br>Vui lòng đợi khoảng 10-15 giây.", "msg-info");
            
            fetch(`/save?ssid=${encodeURIComponent(ssid)}&pass=${encodeURIComponent(pass)}&mqtt=${encodeURIComponent(mqtt)}`)
            .then(res => res.text())
            .then(text => {
                ld.style.display = 'none';
                if(text.includes("OK")) {
                    showMsg("✅ <b>Kết nối thành công!</b><br>Đang lưu cấu hình và khởi động lại...", "msg-success");
                    document.querySelector('.btn-save').disabled = true;
                } else {
                    showMsg("❌ <b>Kết nối thất bại!</b><br>" + text, "msg-error");
                }
            })
            .catch(err => {
                ld.style.display = 'none';
                showMsg("⚠️ Lỗi đường truyền tới ESP32!", "msg-error");
            });
        }
    </script>
</body>
</html>
)=====";

#endif
