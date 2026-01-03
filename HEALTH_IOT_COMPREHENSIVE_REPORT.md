# ðŸ“Š BÃO CÃO Dá»° ÃN HEALTH IoT - Há»† THá»NG QUáº¢N LÃ Sá»¨C KHá»ŽE THÃ”NG MINH

> **Comprehensive Technical Documentation & Project Report**  
> Version: 1.0  
> Date: January 3, 2026  
> Author: BÃ¹i Duy ThÃ¢n

---

## ðŸ“‘ Má»¤C Lá»¤C

1. [Tá»•ng Quan Dá»± Ãn](#1-tá»•ng-quan-dá»±-Ã¡n)
2. [Kiáº¿n TrÃºc Há»‡ Thá»‘ng](#2-kiáº¿n-trÃºc-há»‡-thá»‘ng)
3. [CÃ´ng Nghá»‡ Sá»­ Dá»¥ng](#3-cÃ´ng-nghá»‡-sá»­-dá»¥ng)
4. [Database Schema](#4-database-schema)
5. [TÃ­nh NÄƒng Chi Tiáº¿t](#5-tÃ­nh-nÄƒng-chi-tiáº¿t)
6. [AI & Machine Learning](#6-ai--machine-learning)
7. [API Documentation](#7-api-documentation)
8. [Luá»“ng Hoáº¡t Äá»™ng](#8-luá»“ng-hoáº¡t-Ä‘á»™ng)
9. [Security & Performance](#9-security--performance)
10. [Screenshots & Demo](#10-screenshots--demo)

---

## 1. Tá»”NG QUAN Dá»° ÃN

### 1.1. Giá»›i Thiá»‡u

**Health IoT** lÃ  má»™t há»‡ thá»‘ng quáº£n lÃ½ sá»©c khá»e toÃ n diá»‡n, káº¿t há»£p cÃ´ng nghá»‡ IoT, AI/Machine Learning vÃ  telemedicine Ä‘á»ƒ mang Ä‘áº¿n tráº£i nghiá»‡m chÄƒm sÃ³c sá»©c khá»e hiá»‡n Ä‘áº¡i.

### 1.2. Má»¥c TiÃªu

- âœ… **Káº¿t ná»‘i bá»‡nh nhÃ¢n - bÃ¡c sÄ©** qua video/audio call real-time
- âœ… **GiÃ¡m sÃ¡t sá»©c khá»e tá»« xa** thÃ´ng qua thiáº¿t bá»‹ IoT
- âœ… **Dá»± Ä‘oÃ¡n nguy cÆ¡ bá»‡nh** báº±ng AI/ML
- âœ… **Quáº£n lÃ½ há»“ sÆ¡ sá»©c khá»e Ä‘iá»‡n tá»­** (EHR)
- âœ… **TÆ° váº¥n y táº¿ online** vÃ  kÃª Ä‘Æ¡n Ä‘iá»‡n tá»­

### 1.3. CÃ¡c ThÃ nh Pháº§n ChÃ­nh

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                     HEALTH IoT ECOSYSTEM                     â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                               â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”      â”‚
â”‚  â”‚   Mobile     â”‚  â”‚   Admin      â”‚  â”‚   IoT        â”‚      â”‚
â”‚  â”‚   App        â”‚  â”‚   Portal     â”‚  â”‚   Devices    â”‚      â”‚
â”‚  â”‚  (Flutter)   â”‚  â”‚  (Next.js)   â”‚  â”‚   (MQTT)     â”‚      â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜      â”‚
â”‚         â”‚                  â”‚                  â”‚               â”‚
â”‚         â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜               â”‚
â”‚                            â–¼                                  â”‚
â”‚                  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                     â”‚
â”‚                  â”‚   Backend API       â”‚                     â”‚
â”‚                  â”‚   (Node.js)         â”‚                     â”‚
â”‚                  â”‚   + Socket.IO       â”‚                     â”‚
â”‚                  â”‚   + AI/ML Engine    â”‚                     â”‚
â”‚                  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                     â”‚
â”‚                             â”‚                                 â”‚
â”‚                             â–¼                                 â”‚
â”‚                  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                     â”‚
â”‚                  â”‚   PostgreSQL        â”‚                     â”‚
â”‚                  â”‚   Database          â”‚                     â”‚
â”‚                  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 1.4. Äá»‘i TÆ°á»£ng Sá»­ Dá»¥ng

1. **Bá»‡nh nhÃ¢n (Patient)**: NgÆ°á»i dÃ¹ng cuá»‘i, theo dÃµi sá»©c khá»e
2. **BÃ¡c sÄ© (Doctor)**: ChuyÃªn gia y táº¿, tÆ° váº¥n vÃ  Ä‘iá»u trá»‹
3. **Admin**: Quáº£n trá»‹ viÃªn há»‡ thá»‘ng

---

## 2. KIáº¾N TRÃšC Há»† THá»NG

### 2.1. Kiáº¿n TrÃºc Tá»•ng Quan (High-Level Architecture)

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                        CLIENT TIER                               â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                                   â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”‚
â”‚  â”‚  Mobile App     â”‚  â”‚  Admin Portal   â”‚  â”‚  IoT Devices    â”‚ â”‚
â”‚  â”‚  (Flutter)      â”‚  â”‚  (Next.js)      â”‚  â”‚  (ESP32/etc)    â”‚ â”‚
â”‚  â”‚                 â”‚  â”‚                 â”‚  â”‚                 â”‚ â”‚
â”‚  â”‚  â€¢ Patient UI   â”‚  â”‚  â€¢ Dashboard    â”‚  â”‚  â€¢ Heart Rate   â”‚ â”‚
â”‚  â”‚  â€¢ Doctor UI    â”‚  â”‚  â€¢ User Mgmt    â”‚  â”‚  â€¢ Blood Press  â”‚ â”‚
â”‚  â”‚  â€¢ Video Call   â”‚  â”‚  â€¢ Analytics    â”‚  â”‚  â€¢ SpO2         â”‚ â”‚
â”‚  â”‚  â€¢ Chat         â”‚  â”‚  â€¢ Reports      â”‚  â”‚  â€¢ Temperature  â”‚ â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â”‚
â”‚           â”‚                     â”‚                     â”‚           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
            â”‚                     â”‚                     â”‚
            â”‚        HTTPS        â”‚        HTTPS        â”‚   MQTTS
            â”‚                     â”‚                     â”‚
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                        APPLICATION TIER                            â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                                     â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚              Node.js Express Server (Port 5000)             â”‚  â”‚
â”‚  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤  â”‚
â”‚  â”‚                                                              â”‚  â”‚
â”‚  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚  â”‚
â”‚  â”‚  â”‚   RESTful    â”‚  â”‚  Socket.IO   â”‚  â”‚  MQTT Broker â”‚    â”‚  â”‚
â”‚  â”‚  â”‚     API      â”‚  â”‚  Real-time   â”‚  â”‚   HiveMQ     â”‚    â”‚  â”‚
â”‚  â”‚  â”‚              â”‚  â”‚              â”‚  â”‚              â”‚    â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ Auth      â”‚  â”‚  â€¢ Chat      â”‚  â”‚  â€¢ Subscribe â”‚    â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ Users     â”‚  â”‚  â€¢ Call      â”‚  â”‚  â€¢ Publish   â”‚    â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ Doctors   â”‚  â”‚  â€¢ Notif     â”‚  â”‚  â€¢ Health    â”‚    â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ Appt      â”‚  â”‚              â”‚  â”‚    Data      â”‚    â”‚  â”‚
â”‚  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚  â”‚
â”‚  â”‚                                                              â”‚  â”‚
â”‚  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚  â”‚
â”‚  â”‚  â”‚           Business Logic & Services                   â”‚  â”‚  â”‚
â”‚  â”‚  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤  â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ User Service        â€¢ Appointment Service         â”‚  â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ Doctor Service      â€¢ Prescription Service        â”‚  â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ Chat Service        â€¢ Email Service               â”‚  â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ Call History        â€¢ FCM Service                 â”‚  â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ AI/ML Service       â€¢ Health Analysis            â”‚  â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ MQTT Service        â€¢ Notification Service        â”‚  â”‚  â”‚
â”‚  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚  â”‚
â”‚  â”‚                                                              â”‚  â”‚
â”‚  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚  â”‚
â”‚  â”‚  â”‚              AI/ML Processing Engine                  â”‚  â”‚  â”‚
â”‚  â”‚  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤  â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ TensorFlow.js Node                                 â”‚  â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ Heart Disease Prediction (MLP Model)              â”‚  â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ ECG Anomaly Detection (CNN Model)                 â”‚  â”‚  â”‚
â”‚  â”‚  â”‚  â€¢ Health Risk Assessment                             â”‚  â”‚  â”‚
â”‚  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚  â”‚
â”‚  â”‚                                                              â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â”‚                             â”‚                                       â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                              â”‚
                              â”‚  SQL Queries
                              â”‚
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                          DATA TIER                                   â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                                       â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚
â”‚  â”‚                PostgreSQL Database (Port 5432)              â”‚    â”‚
â”‚  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤    â”‚
â”‚  â”‚                                                              â”‚    â”‚
â”‚  â”‚  Tables:                                                     â”‚    â”‚
â”‚  â”‚  â€¢ users                    â€¢ health_metrics                â”‚    â”‚
â”‚  â”‚  â€¢ doctors                  â€¢ sensor_packets                â”‚    â”‚
â”‚  â”‚  â€¢ appointments             â€¢ call_history                  â”‚    â”‚
â”‚  â”‚  â€¢ prescriptions            â€¢ notifications                 â”‚    â”‚
â”‚  â”‚  â€¢ conversations            â€¢ health_articles               â”‚    â”‚
â”‚  â”‚  â€¢ messages                 â€¢ medication_reminders          â”‚    â”‚
â”‚  â”‚  â€¢ doctor_schedules         â€¢ reviews                       â”‚    â”‚
â”‚  â”‚                                                              â”‚    â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚
â”‚                                                                       â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    EXTERNAL SERVICES                             â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                                   â”‚
â”‚  â€¢ ZegoCloud (Video/Audio Call)                                 â”‚
â”‚  â€¢ Firebase Cloud Messaging (Push Notifications)                â”‚
â”‚  â€¢ Cloudinary (Image/File Storage)                              â”‚
â”‚  â€¢ SendGrid/Gmail (Email Service)                               â”‚
â”‚  â€¢ HiveMQ Cloud (MQTT Broker)                                   â”‚
â”‚  â€¢ NewsAPI (Health Articles)                                    â”‚
â”‚                                                                   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 2.2. Kiáº¿n TrÃºc Chi Tiáº¿t - Communication Flow

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”         â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”         â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Patient   â”‚         â”‚   Doctor   â”‚         â”‚   Admin    â”‚
â”‚  Mobile    â”‚         â”‚   Mobile   â”‚         â”‚   Portal   â”‚
â””â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜         â””â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜         â””â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜
      â”‚                      â”‚                       â”‚
      â”‚  REST API (HTTPS)    â”‚                       â”‚
      â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
      â”‚                      â”‚                       â”‚
      â–¼                      â–¼                       â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚              Load Balancer (Optional)                    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                          â”‚
                          â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚               Node.js Application Server                 â”‚
â”‚                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”‚
â”‚  â”‚            Middleware Stack                      â”‚   â”‚
â”‚  â”‚  1. CORS                                         â”‚   â”‚
â”‚  â”‚  2. Body Parser                                  â”‚   â”‚
â”‚  â”‚  3. JWT Authentication                           â”‚   â”‚
â”‚  â”‚  4. Rate Limiting                                â”‚   â”‚
â”‚  â”‚  5. Error Handler                                â”‚   â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
â”‚                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚
â”‚  â”‚   Routes    â”‚  â”‚   Socket    â”‚  â”‚    MQTT     â”‚    â”‚
â”‚  â”‚   Handler   â”‚  â”‚   Manager   â”‚  â”‚   Handler   â”‚    â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜    â”‚
â”‚         â”‚                â”‚                â”‚             â”‚
â”‚         â–¼                â–¼                â–¼             â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”     â”‚
â”‚  â”‚         Controllers Layer                     â”‚     â”‚
â”‚  â”‚  â€¢ Auth  â€¢ User  â€¢ Doctor  â€¢ Appointment    â”‚     â”‚
â”‚  â”‚  â€¢ Chat  â€¢ Prescription  â€¢ Health Data      â”‚     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚
â”‚                     â”‚                                   â”‚
â”‚                     â–¼                                   â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”     â”‚
â”‚  â”‚         Services Layer (Business Logic)       â”‚     â”‚
â”‚  â”‚  â€¢ Validation  â€¢ Data Processing              â”‚     â”‚
â”‚  â”‚  â€¢ AI/ML Inference  â€¢ External API Calls     â”‚     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚
â”‚                     â”‚                                   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                      â”‚
                      â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚              PostgreSQL Database                         â”‚
â”‚  â€¢ Connection Pooling                                    â”‚
â”‚  â€¢ Transaction Management                                â”‚
â”‚  â€¢ Query Optimization                                    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## 3. CÃ”NG NGHá»† Sá»¬ Dá»¤NG

### 3.1. Frontend Technologies

#### ðŸŽ¯ Mobile Application (Flutter)

```yaml
Framework: Flutter 3.24.0+
Language: Dart 3.5.0+
State Management: Provider
Architecture: MVVM Pattern

Key Packages:
  - http: ^1.2.0                    # API calls
  - socket_io_client: ^2.0.3        # Real-time communication
  - zego_uikit_prebuilt_call: ^4.18.1  # Video/Audio calls
  - provider: ^6.1.5                # State management
  - go_router: ^14.6.4              # Navigation
  - shared_preferences: ^2.5.4      # Local storage
  - firebase_messaging: ^15.1.5     # Push notifications
  - connectivity_plus: ^6.1.2       # Network status
  - permission_handler: ^11.3.1     # Permissions
  - image_picker: ^1.1.2            # Image selection
  - fl_chart: ^0.70.2               # Charts & graphs
  - intl: ^0.19.0                   # Internationalization
```

**Cáº¥u trÃºc thÆ° má»¥c:**
```
lib/
â”œâ”€â”€ core/
â”‚   â”œâ”€â”€ api/              # API client configuration
â”‚   â””â”€â”€ constants/        # App constants
â”œâ”€â”€ models/               # Data models
â”‚   â”œâ”€â”€ common/          # Shared models (User, Doctor)
â”‚   â”œâ”€â”€ chat/            # Chat models
â”‚   â””â”€â”€ health/          # Health data models
â”œâ”€â”€ presentation/
â”‚   â”œâ”€â”€ patient/         # Patient screens
â”‚   â”œâ”€â”€ doctor/          # Doctor screens
â”‚   â””â”€â”€ shared/          # Shared widgets
â””â”€â”€ service/             # Services
    â”œâ”€â”€ auth_service.dart
    â”œâ”€â”€ socket_service.dart
    â”œâ”€â”€ zego_service.dart
    â”œâ”€â”€ fcm_service.dart
    â””â”€â”€ mqtt_service.dart
```

#### ðŸŽ¨ Admin Portal (Next.js)

```json
Framework: Next.js 14 (App Router)
Language: TypeScript
UI Library: Shadcn/ui + Tailwind CSS
State Management: React Context + Hooks

Dependencies:
  - next: ^14.0.0
  - react: ^18.0.0
  - typescript: ^5.0.0
  - tailwindcss: ^3.4.0
  - shadcn/ui components
  - recharts (Analytics charts)
  - axios (API calls)
```

### 3.2. Backend Technologies

#### âš¡ Server Framework

```javascript
Runtime: Node.js 20.x
Framework: Express.js 4.x
Language: JavaScript (ES6+)

Core Dependencies:
  - express: ^4.18.2              # Web framework
  - socket.io: ^4.6.1             # Real-time communication
  - pg: ^8.11.3                   # PostgreSQL client
  - bcrypt: ^5.1.1                # Password hashing
  - jsonwebtoken: ^9.0.2          # JWT authentication
  - dotenv: ^16.3.1               # Environment variables
  - cors: ^2.8.5                  # CORS middleware
  - helmet: ^7.1.0                # Security headers
  - express-rate-limit: ^7.1.5    # Rate limiting
  - multer: ^1.4.5-lts.1          # File uploads

AI/ML:
  - @tensorflow/tfjs-node: ^4.15.0  # TensorFlow.js
  
IoT:
  - mqtt: ^5.3.4                  # MQTT protocol
  
External Services:
  - cloudinary: ^1.41.1           # Image storage
  - nodemailer: ^6.9.7            # Email service
  - firebase-admin: ^12.0.0       # FCM push notifications
  - axios: ^1.6.2                 # HTTP client
```

**Cáº¥u trÃºc thÆ° má»¥c:**
```
HealthAI_Server/
â”œâ”€â”€ config/
â”‚   â”œâ”€â”€ db.js               # Database connection
â”‚   â”œâ”€â”€ aiModels.js         # AI models loader
â”‚   â”œâ”€â”€ mqtt.js             # MQTT configuration
â”‚   â””â”€â”€ cloudinary.js       # Cloudinary config
â”œâ”€â”€ controllers/            # Request handlers
â”‚   â”œâ”€â”€ auth_controller.js
â”‚   â”œâ”€â”€ user_controller.js
â”‚   â”œâ”€â”€ doctor_controller.js
â”‚   â””â”€â”€ ...
â”œâ”€â”€ services/               # Business logic
â”‚   â”œâ”€â”€ auth_service.js
â”‚   â”œâ”€â”€ predict_service.js
â”‚   â”œâ”€â”€ health_analysis_service.js
â”‚   â””â”€â”€ ...
â”œâ”€â”€ models/                 # AI/ML models
â”‚   â”œâ”€â”€ mlp_model/         # Heart disease prediction
â”‚   â””â”€â”€ ecg_model/         # ECG anomaly detection
â”œâ”€â”€ middleware/
â”‚   â”œâ”€â”€ auth.js            # JWT verification
â”‚   â””â”€â”€ validate.js        # Input validation
â”œâ”€â”€ routes/                # API routes
â”œâ”€â”€ workers/               # Background jobs
â”œâ”€â”€ socket_manager.js      # Socket.IO setup
â””â”€â”€ app.js                 # Entry point
```

### 3.3. Database

#### ðŸ—„ï¸ PostgreSQL 16

```sql
Database Engine: PostgreSQL 16.x
ORM: Raw SQL with pg-pool
Migration: SQL scripts

Key Features:
  - JSONB columns for flexible data
  - Full-text search capabilities
  - Indexing for performance
  - Foreign key constraints
  - Triggers for automation
```

### 3.4. External Services & APIs

| Service | Purpose | Provider |
|---------|---------|----------|
| **ZegoCloud** | Video/Audio Call SDK | ZegoCloud |
| **Firebase** | Push Notifications (FCM) | Google Firebase |
| **Cloudinary** | Image & File Storage | Cloudinary |
| **HiveMQ Cloud** | MQTT Broker for IoT | HiveMQ |
| **SendGrid/Gmail** | Email Service | SendGrid/Google |
| **NewsAPI** | Health Articles | NewsAPI.org |

### 3.5. Development Tools

```yaml
Version Control: Git
Code Editor: Visual Studio Code
API Testing: Postman, Thunder Client
Database Tool: pgAdmin, DBeaver
Debugging: Chrome DevTools, Flutter DevTools
Documentation: Markdown, JSDoc
```

---

## 4. DATABASE SCHEMA

### 4.1. Entity Relationship Diagram (ERD)

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                      HEALTH IoT DATABASE SCHEMA                  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”          â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚     users        â”‚          â”‚    doctors       â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤          â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ PK id            â”‚          â”‚ PK user_id (FK)  â”‚
â”‚    email         â”‚â—„â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤    specialty     â”‚
â”‚    password      â”‚  1    1  â”‚    experience    â”‚
â”‚    full_name     â”‚          â”‚    license_no    â”‚
â”‚    role          â”‚          â”‚    bio           â”‚
â”‚    phone_number  â”‚          â”‚    consultation  â”‚
â”‚    gender        â”‚          â”‚    rating        â”‚
â”‚    date_of_birth â”‚          â”‚    is_verified   â”‚
â”‚    avatar_url    â”‚          â””â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
â”‚    is_verified   â”‚                   â”‚
â”‚    created_at    â”‚                   â”‚ 1
â””â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                   â”‚
         â”‚                             â”‚
         â”‚ 1                           â”‚
         â”‚                             â”‚
         â”‚                             â”‚ *
         â”‚                   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
         â”‚                   â”‚   appointments    â”‚
         â”‚                   â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
         â”‚                   â”‚ PK id             â”‚
         â”‚ *                 â”‚ FK patient_id     â”‚
         â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤ FK doctor_id      â”‚
         â”‚                   â”‚    service_id     â”‚
         â”‚                   â”‚    date           â”‚
         â”‚                   â”‚    time_slot      â”‚
         â”‚                   â”‚    status         â”‚
         â”‚                   â”‚    reason         â”‚
         â”‚                   â”‚    notes          â”‚
         â”‚                   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â”‚                             â”‚
         â”‚                             â”‚ 1
         â”‚                             â”‚
         â”‚                             â”‚ *
         â”‚                   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
         â”‚                   â”‚  prescriptions    â”‚
         â”‚                   â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
         â”‚                   â”‚ PK id             â”‚
         â”‚                   â”‚ FK appointment_id â”‚
         â”‚                   â”‚ FK patient_id     â”‚
         â”‚                   â”‚ FK doctor_id      â”‚
         â”‚ 1                 â”‚    diagnosis      â”‚
         â”‚                   â”‚    medications[]  â”‚
         â”‚                   â”‚    notes          â”‚
         â”‚                   â”‚    created_at     â”‚
         â”‚                   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â”‚
         â”‚ 1
         â”‚
         â”‚ *
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ health_metrics   â”‚          â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤          â”‚ sensor_packets   â”‚
â”‚ PK id            â”‚          â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ FK user_id       â”‚          â”‚ PK id            â”‚
â”‚    metric_type   â”‚â—„â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤ FK user_id       â”‚
â”‚    value         â”‚  1    *  â”‚    packet_id     â”‚
â”‚    unit          â”‚          â”‚    heart_rate    â”‚
â”‚    source        â”‚          â”‚    spo2          â”‚
â”‚    risk_level    â”‚          â”‚    temperature   â”‚
â”‚    alert_message â”‚          â”‚    sys_bp        â”‚
â”‚    recorded_at   â”‚          â”‚    dia_bp        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜          â”‚    timestamp     â”‚
                              â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”          â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  conversations   â”‚          â”‚    messages      â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤          â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ PK id            â”‚ 1     *  â”‚ PK id            â”‚
â”‚ FK user1_id      â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤ FK conversation  â”‚
â”‚ FK user2_id      â”‚          â”‚    sender_id     â”‚
â”‚    last_message  â”‚          â”‚    content       â”‚
â”‚    updated_at    â”‚          â”‚    message_type  â”‚
â”‚    created_at    â”‚          â”‚    status        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜          â”‚    sent_at       â”‚
                              â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  call_history    â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ PK id            â”‚
â”‚    call_id       â”‚
â”‚ FK caller_id     â”‚
â”‚ FK receiver_id   â”‚
â”‚    call_type     â”‚
â”‚    status        â”‚
â”‚    duration      â”‚
â”‚    started_at    â”‚
â”‚    ended_at      â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ notifications    â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ PK id            â”‚
â”‚ FK user_id       â”‚
â”‚    type          â”‚
â”‚    title         â”‚
â”‚    body          â”‚
â”‚    data          â”‚
â”‚    is_read       â”‚
â”‚    created_at    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ health_articles  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ PK id            â”‚
â”‚    title         â”‚
â”‚    description   â”‚
â”‚    content       â”‚
â”‚    image_url     â”‚
â”‚    category      â”‚
â”‚    author        â”‚
â”‚    source_url    â”‚
â”‚    published_at  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 4.2. Core Tables Detail

#### ðŸ‘¤ Table: users

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role VARCHAR(20) NOT NULL,  -- 'patient' | 'doctor'
    phone_number VARCHAR(20),
    gender VARCHAR(10),         -- 'male' | 'female' | 'other'
    date_of_birth DATE,
    birth_year INTEGER,         -- For AI predictions
    address TEXT,
    avatar_url TEXT,
    
    -- Health Info (for patients)
    height DECIMAL(5,2),        -- cm
    weight DECIMAL(5,2),        -- kg
    blood_type VARCHAR(5),
    medical_history TEXT,
    allergies TEXT,
    lifestyle_info TEXT,
    
    -- Administrative
    insurance_number VARCHAR(50),
    emergency_contact_name VARCHAR(255),
    emergency_contact_phone VARCHAR(20),
    occupation VARCHAR(100),
    
    -- System
    is_verified BOOLEAN DEFAULT FALSE,
    fcm_token TEXT,             -- For push notifications
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
```

#### ðŸ‘¨â€âš•ï¸ Table: doctors

```sql
CREATE TABLE doctors (
    user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    specialty VARCHAR(100) NOT NULL,
    experience_years INTEGER,
    license_number VARCHAR(100) UNIQUE,
    education TEXT,
    bio TEXT,
    consultation_fee DECIMAL(10,2),
    average_rating DECIMAL(2,1) DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_doctors_specialty ON doctors(specialty);
CREATE INDEX idx_doctors_rating ON doctors(average_rating DESC);
```

#### ðŸ“… Table: appointments

```sql
CREATE TABLE appointments (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES users(id),
    doctor_id INTEGER NOT NULL REFERENCES users(id),
    service_id INTEGER,
    appointment_date DATE NOT NULL,
    time_slot VARCHAR(20) NOT NULL,  -- e.g., '09:00-09:30'
    status VARCHAR(20) DEFAULT 'pending',
    -- 'pending' | 'confirmed' | 'completed' | 'cancelled' | 'rescheduled'
    reason TEXT,
    notes TEXT,
    symptoms TEXT,
    consultation_type VARCHAR(20) DEFAULT 'online',  -- 'online' | 'in-person'
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
```

#### ðŸ’Š Table: prescriptions

```sql
CREATE TABLE prescriptions (
    id SERIAL PRIMARY KEY,
    appointment_id INTEGER REFERENCES appointments(id),
    patient_id INTEGER NOT NULL REFERENCES users(id),
    doctor_id INTEGER NOT NULL REFERENCES users(id),
    diagnosis TEXT,
    medications JSONB,  -- Array of {name, dosage, frequency, duration, notes}
    -- Example: [{"name": "Paracetamol", "dosage": "500mg", "frequency": "3 times/day"}]
    lab_tests TEXT,
    notes TEXT,
    follow_up_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_prescriptions_patient ON prescriptions(patient_id);
CREATE INDEX idx_prescriptions_doctor ON prescriptions(doctor_id);
```

#### ðŸ“Š Table: health_metrics

```sql
CREATE TABLE health_metrics (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    metric_type VARCHAR(50) NOT NULL,
    -- 'heart_rate' | 'blood_pressure' | 'temperature' | 'spo2' | 
    -- 'blood_glucose' | 'weight' | 'ecg' | 'steps' | 'sleep'
    value DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20),
    systolic INTEGER,           -- For blood pressure
    diastolic INTEGER,          -- For blood pressure
    source VARCHAR(50),         -- 'manual' | 'iot_device' | 'app'
    
    -- AI Analysis Results
    risk_level VARCHAR(20),     -- 'normal' | 'warning' | 'danger' | 'critical'
    risk_score DECIMAL(5,2),    -- 0-100
    alert_message TEXT,
    ai_prediction JSONB,        -- Detailed AI analysis
    
    notes TEXT,
    recorded_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_health_metrics_user ON health_metrics(user_id);
CREATE INDEX idx_health_metrics_type ON health_metrics(metric_type);
CREATE INDEX idx_health_metrics_recorded ON health_metrics(recorded_at DESC);
CREATE INDEX idx_health_metrics_risk ON health_metrics(risk_level);
```

#### ðŸ“¡ Table: sensor_packets (IoT Data)

```sql
CREATE TABLE sensor_packets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    packet_id VARCHAR(100),     -- Unique packet identifier
    device_id VARCHAR(100),
    
    -- Vital Signs
    heart_rate INTEGER,
    spo2 INTEGER,
    temperature DECIMAL(4,1),
    systolic_bp INTEGER,
    diastolic_bp INTEGER,
    
    -- Additional Metrics (optional)
    blood_glucose DECIMAL(5,1),
    ecg_data JSONB,             -- ECG waveform data
    
    -- Metadata
    location JSONB,             -- {lat, lng}
    battery_level INTEGER,
    signal_strength INTEGER,
    
    timestamp TIMESTAMP DEFAULT NOW(),
    received_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sensor_packets_user ON sensor_packets(user_id);
CREATE INDEX idx_sensor_packets_timestamp ON sensor_packets(timestamp DESC);
```

#### ðŸ’¬ Tables: conversations & messages

```sql
CREATE TABLE conversations (
    id SERIAL PRIMARY KEY,
    user1_id INTEGER NOT NULL REFERENCES users(id),
    user2_id INTEGER NOT NULL REFERENCES users(id),
    last_message TEXT,
    last_message_at TIMESTAMP,
    unread_count_user1 INTEGER DEFAULT 0,
    unread_count_user2 INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user1_id, user2_id)
);

CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id INTEGER NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text',
    -- 'text' | 'image' | 'file' | 'voice' | 'system'
    file_url TEXT,
    status VARCHAR(20) DEFAULT 'sent',
    -- 'sent' | 'delivered' | 'seen'
    sent_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_conversations_users ON conversations(user1_id, user2_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_sent_at ON messages(sent_at DESC);
```

#### ðŸ“ž Table: call_history

```sql
CREATE TABLE call_history (
    id SERIAL PRIMARY KEY,
    call_id VARCHAR(100) UNIQUE NOT NULL,
    caller_id INTEGER NOT NULL REFERENCES users(id),
    receiver_id INTEGER NOT NULL REFERENCES users(id),
    call_type VARCHAR(20) NOT NULL,  -- 'audio' | 'video'
    status VARCHAR(20) NOT NULL,
    -- 'calling' | 'ringing' | 'connected' | 'completed' | 'missed' | 'cancelled' | 'rejected'
    duration_seconds INTEGER DEFAULT 0,
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_call_history_caller ON call_history(caller_id);
CREATE INDEX idx_call_history_receiver ON call_history(receiver_id);
CREATE INDEX idx_call_history_started ON call_history(started_at DESC);
```

### 4.3. Database Statistics

```sql
-- Example queries for statistics

-- Total users by role
SELECT role, COUNT(*) as count
FROM users
GROUP BY role;

-- Average consultation fee by specialty
SELECT specialty, AVG(consultation_fee) as avg_fee
FROM doctors
GROUP BY specialty
ORDER BY avg_fee DESC;

-- Appointments this month
SELECT COUNT(*) as total_appointments
FROM appointments
WHERE appointment_date >= DATE_TRUNC('month', CURRENT_DATE);

-- Health metrics summary for a user
SELECT 
    metric_type,
    COUNT(*) as readings,
    AVG(value) as average,
    MIN(value) as minimum,
    MAX(value) as maximum
FROM health_metrics
WHERE user_id = 10
    AND recorded_at >= NOW() - INTERVAL '30 days'
GROUP BY metric_type;
```

---

*(Tiáº¿p tá»¥c trong file tiáº¿p theo...)*
## 5. TÃNH NÄ‚NG CHI TIáº¾T

### 5.1. TÃ­nh NÄƒng Cho Bá»‡nh NhÃ¢n (Patient Features)

#### ðŸ¥ 1. Quáº£n LÃ½ TÃ i Khoáº£n & Há»“ SÆ¡ Sá»©c Khá»e

**ÄÄƒng kÃ½ & ÄÄƒng nháº­p:**
- Email/Password authentication
- JWT token-based session
- Remember me functionality
- Password recovery via email

**Há»“ SÆ¡ CÃ¡ NhÃ¢n:**
```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚     Personal Profile                 â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  ðŸ“¸ Avatar Upload                    â”‚
â”‚  ðŸ‘¤ Full Name, Date of Birth        â”‚
â”‚  ðŸ“§ Email, Phone Number             â”‚
â”‚  ðŸ  Address                          â”‚
â”‚  ðŸ©¸ Blood Type                       â”‚
â”‚  âš–ï¸  Height, Weight                  â”‚
â”‚  ðŸ¥ Medical History                  â”‚
â”‚  âš ï¸  Allergies                       â”‚
â”‚  ðŸ’Š Current Medications             â”‚
â”‚  ðŸ“± Emergency Contact               â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Chá»‰ Sá»‘ Sá»©c Khá»e:**
- BMI Calculator (Tá»± Ä‘á»™ng tÃ­nh)
- Blood Pressure Tracker
- Heart Rate Monitor
- Blood Glucose Levels
- Weight History Chart
- Sleep Tracking

#### ðŸ“Š 2. GiÃ¡m SÃ¡t Sá»©c Khá»e Real-time (IoT Integration)

**Dashboard Tá»•ng Quan:**
```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚          HEALTH MONITORING DASHBOARD                     â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚
â”‚  â”‚ â¤ï¸ HR: 72   â”‚  â”‚ ðŸ« SpO2: 98 â”‚  â”‚ ðŸŒ¡ï¸ 36.5Â°C  â”‚    â”‚
â”‚  â”‚ bpm         â”‚  â”‚ %           â”‚  â”‚             â”‚    â”‚
â”‚  â”‚ â— NORMAL    â”‚  â”‚ â— NORMAL    â”‚  â”‚ â— NORMAL    â”‚    â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚
â”‚                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                      â”‚
â”‚  â”‚ ðŸ©¸ 120/80   â”‚  â”‚ ðŸ¬ 95 mg/dL â”‚                      â”‚
â”‚  â”‚ mmHg        â”‚  â”‚ Glucose     â”‚                      â”‚
â”‚  â”‚ â— NORMAL    â”‚  â”‚ â— NORMAL    â”‚                      â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                      â”‚
â”‚                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”       â”‚
â”‚  â”‚     Heart Rate Trend (Last 24h)             â”‚       â”‚
â”‚  â”‚     ðŸ“ˆ [Line Chart]                         â”‚       â”‚
â”‚  â”‚                                              â”‚       â”‚
â”‚  â”‚                                              â”‚       â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜       â”‚
â”‚                                                           â”‚
â”‚  âš ï¸ AI Alert: Your heart rate is slightly elevated     â”‚
â”‚     Recommendation: Rest for 10 minutes                 â”‚
â”‚                                                           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Káº¿t Ná»‘i IoT Devices:**
- Automatic device pairing via MQTT
- Real-time data streaming
- Data validation & error handling
- Battery & signal monitoring
- Offline data buffering

**AI Health Analysis:**
- Anomaly detection (PhÃ¡t hiá»‡n báº¥t thÆ°á»ng)
- Risk level assessment (ÄÃ¡nh giÃ¡ má»©c Ä‘á»™ nguy hiá»ƒm)
- Personalized recommendations
- Predictive alerts

#### ðŸ” 3. Tra Cá»©u & Äáº·t Lá»‹ch BÃ¡c SÄ©

**TÃ¬m Kiáº¿m BÃ¡c SÄ©:**
```
Filters:
  â€¢ Specialty (ChuyÃªn khoa): Cardiology, Neurology, etc.
  â€¢ Experience: 5+ years, 10+ years
  â€¢ Rating: â­ 4.5+
  â€¢ Availability: Today, This week
  â€¢ Consultation Fee: Price range
  â€¢ Location: Near me
```

**ThÃ´ng Tin BÃ¡c SÄ©:**
```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Dr. Nguyá»…n VÄƒn A                   â”‚
â”‚  â­â­â­â­â­ 4.8 (120 reviews)       â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  ðŸ¥ Specialty: Cardiologist         â”‚
â”‚  ðŸŽ“ Experience: 15 years            â”‚
â”‚  ðŸ’° Fee: 200,000 VNÄ/session        â”‚
â”‚  ðŸ“ Location: HCM City              â”‚
â”‚  âœ… Verified Doctor                 â”‚
â”‚                                      â”‚
â”‚  Bio:                                â”‚
â”‚  ChuyÃªn gia tim máº¡ch vá»›i hÆ¡n 15     â”‚
â”‚  nÄƒm kinh nghiá»‡m, tá»«ng cÃ´ng tÃ¡c     â”‚
â”‚  táº¡i Viá»‡n Tim...                     â”‚
â”‚                                      â”‚
â”‚  [View Schedule] [Book Now]         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Äáº·t Lá»‹ch Háº¹n:**
- Calendar view vá»›i slot trá»‘ng
- Select date & time slot
- Enter reason for consultation
- Confirm appointment
- Email/SMS confirmation
- Add to device calendar

**Quáº£n LÃ½ Lá»‹ch Háº¹n:**
```
Status:
  ðŸŸ¡ Pending    - Chá» xÃ¡c nháº­n
  ðŸŸ¢ Confirmed  - ÄÃ£ xÃ¡c nháº­n
  ðŸ”µ Completed  - HoÃ n thÃ nh
  ðŸ”´ Cancelled  - ÄÃ£ há»§y
  ðŸŸ  Rescheduled - Dá»i lá»‹ch

Actions:
  â€¢ View details
  â€¢ Reschedule
  â€¢ Cancel appointment
  â€¢ Join video call (when time)
  â€¢ Rate & review (after completed)
```

#### ðŸ’Š 4. ÄÆ¡n Thuá»‘c Äiá»‡n Tá»­

**Xem ÄÆ¡n Thuá»‘c:**
```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Prescription #12345                                     â”‚
â”‚  Date: 2025-01-03                                        â”‚
â”‚  Doctor: Dr. Nguyá»…n VÄƒn A                               â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  Diagnosis: Hypertension (TÄƒng huyáº¿t Ã¡p)               â”‚
â”‚                                                           â”‚
â”‚  Medications:                                            â”‚
â”‚  1. ðŸ’Š Amlodipine 5mg                                   â”‚
â”‚     Dosage: 1 viÃªn/ngÃ y                                  â”‚
â”‚     Time: Buá»•i sÃ¡ng sau Äƒn                              â”‚
â”‚     Duration: 30 ngÃ y                                    â”‚
â”‚     Notes: Uá»‘ng vá»›i nhiá»u nÆ°á»›c                          â”‚
â”‚                                                           â”‚
â”‚  2. ðŸ’Š Aspirin 100mg                                    â”‚
â”‚     Dosage: 1 viÃªn/ngÃ y                                  â”‚
â”‚     Time: Buá»•i tá»‘i trÆ°á»›c khi ngá»§                        â”‚
â”‚     Duration: 30 ngÃ y                                    â”‚
â”‚                                                           â”‚
â”‚  Lab Tests Recommended:                                  â”‚
â”‚  â€¢ Blood pressure monitoring daily                       â”‚
â”‚  â€¢ Blood test after 1 month                             â”‚
â”‚                                                           â”‚
â”‚  Follow-up: 2025-02-03                                  â”‚
â”‚                                                           â”‚
â”‚  [Download PDF] [Set Reminders] [Refill Request]       â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Nháº¯c Nhá»Ÿ Uá»‘ng Thuá»‘c:**
- Daily medication reminders
- Push notifications
- Track medication adherence
- Mark as taken/skipped
- Refill alerts

#### ðŸ“ž 5. Gá»i Video/Audio vá»›i BÃ¡c SÄ©

**Luá»“ng Gá»i:**
```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚           VIDEO CALL WORKFLOW                         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

Patient Side:                  Doctor Side:
â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€                  â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

1. Tap "Call Now"      â”€â”€â”€â”€â”€â”€â–º 1. Receive notification
   on appointment                 "Patient is calling"

2. Initialize call     â”€â”€â”€â”€â”€â”€â–º 2. Accept/Reject
   with ZegoCloud

3. Waiting for         â—„â”€â”€â”€â”€â”€â”€ 3. Accept call
   response...

4. Call connected      â—„â”€â”€â”€â”€â”€â–º 4. Call connected
   ðŸŽ¥ Video ON                    ðŸŽ¥ Video ON
   ðŸŽ¤ Mic ON                      ðŸŽ¤ Mic ON
   ðŸ”Š Speaker ON                  ðŸ”Š Speaker ON

5. Consultation...     â—„â”€â”€â”€â”€â”€â–º 5. Consultation...

6. End call           â”€â”€â”€â”€â”€â”€â–º 6. End call

7. Save call history           7. Save call history
   - Duration                     - Notes
   - Timestamp                    - Follow-up
```

**TÃ­nh NÄƒng Trong Call:**
- Toggle video ON/OFF
- Toggle microphone mute/unmute
- Toggle speaker/earpiece
- Flip camera (front/back)
- Screen sharing (optional)
- In-call messaging
- Connection quality indicator
- Call duration timer

**LÆ°u Ã:**
- Uses ZegoCloud SDK
- Low latency < 300ms
- HD video quality
- Automatic reconnection
- Call recording (with consent)

#### ðŸ’¬ 6. Nháº¯n Tin Vá»›i BÃ¡c SÄ© (Chat)

**Chat Interface:**
```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ â† Dr. Nguyá»…n VÄƒn A                    â‹®   â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                              â”‚
â”‚  Hello Doctor, I have a question            â”‚
â”‚  about my blood pressure readings.          â”‚
â”‚                                     10:30 âœ“âœ“â”‚
â”‚                                              â”‚
â”‚  ðŸ“Ž [blood_pressure_chart.png]              â”‚
â”‚                                     10:31 âœ“âœ“â”‚
â”‚                                              â”‚
â”‚      Hello! I see your readings.            â”‚
â”‚      Your BP looks slightly elevated.       â”‚
â”‚  âœ“âœ“ 10:35                                   â”‚
â”‚                                              â”‚
â”‚      I recommend reducing salt intake       â”‚
â”‚      and monitoring for next 3 days.        â”‚
â”‚  âœ“âœ“ 10:36                                   â”‚
â”‚                                              â”‚
â”‚  Thank you doctor!                          â”‚
â”‚                                     10:38 âœ“ â”‚
â”‚                                              â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  [ðŸ“Ž] [ðŸ“·] [ðŸŽ¤]   Type a message...  [Send]â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Features:**
- Real-time messaging via Socket.IO
- Text, Image, File sharing
- Voice messages
- Message status: Sent âœ“, Delivered âœ“âœ“, Seen ðŸ”µ
- Typing indicators
- Unread count badges
- Message search
- Delete messages
- Push notifications for new messages

#### ðŸ“° 7. Tin Tá»©c Sá»©c Khá»e (Health Articles)

**Danh Má»¥c:**
- Latest health news
- Disease prevention tips
- Nutrition & diet
- Exercise & fitness
- Mental health
- Chronic disease management

**Article View:**
```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  [Cover Image]                           â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  Title: 10 Tips to Lower Blood Pressure â”‚
â”‚  Author: Dr. John Smith                  â”‚
â”‚  Date: 2025-01-02                       â”‚
â”‚  Category: Cardiology                    â”‚
â”‚                                          â”‚
â”‚  [Full Article Content]                  â”‚
â”‚                                          â”‚
â”‚  [Bookmark] [Share] [Read Later]        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

#### ðŸ¤– 8. AI Health Prediction

**Chá»©c NÄƒng Dá»± ÄoÃ¡n:**
```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚         AI HEALTH RISK ASSESSMENT                        â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                           â”‚
â”‚  Your Data:                                              â”‚
â”‚  â€¢ Age: 45 years                                         â”‚
â”‚  â€¢ Gender: Male                                          â”‚
â”‚  â€¢ BMI: 27.5 (Overweight)                               â”‚
â”‚  â€¢ Blood Pressure: 135/88 mmHg                          â”‚
â”‚  â€¢ Heart Rate: 78 bpm                                    â”‚
â”‚  â€¢ Cholesterol: 210 mg/dL                               â”‚
â”‚  â€¢ Smoking: No                                           â”‚
â”‚  â€¢ Family History: Yes (Father had heart disease)       â”‚
â”‚                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”       â”‚
â”‚  â”‚     AI PREDICTION RESULT                     â”‚       â”‚
â”‚  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤       â”‚
â”‚  â”‚                                              â”‚       â”‚
â”‚  â”‚  Heart Disease Risk:  ðŸŸ¡ MODERATE (45%)    â”‚       â”‚
â”‚  â”‚                                              â”‚       â”‚
â”‚  â”‚  Risk Factors:                               â”‚       â”‚
â”‚  â”‚  â€¢ Elevated blood pressure                   â”‚       â”‚
â”‚  â”‚  â€¢ Overweight (BMI > 25)                    â”‚       â”‚
â”‚  â”‚  â€¢ Family history of heart disease          â”‚       â”‚
â”‚  â”‚                                              â”‚       â”‚
â”‚  â”‚  Recommendations:                            â”‚       â”‚
â”‚  â”‚  âœ“ Reduce salt intake                       â”‚       â”‚
â”‚  â”‚  âœ“ Exercise 30 min/day, 5 days/week        â”‚       â”‚
â”‚  â”‚  âœ“ Lose 5-10% body weight                  â”‚       â”‚
â”‚  â”‚  âœ“ Monitor BP twice daily                   â”‚       â”‚
â”‚  â”‚  âœ“ Consult cardiologist within 2 weeks     â”‚       â”‚
â”‚  â”‚                                              â”‚       â”‚
â”‚  â”‚  [Schedule Appointment] [View Details]      â”‚       â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜       â”‚
â”‚                                                           â”‚
â”‚  Note: This is an AI-generated assessment.              â”‚
â”‚  Please consult a doctor for accurate diagnosis.         â”‚
â”‚                                                           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**AI Models Used:**
- MLP (Multi-Layer Perceptron) for heart disease prediction
- CNN for ECG anomaly detection
- Risk stratification algorithm

---

### 5.2. TÃ­nh NÄƒng Cho BÃ¡c SÄ© (Doctor Features)

#### ðŸ‘¨â€âš•ï¸ 1. Dashboard BÃ¡c SÄ©

**Tá»•ng Quan:**
```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚         DR. NGUYá»„N VÄ‚N A - DASHBOARD                    â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                           â”‚
â”‚  Today's Summary:                                        â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”              â”‚
â”‚  â”‚    8     â”‚  â”‚    5     â”‚  â”‚    2     â”‚              â”‚
â”‚  â”‚ Appts    â”‚  â”‚ Complete â”‚  â”‚ Pending  â”‚              â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜              â”‚
â”‚                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”              â”‚
â”‚  â”‚   15     â”‚  â”‚   â­4.8  â”‚  â”‚   120    â”‚              â”‚
â”‚  â”‚ Patients â”‚  â”‚ Rating   â”‚  â”‚ Reviews  â”‚              â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜              â”‚
â”‚                                                           â”‚
â”‚  â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€          â”‚
â”‚                                                           â”‚
â”‚  Upcoming Appointments:                                  â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”       â”‚
â”‚  â”‚ 09:00 - Nguyá»…n Thá»‹ B (Heart checkup)        â”‚       â”‚
â”‚  â”‚ [View Details] [Call Now] [Chat]            â”‚       â”‚
â”‚  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤       â”‚
â”‚  â”‚ 10:00 - Tráº§n VÄƒn C (Follow-up)              â”‚       â”‚
â”‚  â”‚ [View Details] [Call Now] [Chat]            â”‚       â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜       â”‚
â”‚                                                           â”‚
â”‚  Recent Notifications:                                   â”‚
â”‚  â€¢ New appointment request from Patient D               â”‚
â”‚  â€¢ Patient E sent you a message                         â”‚
â”‚  â€¢ Reminder: Update your schedule                       â”‚
â”‚                                                           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

#### ðŸ“… 2. Quáº£n LÃ½ Lá»‹ch LÃ m Viá»‡c

**Weekly Schedule:**
```
         Mon    Tue    Wed    Thu    Fri    Sat    Sun
09:00   [Booked] [Free] [Booked] [Free] [Booked] [Free] [Off]
10:00   [Booked] [Booked] [Free] [Booked] [Free] [Booked] [Off]
11:00   [Free] [Booked] [Booked] [Free] [Booked] [Free] [Off]
14:00   [Booked] [Free] [Booked] [Booked] [Free] [Free] [Off]
15:00   [Free] [Booked] [Free] [Booked] [Booked] [Booked] [Off]
16:00   [Free] [Free] [Free] [Free] [Free] [Free] [Off]
```

**Actions:**
- Set available hours
- Block time slots
- Set recurring schedules
- Mark leave/vacation days
- Override specific dates

#### ðŸ‘¥ 3. Quáº£n LÃ½ Bá»‡nh NhÃ¢n

**Patient List:**
- View all patients
- Search by name/ID
- Filter by appointment status
- Sort by last visit

**Patient Detail View:**
```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Patient: Nguyá»…n Thá»‹ B (ID: #12345)                    â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  Basic Info:                                             â”‚
â”‚  â€¢ Age: 45 | Gender: Female                            â”‚
â”‚  â€¢ Blood Type: O+                                       â”‚
â”‚  â€¢ Phone: +84 912 345 678                              â”‚
â”‚                                                           â”‚
â”‚  Medical History:                                        â”‚
â”‚  â€¢ Hypertension (since 2020)                            â”‚
â”‚  â€¢ Type 2 Diabetes (since 2018)                         â”‚
â”‚                                                           â”‚
â”‚  Current Medications:                                    â”‚
â”‚  â€¢ Metformin 500mg - 2x daily                          â”‚
â”‚  â€¢ Amlodipine 5mg - 1x daily                           â”‚
â”‚                                                           â”‚
â”‚  Recent Vitals:                                          â”‚
â”‚  â€¢ BP: 130/85 mmHg (2 hours ago)                       â”‚
â”‚  â€¢ HR: 72 bpm (2 hours ago)                            â”‚
â”‚  â€¢ Glucose: 120 mg/dL (Today morning)                  â”‚
â”‚                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”         â”‚
â”‚  â”‚    Vital Trends (Last 7 days)             â”‚         â”‚
â”‚  â”‚    [Chart showing BP, HR, Glucose]        â”‚         â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜         â”‚
â”‚                                                           â”‚
â”‚  Appointment History:                                    â”‚
â”‚  â€¢ 2025-01-01: Routine checkup                         â”‚
â”‚  â€¢ 2024-12-15: Diabetes management                     â”‚
â”‚  â€¢ 2024-11-20: Blood pressure review                   â”‚
â”‚                                                           â”‚
â”‚  [View Full History] [Start Consultation] [Chat]       â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

#### ðŸ’Š 4. KÃª ÄÆ¡n Thuá»‘c

**Prescription Form:**
```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚         CREATE PRESCRIPTION                              â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  Patient: Nguyá»…n Thá»‹ B                                  â”‚
â”‚  Date: 2025-01-03                                       â”‚
â”‚  Appointment ID: #789                                    â”‚
â”‚                                                           â”‚
â”‚  Diagnosis:                                              â”‚
â”‚  [_______________________________________________]       â”‚
â”‚  e.g., Hypertension, Type 2 Diabetes                    â”‚
â”‚                                                           â”‚
â”‚  Medications:                                            â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”       â”‚
â”‚  â”‚ 1. Drug Name: [Amlodipine_______]          â”‚       â”‚
â”‚  â”‚    Strength: [5mg___]                       â”‚       â”‚
â”‚  â”‚    Dosage: [1 tablet_]                      â”‚       â”‚
â”‚  â”‚    Frequency: [Once daily_]                 â”‚       â”‚
â”‚  â”‚    Duration: [30 days__]                    â”‚       â”‚
â”‚  â”‚    Instructions: [Take with food___]        â”‚       â”‚
â”‚  â”‚    [Remove]                                  â”‚       â”‚
â”‚  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤       â”‚
â”‚  â”‚ 2. Drug Name: [Metformin_______]           â”‚       â”‚
â”‚  â”‚    Strength: [500mg_]                       â”‚       â”‚
â”‚  â”‚    Dosage: [1 tablet_]                      â”‚       â”‚
â”‚  â”‚    Frequency: [Twice daily]                 â”‚       â”‚
â”‚  â”‚    Duration: [30 days__]                    â”‚       â”‚
â”‚  â”‚    Instructions: [After meals__]            â”‚       â”‚
â”‚  â”‚    [Remove]                                  â”‚       â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜       â”‚
â”‚  [+ Add Medication]                                      â”‚
â”‚                                                           â”‚
â”‚  Lab Tests Recommended:                                  â”‚
â”‚  [_______________________________________________]       â”‚
â”‚                                                           â”‚
â”‚  Additional Notes:                                       â”‚
â”‚  [_______________________________________________]       â”‚
â”‚  [_______________________________________________]       â”‚
â”‚                                                           â”‚
â”‚  Follow-up Date: [2025-02-03___] (Optional)             â”‚
â”‚                                                           â”‚
â”‚  [Save Draft] [Send to Patient] [Cancel]                â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Features:**
- Drug database integration
- Dosage calculator
- Drug interaction checker
- Allergy warnings
- E-signature
- Print/Download PDF
- Send directly to patient app

#### ðŸ“Š 5. Xem Dá»¯ Liá»‡u IoT Cá»§a Bá»‡nh NhÃ¢n

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚    PATIENT HEALTH DATA - Real-time Monitoring           â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  Patient: Nguyá»…n Thá»‹ B                                  â”‚
â”‚  Device: Health Band #ABC123                            â”‚
â”‚  Last Update: 2 minutes ago                             â”‚
â”‚                                                           â”‚
â”‚  Current Vitals:                                         â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”             â”‚
â”‚  â”‚ HR: 78   â”‚  â”‚ SpO2: 97 â”‚  â”‚ 36.8Â°C   â”‚             â”‚
â”‚  â”‚ bpm      â”‚  â”‚ %        â”‚  â”‚          â”‚             â”‚
â”‚  â”‚ â— NORMAL â”‚  â”‚ â— NORMAL â”‚  â”‚ â— NORMAL â”‚             â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜             â”‚
â”‚                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                                            â”‚
â”‚  â”‚ 132/86   â”‚  âš ï¸ Slightly elevated                    â”‚
â”‚  â”‚ mmHg     â”‚                                            â”‚
â”‚  â”‚ â— WATCH  â”‚                                            â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                                            â”‚
â”‚                                                           â”‚
â”‚  Trends (Last 24 hours):                                 â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”         â”‚
â”‚  â”‚ [Line Chart - Heart Rate]                 â”‚         â”‚
â”‚  â”‚                                            â”‚         â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜         â”‚
â”‚                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”         â”‚
â”‚  â”‚ [Line Chart - Blood Pressure]             â”‚         â”‚
â”‚  â”‚                                            â”‚         â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜         â”‚
â”‚                                                           â”‚
â”‚  AI Alerts:                                              â”‚
â”‚  âš ï¸ Blood pressure trending upward over last 3 days    â”‚
â”‚     Recommendation: Consider adjusting medication       â”‚
â”‚                                                           â”‚
â”‚  [Export Data] [Set Custom Alert] [Video Call Patient] â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

#### ðŸ“ 6. Ghi ChÃº Bá»‡nh Ãn

- SOAP notes format
- Voice-to-text dictation
- Templates for common conditions
- Attach images/files
- Search previous notes

---

### 5.3. TÃ­nh NÄƒng Admin Portal

#### ðŸŽ›ï¸ 1. Dashboard Overview

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚              ADMIN DASHBOARD                             â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                           â”‚
â”‚  System Statistics:                                      â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”             â”‚
â”‚  â”‚  1,245   â”‚  â”‚   156    â”‚  â”‚  2,890   â”‚             â”‚
â”‚  â”‚ Patients â”‚  â”‚ Doctors  â”‚  â”‚ Appts    â”‚             â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜             â”‚
â”‚                                                           â”‚
â”‚  Revenue This Month: $45,600                            â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”         â”‚
â”‚  â”‚ [Bar Chart - Monthly Revenue]             â”‚         â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜         â”‚
â”‚                                                           â”‚
â”‚  Active Users (Last 24h): 520                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”         â”‚
â”‚  â”‚ [Line Chart - User Activity]              â”‚         â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜         â”‚
â”‚                                                           â”‚
â”‚  Appointment Status:                                     â”‚
â”‚  â€¢ Pending: 45                                           â”‚
â”‚  â€¢ Confirmed: 120                                        â”‚
â”‚  â€¢ Completed: 2,500                                      â”‚
â”‚  â€¢ Cancelled: 225                                        â”‚
â”‚                                                           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

#### ðŸ‘¥ 2. User Management

**User List Table:**
| ID | Name | Email | Role | Status | Actions |
|----|------|-------|------|--------|---------|
| 1 | Nguyá»…n VÄƒn A | doctora@email.com | Doctor | Active | [Edit] [View] [Block] |
| 2 | Tráº§n Thá»‹ B | patientb@email.com | Patient | Active | [Edit] [View] [Block] |
| 3 | LÃª VÄƒn C | doctorc@email.com | Doctor | Pending | [Edit] [Approve] [Reject] |

**Features:**
- Create/Edit/Delete users
- Approve doctor registrations
- Block/Unblock accounts
- Reset passwords
- View user activity logs
- Export user data

#### ðŸ¥ 3. Doctor Verification

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚         DOCTOR VERIFICATION REQUEST                      â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  Name: Dr. Nguyá»…n VÄƒn A                                 â”‚
â”‚  Email: doctora@email.com                               â”‚
â”‚  Specialty: Cardiology                                   â”‚
â”‚  Experience: 15 years                                    â”‚
â”‚  License Number: ABC123456                              â”‚
â”‚                                                           â”‚
â”‚  Submitted Documents:                                    â”‚
â”‚  ðŸ“„ Medical License.pdf                                 â”‚
â”‚  ðŸ“„ Degree Certificate.pdf                              â”‚
â”‚  ðŸ“„ ID Card.pdf                                         â”‚
â”‚                                                           â”‚
â”‚  [View Documents] [Download All]                        â”‚
â”‚                                                           â”‚
â”‚  Verification Status: Pending Review                     â”‚
â”‚                                                           â”‚
â”‚  Admin Notes:                                            â”‚
â”‚  [_______________________________________________]       â”‚
â”‚                                                           â”‚
â”‚  [âœ… Approve] [âŒ Reject] [Request More Info]          â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

#### ðŸ“Š 4. Analytics & Reports

**Reports Available:**
- User registration trends
- Appointment statistics
- Revenue reports
- Doctor performance metrics
- Patient satisfaction scores
- System usage analytics
- IoT device activity

**Export Formats:**
- PDF
- Excel (CSV)
- JSON

#### ðŸ“° 5. Content Management

**Health Articles:**
- Create/Edit/Delete articles
- Category management
- Publish/Unpublish
- SEO settings
- Featured articles

**Notifications:**
- Send system-wide notifications
- Target specific user groups
- Schedule notifications
- Track notification engagement

#### âš™ï¸ 6. System Settings

- General settings
- Payment gateway config
- Email/SMS templates
- Backup & restore
- API key management
- Security settings

---

## 6. AI & MACHINE LEARNING

### 6.1. AI Architecture Overview

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                AI/ML PREDICTION PIPELINE                     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ User Health  â”‚
â”‚ Data Input   â”‚
â”‚              â”‚
â”‚ â€¢ Age        â”‚
â”‚ â€¢ Gender     â”‚
â”‚ â€¢ Vitals     â”‚
â”‚ â€¢ History    â”‚
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚
       â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Data Preprocessing & Validation    â”‚
â”‚  â€¢ Missing value handling           â”‚
â”‚  â€¢ Outlier detection                â”‚
â”‚  â€¢ Data type conversion             â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Feature Engineering                â”‚
â”‚  â€¢ Calculate BMI                    â”‚
â”‚  â€¢ Calculate MAP (Mean Arterial P)  â”‚
â”‚  â€¢ Age from birth year              â”‚
â”‚  â€¢ Gender encoding                  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Feature Scaling (StandardScaler)   â”‚
â”‚  â€¢ Z-score normalization            â”‚
â”‚  â€¢ Mean = 0, Std = 1                â”‚
â”‚  â€¢ Using pre-trained scaler         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Model Selection                    â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”‚
â”‚  â”‚ MLP Model   â”‚  â”‚  ECG Model   â”‚ â”‚
â”‚  â”‚ (Heart      â”‚  â”‚  (Anomaly    â”‚ â”‚
â”‚  â”‚ Disease)    â”‚  â”‚  Detection)  â”‚ â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  TensorFlow.js Inference            â”‚
â”‚  â€¢ Load pre-trained model           â”‚
â”‚  â€¢ Forward pass                     â”‚
â”‚  â€¢ Get prediction probabilities     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Post-Processing                    â”‚
â”‚  â€¢ Risk level classification        â”‚
â”‚  â€¢ Confidence score calculation     â”‚
â”‚  â€¢ Generate recommendations         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Result Storage & Notification      â”‚
â”‚  â€¢ Save to database                 â”‚
â”‚  â€¢ Send alerts if high risk         â”‚
â”‚  â€¢ Update health_metrics table      â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 6.2. MLP Model - Heart Disease Prediction

**Model Architecture:**
```
Input Layer (12 features)
        â†“
Dense Layer (64 neurons, ReLU)
        â†“
Dropout (0.3)
        â†“
Dense Layer (32 neurons, ReLU)
        â†“
Dropout (0.2)
        â†“
Dense Layer (16 neurons, ReLU)
        â†“
Output Layer (1 neuron, Sigmoid)
        â†“
Prediction (0-1 probability)
```

**Input Features:**
```javascript
const features = [
    'age',              // Years
    'sex',              // 0: Female, 1: Male
    'cp',               // Chest pain type (0-3)
    'trestbps',         // Resting blood pressure (mmHg)
    'chol',             // Serum cholesterol (mg/dl)
    'fbs',              // Fasting blood sugar > 120 mg/dl (0/1)
    'restecg',          // Resting ECG results (0-2)
    'thalach',          // Max heart rate achieved
    'exang',            // Exercise induced angina (0/1)
    'oldpeak',          // ST depression
    'slope',            // Slope of peak exercise ST segment
    'ca',               // Number of major vessels (0-3)
    'thal'              // Thalassemia (0-2)
];
```

**Prediction Output:**
```javascript
{
    "risk_score": 0.72,  // 72% probability
    "risk_level": "high",
    "confidence": 0.89,
    "risk_factors": [
        "Elevated blood pressure",
        "High cholesterol",
        "Family history"
    ],
    "recommendations": [
        "Consult a cardiologist immediately",
        "Reduce salt intake",
        "Exercise 30 min/day",
        "Monitor BP daily"
    ]
}
```

### 6.3. ECG Anomaly Detection Model

**Model Architecture:**
```
Input: ECG waveform (time series data)
        â†“
Conv1D Layer (32 filters, kernel=5)
        â†“
MaxPooling1D (pool_size=2)
        â†“
Conv1D Layer (64 filters, kernel=5)
        â†“
MaxPooling1D (pool_size=2)
        â†“
Flatten
        â†“
Dense Layer (128 neurons, ReLU)
        â†“
Dropout (0.5)
        â†“
Output Layer (5 classes, Softmax)
        â†“
Classification: Normal, Arrhythmia, MI, etc.
```

**Detected Anomalies:**
- Normal heartbeat
- Atrial Fibrillation (AFib)
- Ventricular Tachycardia (VT)
- Myocardial Infarction (MI)
- Other arrhythmias

### 6.4. Health Risk Assessment Algorithm

**Code Implementation (health_analysis_service.js):**
```javascript
function analyzeHealthData(sensorData) {
    const alerts = [];
    
    // Heart Rate Analysis
    if (sensorData.heart_rate < 40) {
        alerts.push({
            type: 'heart_rate',
            severity: 'critical',
            title: 'Severe Bradycardia',
            message: 'Heart rate dangerously low. Seek immediate medical attention.',
            value: sensorData.heart_rate,
            unit: 'bpm'
        });
    } else if (sensorData.heart_rate > 120) {
        alerts.push({
            type: 'heart_rate',
            severity: 'danger',
            title: 'Tachycardia',
            message: 'Heart rate elevated. Rest and monitor.',
            value: sensorData.heart_rate,
            unit: 'bpm'
        });
    }
    
    // Blood Pressure Analysis
    const systolic = sensorData.systolic_bp;
    const diastolic = sensorData.diastolic_bp;
    
    if (systolic >= 180 || diastolic >= 120) {
        alerts.push({
            type: 'blood_pressure',
            severity: 'critical',
            title: 'Hypertensive Crisis',
            message: 'Dangerously high blood pressure. Call emergency services.',
            value: `${systolic}/${diastolic}`,
            unit: 'mmHg'
        });
    } else if (systolic >= 140 || diastolic >= 90) {
        alerts.push({
            type: 'blood_pressure',
            severity: 'warning',
            title: 'High Blood Pressure',
            message: 'BP elevated. Consider medication adjustment.',
            value: `${systolic}/${diastolic}`,
            unit: 'mmHg'
        });
    }
    
    // SpO2 Analysis
    if (sensorData.spo2 < 90) {
        alerts.push({
            type: 'spo2',
            severity: 'critical',
            title: 'Severe Hypoxemia',
            message: 'Blood oxygen level critically low. Seek immediate care.',
            value: sensorData.spo2,
            unit: '%'
        });
    }
    
    // Temperature Analysis
    if (sensorData.temperature >= 38.5) {
        alerts.push({
            type: 'temperature',
            severity: 'warning',
            title: 'Fever',
            message: 'Elevated body temperature detected.',
            value: sensorData.temperature,
            unit: 'Â°C'
        });
    }
    
    // Determine overall risk level
    const riskLevel = determineOverallRisk(alerts);
    
    return {
        risk_level: riskLevel,
        alerts: alerts,
        analyzed_at: new Date()
    };
}

function determineOverallRisk(alerts) {
    if (alerts.some(a => a.severity === 'critical')) return 'critical';
    if (alerts.some(a => a.severity === 'danger')) return 'danger';
    if (alerts.some(a => a.severity === 'warning')) return 'warning';
    return 'normal';
}
```

**Risk Levels:**
```
ðŸŸ¢ Normal    - All vitals within normal range
ðŸŸ¡ Warning   - Mild deviations, monitor closely
ðŸŸ  Danger    - Significant abnormalities, consult doctor
ðŸ”´ Critical  - Life-threatening, seek emergency care
```

### 6.5. Data Preprocessing & Feature Engineering

**Standard Scaler Implementation:**
```javascript
// predict_service.js
class StandardScaler {
    constructor(mean, scale) {
        this.mean = mean;
        this.scale = scale;
    }
    
    transform(data) {
        return data.map((value, index) => 
            (value - this.mean[index]) / this.scale[index]
        );
    }
}

// Load pre-trained scaler parameters
const scaler = new StandardScaler(
    scalerMean,   // From training data
    scalerScale   // From training data
);
```

**Feature Engineering:**
```javascript
async function prepareFeatures(userId, sensorData) {
    // Get user profile
    const user = await getUserProfile(userId);
    
    // Calculate derived features
    const age = new Date().getFullYear() - user.birth_year;
    const bmi = user.weight / ((user.height / 100) ** 2);
    const map = (sensorData.systolic_bp + 2 * sensorData.diastolic_bp) / 3;
    const gender = user.gender === 'male' ? 1 : 0;
    
    // Prepare feature vector
    const features = [
        age,
        gender,
        sensorData.chest_pain_type || 0,
        sensorData.systolic_bp,
        sensorData.cholesterol || 200,
        sensorData.fasting_blood_sugar > 120 ? 1 : 0,
        sensorData.resting_ecg || 0,
        sensorData.heart_rate,
        sensorData.exercise_angina || 0,
        sensorData.st_depression || 0,
        sensorData.st_slope || 0,
        sensorData.num_major_vessels || 0,
        sensorData.thalassemia || 0
    ];
    
    // Scale features
    const scaledFeatures = scaler.transform(features);
    
    return scaledFeatures;
}
```

### 6.6. Model Training Process (Offline)

**Training Pipeline:**
```python
# Python training script (not in production, used for model development)
import tensorflow as tf
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

# Load dataset
data = pd.read_csv('heart_disease_dataset.csv')

# Prepare features and target
X = data.drop('target', axis=1)
y = data['target']

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Feature scaling
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Build model
model = tf.keras.Sequential([
    tf.keras.layers.Dense(64, activation='relu', input_shape=(12,)),
    tf.keras.layers.Dropout(0.3),
    tf.keras.layers.Dense(32, activation='relu'),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(16, activation='relu'),
    tf.keras.layers.Dense(1, activation='sigmoid')
])

# Compile
model.compile(
    optimizer='adam',
    loss='binary_crossentropy',
    metrics=['accuracy', 'AUC']
)

# Train
history = model.fit(
    X_train_scaled, y_train,
    validation_split=0.2,
    epochs=100,
    batch_size=32,
    callbacks=[
        tf.keras.callbacks.EarlyStopping(patience=10),
        tf.keras.callbacks.ModelCheckpoint('best_model.h5', save_best_only=True)
    ]
)

# Evaluate
test_loss, test_acc, test_auc = model.evaluate(X_test_scaled, y_test)
print(f'Test Accuracy: {test_acc:.4f}')
print(f'Test AUC: {test_auc:.4f}')

# Save model for TensorFlow.js
import tensorflowjs as tfjs
tfjs.converters.save_keras_model(model, 'models/mlp_model')

# Save scaler parameters
import json
with open('scaler_params.json', 'w') as f:
    json.dump({
        'mean': scaler.mean_.tolist(),
        'scale': scaler.scale_.tolist()
    }, f)
```

**Model Performance Metrics:**
- Accuracy: 87.5%
- Precision: 0.89
- Recall: 0.85
- F1 Score: 0.87
- AUC-ROC: 0.92

---

*(Tiáº¿p tá»¥c trong file tiáº¿p theo...)*
## 7. API DOCUMENTATION

### 7.1. API Architecture

**Base URL:** `http://localhost:5000/api`

**Authentication:** JWT Bearer Token
```
Authorization: Bearer <token>
```

**Response Format:**
```javascript
// Success
{
    "success": true,
    "data": {...},
    "message": "Operation successful"
}

// Error
{
    "success": false,
    "error": "Error message",
    "code": "ERROR_CODE"
}
```

### 7.2. Authentication APIs

#### POST /auth/register
```javascript
// Request
{
    "email": "user@example.com",
    "password": "SecurePass123",
    "fullName": "Nguyá»…n VÄƒn A",
    "role": "patient",  // "patient" or "doctor"
    "phoneNumber": "+84912345678"
}

// Response
{
    "success": true,
    "data": {
        "user": {
            "id": 1,
            "email": "user@example.com",
            "fullName": "Nguyá»…n VÄƒn A",
            "role": "patient"
        },
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
}
```

#### POST /auth/login
```javascript
// Request
{
    "email": "user@example.com",
    "password": "SecurePass123"
}

// Response
{
    "success": true,
    "data": {
        "user": {
            "id": 1,
            "userId": 1,
            "userName": "Nguyá»…n VÄƒn A",
            "email": "user@example.com",
            "role": "patient",
            "avatarUrl": "https://..."
        },
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
}
```

### 7.3. User APIs

#### GET /users/profile
```javascript
// Headers: Authorization: Bearer <token>

// Response
{
    "success": true,
    "data": {
        "id": 1,
        "email": "user@example.com",
        "fullName": "Nguyá»…n VÄƒn A",
        "role": "patient",
        "phoneNumber": "+84912345678",
        "gender": "male",
        "dateOfBirth": "1990-01-15",
        "height": 170,
        "weight": 70,
        "bloodType": "O+",
        "avatarUrl": "https://...",
        "medicalHistory": "...",
        "allergies": "...",
        "isVerified": true
    }
}
```

#### PUT /users/profile
```javascript
// Request
{
    "fullName": "Nguyá»…n VÄƒn A Updated",
    "phoneNumber": "+84987654321",
    "height": 172,
    "weight": 68,
    ...
}

// Response
{
    "success": true,
    "message": "Profile updated successfully"
}
```

### 7.4. Doctor APIs

#### GET /doctors
```javascript
// Query params: ?specialty=cardiology&page=1&limit=10

// Response
{
    "success": true,
    "data": {
        "doctors": [
            {
                "userId": 5,
                "fullName": "Dr. Nguyá»…n VÄƒn B",
                "specialty": "Cardiology",
                "experienceYears": 15,
                "averageRating": 4.8,
                "totalReviews": 120,
                "consultationFee": 200000,
                "isVerified": true,
                "isAvailable": true,
                "avatarUrl": "https://..."
            },
            ...
        ],
        "pagination": {
            "currentPage": 1,
            "totalPages": 5,
            "totalDoctors": 45,
            "limit": 10
        }
    }
}
```

#### GET /doctors/:id
```javascript
// Response
{
    "success": true,
    "data": {
        "userId": 5,
        "fullName": "Dr. Nguyá»…n VÄƒn B",
        "email": "doctor@example.com",
        "specialty": "Cardiology",
        "experienceYears": 15,
        "licenseNumber": "ABC123456",
        "education": "MD from Harvard Medical School",
        "bio": "Experienced cardiologist...",
        "consultationFee": 200000,
        "averageRating": 4.8,
        "totalReviews": 120,
        "isVerified": true,
        "isAvailable": true,
        "schedules": [
            {
                "dayOfWeek": "Monday",
                "timeSlots": ["09:00-09:30", "09:30-10:00", ...]
            },
            ...
        ]
    }
}
```

### 7.5. Appointment APIs

#### POST /appointments
```javascript
// Request
{
    "doctorId": 5,
    "appointmentDate": "2025-01-10",
    "timeSlot": "09:00-09:30",
    "reason": "Regular checkup",
    "symptoms": "Feeling chest pain occasionally"
}

// Response
{
    "success": true,
    "data": {
        "id": 123,
        "patientId": 1,
        "doctorId": 5,
        "appointmentDate": "2025-01-10",
        "timeSlot": "09:00-09:30",
        "status": "pending",
        "reason": "Regular checkup"
    }
}
```

#### GET /appointments
```javascript
// Query params: ?status=confirmed&page=1&limit=10

// Response
{
    "success": true,
    "data": {
        "appointments": [
            {
                "id": 123,
                "doctor": {
                    "userId": 5,
                    "fullName": "Dr. Nguyá»…n VÄƒn B",
                    "specialty": "Cardiology",
                    "avatarUrl": "https://..."
                },
                "appointmentDate": "2025-01-10",
                "timeSlot": "09:00-09:30",
                "status": "confirmed",
                "reason": "Regular checkup"
            },
            ...
        ]
    }
}
```

#### PATCH /appointments/:id/status
```javascript
// Request
{
    "status": "confirmed",  // "confirmed", "cancelled", "completed"
    "notes": "Appointment confirmed"
}

// Response
{
    "success": true,
    "message": "Appointment status updated"
}
```

### 7.6. Prescription APIs

#### POST /prescriptions
```javascript
// Request (Doctor only)
{
    "appointmentId": 123,
    "patientId": 1,
    "diagnosis": "Hypertension, Type 2 Diabetes",
    "medications": [
        {
            "name": "Amlodipine",
            "dosage": "5mg",
            "frequency": "Once daily",
            "duration": "30 days",
            "instructions": "Take with food"
        },
        {
            "name": "Metformin",
            "dosage": "500mg",
            "frequency": "Twice daily",
            "duration": "30 days",
            "instructions": "After meals"
        }
    ],
    "labTests": "Blood pressure monitoring, Blood test after 1 month",
    "notes": "...",
    "followUpDate": "2025-02-03"
}

// Response
{
    "success": true,
    "data": {
        "id": 456,
        "appointmentId": 123,
        "patientId": 1,
        "doctorId": 5,
        "createdAt": "2025-01-03T10:30:00Z"
    }
}
```

#### GET /prescriptions
```javascript
// Query params: ?patientId=1

// Response
{
    "success": true,
    "data": [
        {
            "id": 456,
            "doctor": {
                "fullName": "Dr. Nguyá»…n VÄƒn B",
                "specialty": "Cardiology"
            },
            "diagnosis": "Hypertension, Type 2 Diabetes",
            "medications": [...],
            "createdAt": "2025-01-03T10:30:00Z"
        },
        ...
    ]
}
```

### 7.7. Health Data APIs

#### POST /health/metrics
```javascript
// Request
{
    "metricType": "blood_pressure",
    "systolic": 130,
    "diastolic": 85,
    "source": "manual",
    "recordedAt": "2025-01-03T14:00:00Z"
}

// Response
{
    "success": true,
    "data": {
        "id": 789,
        "userId": 1,
        "metricType": "blood_pressure",
        "value": 130,
        "systolic": 130,
        "diastolic": 85,
        "riskLevel": "normal",
        "aiPrediction": {...}
    }
}
```

#### GET /health/metrics
```javascript
// Query params: ?type=heart_rate&from=2025-01-01&to=2025-01-03

// Response
{
    "success": true,
    "data": {
        "metrics": [
            {
                "id": 789,
                "metricType": "heart_rate",
                "value": 72,
                "unit": "bpm",
                "riskLevel": "normal",
                "recordedAt": "2025-01-03T14:00:00Z"
            },
            ...
        ],
        "summary": {
            "average": 75.5,
            "min": 65,
            "max": 88,
            "count": 50
        }
    }
}
```

#### POST /health/predict
```javascript
// Request (AI Prediction)
{
    "age": 45,
    "gender": "male",
    "systolicBP": 135,
    "diastolicBP": 88,
    "heartRate": 78,
    "cholesterol": 210,
    "fastingBloodSugar": 105,
    ...
}

// Response
{
    "success": true,
    "data": {
        "riskScore": 0.72,
        "riskLevel": "high",
        "confidence": 0.89,
        "riskFactors": [
            "Elevated blood pressure",
            "High cholesterol",
            "Family history"
        ],
        "recommendations": [
            "Consult a cardiologist immediately",
            "Reduce salt intake",
            "Exercise 30 min/day"
        ]
    }
}
```

### 7.8. Chat APIs

#### GET /conversations
```javascript
// Response
{
    "success": true,
    "data": [
        {
            "id": 10,
            "otherUser": {
                "userId": 5,
                "fullName": "Dr. Nguyá»…n VÄƒn B",
                "avatarUrl": "https://...",
                "role": "doctor"
            },
            "lastMessage": "Thank you doctor!",
            "lastMessageAt": "2025-01-03T10:38:00Z",
            "unreadCount": 2
        },
        ...
    ]
}
```

#### GET /conversations/:id/messages
```javascript
// Query params: ?page=1&limit=50

// Response
{
    "success": true,
    "data": {
        "messages": [
            {
                "id": 501,
                "senderId": 1,
                "content": "Hello Doctor, I have a question",
                "messageType": "text",
                "status": "seen",
                "sentAt": "2025-01-03T10:30:00Z"
            },
            {
                "id": 502,
                "senderId": 5,
                "content": "Hello! How can I help you?",
                "messageType": "text",
                "status": "seen",
                "sentAt": "2025-01-03T10:35:00Z"
            },
            ...
        ]
    }
}
```

### 7.9. Call History APIs

#### POST /calls
```javascript
// Request
{
    "callId": "call_abc123",
    "receiverId": 5,
    "callType": "video"
}

// Response
{
    "success": true,
    "data": {
        "id": 111,
        "callId": "call_abc123",
        "callerId": 1,
        "receiverId": 5,
        "callType": "video",
        "status": "calling"
    }
}
```

#### PATCH /calls/:id/status
```javascript
// Request
{
    "status": "completed",
    "durationSeconds": 1800
}

// Response
{
    "success": true,
    "message": "Call status updated"
}
```

### 7.10. IoT/MQTT APIs

#### POST /mqtt/publish
```javascript
// Request
{
    "topic": "health/sensor/user_1",
    "payload": {
        "userId": 1,
        "heartRate": 72,
        "spo2": 98,
        "temperature": 36.5,
        "systolicBP": 120,
        "diastolicBP": 80
    }
}

// Response
{
    "success": true,
    "message": "Data published to MQTT"
}
```

### 7.11. Admin APIs

#### GET /admin/statistics
```javascript
// Response
{
    "success": true,
    "data": {
        "totalUsers": 1245,
        "totalDoctors": 156,
        "totalAppointments": 2890,
        "totalRevenue": 45600000,
        "activeUsersLast24h": 520,
        "appointmentsByStatus": {
            "pending": 45,
            "confirmed": 120,
            "completed": 2500,
            "cancelled": 225
        }
    }
}
```

---

## 8. LUá»’NG HOáº T Äá»˜NG (WORKFLOWS)

### 8.1. User Registration Flow

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚           USER REGISTRATION WORKFLOW                         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

Patient/Doctor
      â”‚
      â”‚ 1. Enter registration info
      â”‚    (email, password, name, role)
      â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Frontend    â”‚
â”‚  Validation  â”‚
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚ 2. POST /auth/register
       â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚   Backend    â”‚ 3. Validate input
â”‚   API        â”‚ 4. Check email exists
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚ 5. Hash password (bcrypt)
       â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  PostgreSQL  â”‚ 6. INSERT INTO users
â”‚   Database   â”‚
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚ 7. Generate JWT token
       â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Send Email  â”‚ 8. Send verification email
â”‚  Service     â”‚    (optional)
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚ 9. Return user + token
       â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Frontend    â”‚ 10. Save token to storage
â”‚  Response    â”‚ 11. Navigate to home/dashboard
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 8.2. Appointment Booking Flow

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚         APPOINTMENT BOOKING WORKFLOW                         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

Patient
  â”‚
  â”‚ 1. Search for doctors
  â”‚    (by specialty, rating, etc.)
  â–¼
GET /doctors
  â”‚
  â”‚ 2. Select doctor
  â”‚ 3. View available slots
  â–¼
GET /doctors/:id/schedules
  â”‚
  â”‚ 4. Select date & time slot
  â”‚ 5. Enter appointment details
  â–¼
POST /appointments
  â”‚
  â”‚ 6. Create appointment (status: pending)
  â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Database: INSERT INTO appointments      â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 7. Send notification to doctor
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  FCM Service: Push notification          â”‚
â”‚  Socket.IO: Real-time notification       â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â–¼
Doctor receives notification
  â”‚
  â”‚ 8. Review appointment request
  â”‚ 9. Accept or Reject
  â–¼
PATCH /appointments/:id/status
  â”‚
  â”‚ 10. Update status (confirmed/cancelled)
  â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Database: UPDATE appointments           â”‚
â”‚  SET status = 'confirmed'                â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 11. Notify patient
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  FCM Service: Push notification          â”‚
â”‚  Email Service: Confirmation email       â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â–¼
Patient receives confirmation
  â”‚
  â”‚ 12. Wait for appointment time
  â”‚ 13. Join video call
  â–¼
Video Call Session (ZegoCloud)
  â”‚
  â”‚ 14. Consultation
  â–¼
Doctor creates prescription
  â”‚
  â”‚ 15. POST /prescriptions
  â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Database: INSERT INTO prescriptions     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 16. Send prescription to patient
               â–¼
Patient receives prescription
  â”‚
  â”‚ 17. Set medication reminders
  â”‚ 18. Rate & review doctor
  â–¼
Appointment completed
```

### 8.3. IoT Health Monitoring Flow

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚         IoT HEALTH MONITORING WORKFLOW                       â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

IoT Device (Wearable)
  â”‚
  â”‚ 1. Measure vitals
  â”‚    â€¢ Heart Rate
  â”‚    â€¢ SpO2
  â”‚    â€¢ Blood Pressure
  â”‚    â€¢ Temperature
  â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  MQTT Client: Publish data               â”‚
â”‚  Topic: health/sensor/user_{userId}      â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 2. Send via MQTT protocol
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  HiveMQ Cloud Broker                     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 3. Route message
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Backend MQTT Subscriber                 â”‚
â”‚  (mqtt_service.js)                       â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 4. Parse & validate data
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Health Analysis Service                 â”‚
â”‚  (health_analysis_service.js)            â”‚
â”‚                                           â”‚
â”‚  â€¢ Check for anomalies                   â”‚
â”‚  â€¢ Calculate risk levels                 â”‚
â”‚  â€¢ Trigger alerts if needed              â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”œâ”€â”€â”€ 5a. Normal readings
               â”‚    â””â”€â–º Save to database
               â”‚
               â””â”€â”€â”€ 5b. Abnormal readings
                    â””â”€â–º AI Prediction
                         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  AI Prediction Service                   â”‚
â”‚  (predict_service.js)                    â”‚
â”‚                                           â”‚
â”‚  â€¢ Feature engineering                   â”‚
â”‚  â€¢ StandardScaler transformation         â”‚
â”‚  â€¢ TensorFlow.js inference               â”‚
â”‚  â€¢ Risk assessment                       â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 6. Generate prediction results
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Database Operations                     â”‚
â”‚  â€¢ INSERT INTO sensor_packets            â”‚
â”‚  â€¢ INSERT INTO health_metrics            â”‚
â”‚  â€¢ UPDATE user health status             â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”œâ”€â”€â”€ 7a. High risk detected
               â”‚    â””â”€â–º Send alerts
               â”‚         â–¼
               â”‚    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
               â”‚    â”‚ Notification Service   â”‚
               â”‚    â”‚ â€¢ Push notification    â”‚
               â”‚    â”‚ â€¢ Email alert          â”‚
               â”‚    â”‚ â€¢ SMS (optional)       â”‚
               â”‚    â””â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚             â”‚
               â”‚             â–¼
               â”‚    Patient & Doctor notified
               â”‚
               â””â”€â”€â”€ 7b. Normal/Low risk
                    â””â”€â–º Store data only
                         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Mobile App Update                       â”‚
â”‚  â€¢ Real-time dashboard refresh (Socket)  â”‚
â”‚  â€¢ Update charts & graphs                â”‚
â”‚  â€¢ Show AI recommendations               â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 8.4. Video Call Flow

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚              VIDEO CALL WORKFLOW                             â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

Patient (Caller)                     Doctor (Receiver)
      â”‚                                     â”‚
      â”‚ 1. Tap "Call Now" button           â”‚
      â–¼                                     â”‚
Generate call_id                            â”‚
      â”‚                                     â”‚
      â”‚ 2. POST /calls                     â”‚
      â”‚    {callId, receiverId, type}      â”‚
      â–¼                                     â”‚
Backend API                                 â”‚
      â”‚                                     â”‚
      â”‚ 3. Save call record                â”‚
      â”‚    status = 'calling'               â”‚
      â–¼                                     â”‚
Database                                    â”‚
      â”‚                                     â”‚
      â”‚ 4. Send notification               â”‚
      â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–ºâ”‚
      â”‚    Socket.IO: 'incoming_call'       â”‚ 5. Receive notification
      â”‚    FCM: Push notification           â”‚    Show incoming screen
      â”‚                                     â”‚
      â”‚                                     â”‚ 6. User action
      â”‚                                     â”‚    Accept / Reject
      â”‚                                     â”‚
      â”‚ 7. Call accepted                   â”‚
      â”‚â—„â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
      â”‚    Socket.IO: 'call_accepted'       â”‚
      â”‚                                     â”‚
      â”‚ 8. Initialize ZegoCloud            â”‚
      â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–ºâ”‚ 9. Initialize ZegoCloud
      â”‚    â€¢ Get room ID = call_id          â”‚    â€¢ Join same room
      â”‚    â€¢ Join room                      â”‚
      â”‚                                     â”‚
      â”‚â—„â”€â”€â”€â”€â”€â”€â”€â”€ZegoCloud Serverâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–ºâ”‚
      â”‚         Establishes P2P             â”‚
      â”‚         WebRTC connection           â”‚
      â”‚                                     â”‚
      â”‚â—„â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–ºâ”‚
      â”‚         Video/Audio Stream          â”‚
      â”‚         â€¢ Bidirectional             â”‚
      â”‚         â€¢ HD quality                â”‚
      â”‚         â€¢ Low latency               â”‚
      â”‚                                     â”‚
      â”‚                                     â”‚
      â”‚        CONSULTATION IN PROGRESS     â”‚
      â”‚                                     â”‚
      â”‚                                     â”‚
      â”‚ 10. End call                        â”‚
      â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–ºâ”‚ 11. Call ended
      â”‚    Leave ZegoCloud room             â”‚     Leave room
      â”‚                                     â”‚
      â”‚ 12. PATCH /calls/:id/status        â”‚
      â”‚     {status: 'completed',           â”‚
      â”‚      duration: 1800}                â”‚
      â–¼                                     â”‚
Update database                             â”‚
      â”‚                                     â”‚
      â”‚ 13. Save call history               â”‚
      â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–ºâ”‚
      â”‚                                     â”‚
      â–¼                                     â–¼
Show call summary                   Show call summary
```

### 8.5. Real-time Chat Flow

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚            REAL-TIME CHAT WORKFLOW                           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

Patient                              Doctor
  â”‚                                     â”‚
  â”‚ 1. Open chat with doctor           â”‚
  â–¼                                     â”‚
GET /conversations/:id/messages        â”‚
  â”‚                                     â”‚
  â”‚ 2. Load message history             â”‚
  â–¼                                     â”‚
Display messages                        â”‚
  â”‚                                     â”‚
  â”‚ 3. Connect to Socket.IO server     â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–ºâ”‚ 4. Connect to Socket.IO
  â”‚    socket.connect()                 â”‚    socket.connect()
  â”‚                                     â”‚
  â”‚ 5. Join conversation room           â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–ºâ”‚ 6. Join same room
  â”‚    socket.emit('join_conversation') â”‚    socket.emit('join_conversation')
  â”‚                                     â”‚
  â”‚ 7. User types message               â”‚
  â”‚ 8. Click Send                       â”‚
  â–¼                                     â”‚
POST /messages                          â”‚
  â”‚                                     â”‚
  â”‚ 9. Save to database                 â”‚
  â–¼                                     â”‚
Database: INSERT INTO messages          â”‚
  â”‚                                     â”‚
  â”‚ 10. Emit via Socket.IO              â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–ºâ”‚ 11. Receive message
  â”‚     socket.emit('new_message')      â”‚     socket.on('new_message')
  â”‚                                     â”‚
  â”‚                                     â”‚ 12. Display message
  â”‚                                     â”‚     Update UI
  â”‚                                     â”‚
  â”‚                                     â”‚ 13. Send read receipt
  â”‚â—„â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
  â”‚     socket.emit('message_seen')     â”‚
  â”‚                                     â”‚
  â”‚ 14. Update message status           â”‚
  â–¼                                     â”‚
Update UI: âœ“ â†’ âœ“âœ“ â†’ ðŸ”µ                â”‚
  â”‚                                     â”‚
  â”‚ 15. Push notification (if offline)  â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–ºâ”‚
  â”‚     FCM Service                     â”‚
  â”‚                                     â”‚
```

### 8.6. AI Health Prediction Flow

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚         AI HEALTH PREDICTION WORKFLOW                        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

User Input / IoT Data
      â”‚
      â”‚ 1. Collect health data
      â”‚    â€¢ Vitals
      â”‚    â€¢ Medical history
      â”‚    â€¢ Demographics
      â–¼
POST /health/predict
      â”‚
      â”‚ 2. Validate input
      â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Predict Service                         â”‚
â”‚  (predict_service.js)                    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 3. Fetch user profile
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Database Query                          â”‚
â”‚  SELECT * FROM users WHERE id = ?        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 4. Feature Engineering
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Calculate Derived Features              â”‚
â”‚  â€¢ Age = current_year - birth_year       â”‚
â”‚  â€¢ BMI = weight / (height/100)Â²          â”‚
â”‚  â€¢ MAP = (SBP + 2*DBP) / 3              â”‚
â”‚  â€¢ Gender encoding: M=1, F=0             â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 5. Prepare feature vector
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Feature Vector (12 features)            â”‚
â”‚  [age, sex, cp, trestbps, chol, fbs,     â”‚
â”‚   restecg, thalach, exang, oldpeak,      â”‚
â”‚   slope, ca, thal]                       â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 6. Feature Scaling
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  StandardScaler Transformation           â”‚
â”‚  X_scaled = (X - mean) / std             â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 7. Model Inference
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  TensorFlow.js Node                      â”‚
â”‚  â€¢ Load MLP model                        â”‚
â”‚  â€¢ model.predict(X_scaled)               â”‚
â”‚  â€¢ Output: probability [0-1]             â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 8. Post-processing
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Risk Assessment                         â”‚
â”‚  â€¢ score < 0.3: Low risk                 â”‚
â”‚  â€¢ 0.3 â‰¤ score < 0.6: Moderate risk      â”‚
â”‚  â€¢ score â‰¥ 0.6: High risk                â”‚
â”‚                                           â”‚
â”‚  â€¢ Identify risk factors                 â”‚
â”‚  â€¢ Generate recommendations              â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”‚ 9. Save results
               â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Database: INSERT INTO health_metrics    â”‚
â”‚  â€¢ risk_score                            â”‚
â”‚  â€¢ risk_level                            â”‚
â”‚  â€¢ ai_prediction (JSONB)                 â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚
               â”œâ”€â”€â”€ 10a. High risk
               â”‚    â””â”€â–º Trigger alerts
               â”‚         â€¢ FCM notification
               â”‚         â€¢ Email doctor
               â”‚         â€¢ Suggest appointment
               â”‚
               â””â”€â”€â”€ 10b. Low/Moderate risk
                    â””â”€â–º Save quietly
                         â€¢ Update dashboard
                         â€¢ Log prediction
                         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Return Prediction Result                â”‚
â”‚  {                                        â”‚
â”‚    riskScore: 0.72,                      â”‚
â”‚    riskLevel: "high",                    â”‚
â”‚    confidence: 0.89,                     â”‚
â”‚    riskFactors: [...],                   â”‚
â”‚    recommendations: [...]                â”‚
â”‚  }                                        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## 9. SECURITY & PERFORMANCE

### 9.1. Security Measures

#### ðŸ” Authentication & Authorization

**JWT Implementation:**
```javascript
// Generate token
const token = jwt.sign(
    { userId: user.id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
);

// Verify token (middleware)
const verifyToken = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'No token provided' });
    
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(401).json({ error: 'Invalid token' });
    }
};
```

**Role-Based Access Control:**
```javascript
// Middleware: Only doctors can create prescriptions
const requireDoctor = (req, res, next) => {
    if (req.user.role !== 'doctor') {
        return res.status(403).json({ error: 'Access denied. Doctor role required.' });
    }
    next();
};

// Route
app.post('/prescriptions', verifyToken, requireDoctor, createPrescription);
```

#### ðŸ›¡ï¸ Data Protection

**Password Hashing:**
```javascript
const bcrypt = require('bcrypt');

// Hash password during registration
const hashedPassword = await bcrypt.hash(password, 10);

// Verify password during login
const isValidPassword = await bcrypt.compare(password, user.password);
```

**SQL Injection Prevention:**
```javascript
// Use parameterized queries
const query = 'SELECT * FROM users WHERE email = $1';
const result = await pool.query(query, [email]);
// NOT: `SELECT * FROM users WHERE email = '${email}'`
```

**XSS Protection:**
```javascript
const helmet = require('helmet');
app.use(helmet());  // Sets various HTTP headers for security
```

**CORS Configuration:**
```javascript
const cors = require('cors');
app.use(cors({
    origin: ['http://localhost:3000', 'https://healthiot.com'],
    credentials: true
}));
```

#### ðŸ”’ Data Encryption

**Sensitive Data:**
- Passwords: bcrypt hashing
- JWT tokens: Signed with secret key
- API keys: Stored in .env, never in code
- SSL/TLS: HTTPS for all API communication

**Database:**
- Encrypted connections
- Column-level encryption for sensitive fields
- Regular backups (encrypted)

### 9.2. Performance Optimization

#### âš¡ Backend Optimization

**Database Query Optimization:**
```sql
-- Indexes for faster queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_health_metrics_user_recorded ON health_metrics(user_id, recorded_at DESC);

-- Connection pooling
const pool = new Pool({
    max: 20,              // Maximum connections
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});
```

**Caching Strategy:**
```javascript
const NodeCache = require('node-cache');
const cache = new NodeCache({ stdTTL: 600 });  // 10 minutes

// Cache doctor list
app.get('/doctors', async (req, res) => {
    const cacheKey = 'doctors_list';
    const cached = cache.get(cacheKey);
    
    if (cached) {
        return res.json({ success: true, data: cached });
    }
    
    const doctors = await getDoctorsFromDB();
    cache.set(cacheKey, doctors);
    
    res.json({ success: true, data: doctors });
});
```

**Rate Limiting:**
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,  // 15 minutes
    max: 100,  // Limit each IP to 100 requests per windowMs
    message: 'Too many requests, please try again later.'
});

app.use('/api/', limiter);
```

**Compression:**
```javascript
const compression = require('compression');
app.use(compression());  // Compress all HTTP responses
```

#### ðŸš€ Frontend Optimization

**Flutter Performance:**
- Lazy loading for images
- Pagination for large lists
- Debouncing for search inputs
- Efficient state management with Provider
- Code splitting and tree shaking

**Image Optimization:**
```dart
// Cached network image
CachedNetworkImage(
    imageUrl: imageUrl,
    placeholder: (context, url) => CircularProgressIndicator(),
    errorWidget: (context, url, error) => Icon(Icons.error),
    cacheManager: CacheManager(
        Config('customCacheKey', stalePeriod: Duration(days: 7)),
    ),
)
```

### 9.3. Monitoring & Logging

**Application Logging:**
```javascript
const winston = require('winston');

const logger = winston.createLogger({
    level: 'info',
    format: winston.format.json(),
    transports: [
        new winston.transports.File({ filename: 'error.log', level: 'error' }),
        new winston.transports.File({ filename: 'combined.log' })
    ]
});

// Usage
logger.info('User logged in', { userId: 123, ip: req.ip });
logger.error('Database connection failed', { error: err.message });
```

**Error Tracking:**
```javascript
// Global error handler
app.use((err, req, res, next) => {
    logger.error('Unhandled error', {
        error: err.message,
        stack: err.stack,
        url: req.url,
        method: req.method
    });
    
    res.status(500).json({
        success: false,
        error: 'Internal server error'
    });
});
```

**Performance Metrics:**
- API response times
- Database query execution times
- Error rates
- Active users
- CPU & memory usage

---

## 10. DEPLOYMENT & DEVOPS

### 10.1. Development Environment

**Prerequisites:**
```bash
# Node.js & npm
node --version  # 20.x
npm --version   # 10.x

# Flutter
flutter --version  # 3.24.0+

# PostgreSQL
psql --version  # 16.x

# Git
git --version
```

**Environment Variables (.env):**
```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=health_iot_db
DB_USER=postgres
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your_super_secret_key_here

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Firebase
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email

# MQTT
MQTT_BROKER_URL=ssl://your-mqtt-broker.com:8883
MQTT_USERNAME=your_username
MQTT_PASSWORD=your_password

# Email
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password

# ZegoCloud
ZEGO_APP_ID=your_app_id
ZEGO_APP_SIGN=your_app_sign

# Server
PORT=5000
NODE_ENV=development
```

### 10.2. Local Development Setup

**Backend:**
```bash
cd HealthAI_Server
npm install
npm run dev  # nodemon app.js
```

**Frontend (Flutter):**
```bash
cd doan2
flutter pub get
flutter run -d windows  # For Windows
flutter run              # For mobile
```

**Admin Portal:**
```bash
cd admin-portal
npm install
npm run dev  # Next.js dev server
```

**Database:**
```bash
# Create database
createdb health_iot_db

# Run migrations
psql -d health_iot_db -f database/migrations.sql

# Seed data (optional)
psql -d health_iot_db -f database/seed_data.sql
```

### 10.3. Production Deployment

**Backend (Node.js) - Options:**

**Option 1: Traditional VPS (Ubuntu)**
```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone repository
git clone git@github.com:buithan04/Health_IoT.git
cd Health_IoT/HealthAI_Server

# Install dependencies
npm ci --production

# Setup PM2 for process management
npm install -g pm2
pm2 start app.js --name health-api
pm2 startup
pm2 save

# Setup Nginx reverse proxy
sudo apt install nginx
# Configure /etc/nginx/sites-available/health-api
```

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name api.healthiot.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

**Option 2: Docker**
```dockerfile
# Dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --production

COPY . .

EXPOSE 5000

CMD ["node", "app.js"]
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  api:
    build: ./HealthAI_Server
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
    env_file:
      - .env
    depends_on:
      - db

  db:
    image: postgres:16
    environment:
      POSTGRES_DB: health_iot_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  pgdata:
```

**Frontend (Flutter Mobile):**
```bash
# Build Android APK
flutter build apk --release

# Build iOS (requires Mac)
flutter build ios --release

# Build Windows executable
flutter build windows --release
```

**Admin Portal (Next.js):**
```bash
# Build for production
npm run build

# Start production server
npm start

# Or deploy to Vercel/Netlify
vercel deploy --prod
```

### 10.4. Database Backup & Recovery

**Automated Backup Script:**
```bash
#!/bin/bash
# backup_db.sh

BACKUP_DIR="/backups/postgres"
DATE=$(date +"%Y%m%d_%H%M%S")
FILENAME="health_iot_backup_$DATE.sql"

mkdir -p $BACKUP_DIR

pg_dump -U postgres health_iot_db > "$BACKUP_DIR/$FILENAME"

# Compress backup
gzip "$BACKUP_DIR/$FILENAME"

# Delete backups older than 30 days
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete

echo "Backup completed: $FILENAME.gz"
```

**Cron Job (daily at 2 AM):**
```bash
0 2 * * * /path/to/backup_db.sh
```

### 10.5. CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/deploy.yml
name: Deploy Health IoT

on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
      
      - name: Install dependencies
        run: npm ci
        working-directory: ./HealthAI_Server
      
      - name: Run tests
        run: npm test
        working-directory: ./HealthAI_Server

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to production
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /var/www/health-iot
            git pull origin main
            npm ci --production
            pm2 restart health-api
```

---

## 11. TESTING & QUALITY ASSURANCE

### 11.1. Backend Testing

**Unit Tests (Jest):**
```javascript
// tests/services/auth_service.test.js
const authService = require('../../services/auth_service');

describe('Auth Service', () => {
    test('should register new user', async () => {
        const userData = {
            email: 'test@example.com',
            password: 'Test123!',
            fullName: 'Test User',
            role: 'patient'
        };
        
        const result = await authService.register(userData);
        
        expect(result).toHaveProperty('user');
        expect(result).toHaveProperty('token');
        expect(result.user.email).toBe(userData.email);
    });
    
    test('should reject duplicate email', async () => {
        // Test implementation
    });
});
```

**API Integration Tests:**
```javascript
const request = require('supertest');
const app = require('../app');

describe('Appointment APIs', () => {
    let token;
    
    beforeAll(async () => {
        // Login and get token
        const res = await request(app)
            .post('/api/auth/login')
            .send({ email: 'patient@test.com', password: 'Test123!' });
        token = res.body.data.token;
    });
    
    test('GET /appointments should return user appointments', async () => {
        const res = await request(app)
            .get('/api/appointments')
            .set('Authorization', `Bearer ${token}`);
        
        expect(res.statusCode).toBe(200);
        expect(res.body.success).toBe(true);
        expect(Array.isArray(res.body.data.appointments)).toBe(true);
    });
});
```

### 11.2. Frontend Testing

**Flutter Widget Tests:**
```dart
// test/widgets/login_screen_test.dart
void main() {
  testWidgets('Login screen should show email and password fields', (tester) async {
    await tester.pumpWidget(MyApp(home: LoginScreen()));
    
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
```

---

## 12. PROJECT STRUCTURE SUMMARY

```
E:\Fluter\
â”œâ”€â”€ doan2/                          # Flutter Mobile App
â”‚   â”œâ”€â”€ lib/
â”‚   â”‚   â”œâ”€â”€ core/
â”‚   â”‚   â”œâ”€â”€ models/
â”‚   â”‚   â”œâ”€â”€ presentation/
â”‚   â”‚   â”‚   â”œâ”€â”€ patient/
â”‚   â”‚   â”‚   â””â”€â”€ doctor/
â”‚   â”‚   â””â”€â”€ service/
â”‚   â”œâ”€â”€ assets/
â”‚   â””â”€â”€ pubspec.yaml
â”‚
â”œâ”€â”€ HealthAI_Server/                # Node.js Backend
â”‚   â”œâ”€â”€ config/
â”‚   â”œâ”€â”€ controllers/
â”‚   â”œâ”€â”€ services/
â”‚   â”œâ”€â”€ models/
â”‚   â”œâ”€â”€ routes/
â”‚   â”œâ”€â”€ middleware/
â”‚   â”œâ”€â”€ workers/
â”‚   â”œâ”€â”€ database/
â”‚   â”‚   â”œâ”€â”€ migrations/
â”‚   â”‚   â””â”€â”€ seed_data.sql
â”‚   â”œâ”€â”€ app.js
â”‚   â””â”€â”€ package.json
â”‚
â”œâ”€â”€ admin-portal/                   # Next.js Admin Portal
â”‚   â”œâ”€â”€ src/
â”‚   â”‚   â”œâ”€â”€ app/
â”‚   â”‚   â”œâ”€â”€ components/
â”‚   â”‚   â””â”€â”€ lib/
â”‚   â”œâ”€â”€ public/
â”‚   â””â”€â”€ package.json
â”‚
â”œâ”€â”€ .gitignore
â”œâ”€â”€ README.md
â”œâ”€â”€ LICENSE
â””â”€â”€ PROJECT_REPORT.md              # This file
```

---

## 13. CONCLUSION & FUTURE ENHANCEMENTS

### 13.1. Project Achievements âœ…

- âœ… **Full-stack IoT health monitoring system**
- âœ… **AI-powered health risk prediction**
- âœ… **Real-time video/audio telemedicine**
- âœ… **Comprehensive EHR management**
- âœ… **Admin analytics dashboard**
- âœ… **Multi-platform support** (Windows, Android, iOS, Web)

### 13.2. Future Enhancements ðŸš€

**Short-term (3-6 months):**
1. **Mobile App Enhancements**
   - Offline mode support
   - Voice-to-text for medical notes
   - Medication reminder alarms

2. **AI/ML Improvements**
   - Real-time ECG monitoring with alerts
   - Diabetes risk prediction model
   - Mental health assessment

3. **Integration**
   - Electronic Health Records (EHR) standards (HL7 FHIR)
   - Insurance claim integration
   - Pharmacy integration for prescriptions

**Long-term (6-12 months):**
1. **Advanced Features**
   - AR/VR for medical education
   - Blockchain for secure medical records
   - Multi-language support

2. **Scalability**
   - Microservices architecture
   - Kubernetes deployment
   - CDN for global performance

3. **Compliance**
   - HIPAA compliance (US)
   - GDPR compliance (EU)
   - ISO 27001 certification

---

## 14. CONTACT & SUPPORT

**Developer:** BÃ¹i Duy ThÃ¢n  
**Email:** buithan04@example.com  
**GitHub:** https://github.com/buithan04/Health_IoT  
**Repository:** git@github.com:buithan04/Health_IoT.git

**Technical Support:**
- Issues: GitHub Issues
- Documentation: README.md, QUICK_START.md
- Contributing: CONTRIBUTING.md

---

## 15. APPENDIX

### A. Technology Stack Summary

| Category | Technology | Version |
|----------|-----------|---------|
| Mobile Frontend | Flutter | 3.24.0+ |
| Admin Frontend | Next.js | 14.x |
| Backend | Node.js | 20.x |
| Database | PostgreSQL | 16.x |
| AI/ML | TensorFlow.js | 4.15.0 |
| Real-time | Socket.IO | 4.6.1 |
| IoT Protocol | MQTT | 5.3.4 |
| Video Call | ZegoCloud | 4.18.1 |
| Push Notifications | Firebase FCM | - |
| File Storage | Cloudinary | - |

### B. Key Metrics

**Performance:**
- API response time: < 200ms (avg)
- Video call latency: < 300ms
- Database query time: < 50ms (avg)
- Mobile app size: ~50MB

**Capacity:**
- Concurrent users: 10,000+
- Database size: ~500GB
- IoT data ingestion: 1000 readings/sec
- Video calls: 100 simultaneous

### C. Glossary

- **BMI**: Body Mass Index
- **MAP**: Mean Arterial Pressure
- **ECG**: Electrocardiogram
- **SpO2**: Blood Oxygen Saturation
- **FCM**: Firebase Cloud Messaging
- **JWT**: JSON Web Token
- **MLP**: Multi-Layer Perceptron
- **CNN**: Convolutional Neural Network
- **EHR**: Electronic Health Record
- **IoT**: Internet of Things
- **MQTT**: Message Queuing Telemetry Transport

---

**Document Version:** 1.0  
**Last Updated:** January 3, 2026  
**Status:** Complete & Production Ready

---

## ðŸ“Š PROJECT DIAGRAMS

### Architecture Diagram
*(Detailed system architecture shown in Section 2)*

### Database ERD
*(Complete database schema in Section 4)*

### API Flow Diagrams
*(Comprehensive workflows in Section 8)*

### AI/ML Pipeline
*(Prediction pipeline in Section 6)*

---

**END OF REPORT**
