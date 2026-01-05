import serial
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from collections import deque
from scipy.signal import savgol_filter
import threading
import sys
import time

# --- CẤU HÌNH ---
COM_PORT = 'COM4'       # <--- SỬA LẠI CỔNG COM CỦA BẠN
BAUD_RATE = 115200      
SAMPLE_RATE = 125       
WINDOW_SIZE = 1000      # 8 giây

# Biến lưu trữ dữ liệu
current_data = {'hr': 0, 'spo2': 0, 'temp': 0.0}
is_running = True

# Bộ đệm ECG
ecg_buffer = deque([2048]*WINDOW_SIZE, maxlen=WINDOW_SIZE)
data_lock = threading.Lock()

# Hàm làm mượt (Smoothing) cho hiển thị đẹp
def smooth_signal(data):
    if len(data) < 21: return data
    try: return savgol_filter(data, 11, 3)
    except: return data

def read_serial():
    global is_running
    try:
        ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=1)
        time.sleep(2)
        print(f"✅ Đã kết nối {COM_PORT} - Đang nhận dữ liệu...")
        
        while is_running:
            try:
                line = ser.readline().decode('utf-8', errors='ignore').strip()
                
                # Định dạng E:giá_trị (ECG)
                if line.startswith("E:"):
                    val = int(line.split(":")[1])
                    with data_lock:
                        ecg_buffer.append(val)
                
                # Định dạng V:temp,spo2,hr (Vitals)
                elif line.startswith("V:"):
                    parts = line.split(":")[1].split(",")
                    if len(parts) == 3:
                        current_data['temp'] = float(parts[0])
                        current_data['spo2'] = int(parts[1])
                        current_data['hr'] = int(parts[2])
                        print(f"📡 Vitals: {current_data}") # In ra để debug
                        
            except: pass
    except Exception as e:
        print(f"❌ Lỗi Serial: {e}")
        is_running = False

t = threading.Thread(target=read_serial)
t.daemon = True
t.start()

# --- GIAO DIỆN ---
plt.style.use('dark_background')
fig, ax = plt.subplots(figsize=(12, 7))
fig.canvas.manager.set_window_title('Medical AI Monitor Pro')

x = np.arange(WINDOW_SIZE) / SAMPLE_RATE
line, = ax.plot(x, [0]*WINDOW_SIZE, color='#00E676', lw=1.5)

ax.set_ylim(-600, 600)
ax.set_title("HỆ THỐNG GIÁM SÁT SINH HIỆU (REAL-TIME)", fontsize=16, color='white', pad=20)
ax.grid(True, alpha=0.15)
ax.set_ylabel("ECG (mV)")
ax.set_xlabel("Thời gian (giây)")

# Các ô hiển thị chỉ số
props = dict(boxstyle='round', facecolor='#263238', alpha=0.9, edgecolor='gray')
txt_hr = ax.text(0.1, 0.92, "HR: --", transform=ax.transAxes, fontsize=14, color='#FF5252', bbox=props)
txt_spo2 = ax.text(0.4, 0.92, "SpO2: --", transform=ax.transAxes, fontsize=14, color='#40C4FF', bbox=props)
txt_temp = ax.text(0.7, 0.92, "Temp: --", transform=ax.transAxes, fontsize=14, color='#FFEA00', bbox=props)

def update(frame):
    if not is_running: return line,
    
    # Cập nhật số liệu
    txt_hr.set_text(f"HR: {current_data['hr']} BPM")
    txt_spo2.set_text(f"SpO2: {current_data['spo2']} %")
    txt_temp.set_text(f"Temp: {current_data['temp']:.1f} °C")
    
    # Cập nhật sóng
    with data_lock:
        raw = np.array(ecg_buffer)
    
    if len(raw) > 0:
        # Làm mượt và căn giữa (Zero-centering)
        clean = smooth_signal(raw)
        line.set_ydata(clean - np.mean(clean))
        
    return line, txt_hr, txt_spo2, txt_temp

# 30 FPS để mượt mà
ani = FuncAnimation(fig, update, interval=33, blit=True)
plt.show()
is_running = False