"use client";

import { useEffect, useState } from "react";
import { FaCog, FaBell, FaShieldAlt, FaPalette, FaSave, FaUndo } from "react-icons/fa";

export default function SettingsPage() {
    const [settings, setSettings] = useState({
        systemName: 'HealthAI',
        contactEmail: 'admin@healthai.com',
        contactPhone: '0123456789',
        emailNotification: true,
        appointmentNotification: true,
        userNotification: false,
        twoFactorAuth: false,
        passwordExpiry: false,
        themeMode: 'light',
        language: 'vi'
    });

    const [message, setMessage] = useState<{ text: string; type: 'success' | 'info' } | null>(null);

    useEffect(() => {
        const savedSettings = localStorage.getItem('adminSettings');
        if (savedSettings) {
            setSettings(JSON.parse(savedSettings));
        }
    }, []);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
        const { name, value, type } = e.target;
        const checked = (e.target as HTMLInputElement).checked;

        setSettings(prev => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value
        }));
    };

    const handleSave = () => {
        localStorage.setItem('adminSettings', JSON.stringify(settings));
        setMessage({ text: 'Lưu cài đặt thành công!', type: 'success' });
        setTimeout(() => setMessage(null), 3000);
    };

    const handleReset = () => {
        if (confirm('Bạn có chắc muốn đặt lại tất cả cài đặt về mặc định?')) {
            const defaultSettings = {
                systemName: 'HealthAI',
                contactEmail: 'admin@healthai.com',
                contactPhone: '0123456789',
                emailNotification: true,
                appointmentNotification: true,
                userNotification: false,
                twoFactorAuth: false,
                passwordExpiry: false,
                themeMode: 'light',
                language: 'vi'
            };
            setSettings(defaultSettings);
            localStorage.removeItem('adminSettings');
            setMessage({ text: 'Đã đặt lại cài đặt mặc định', type: 'info' });
            setTimeout(() => setMessage(null), 3000);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold text-gray-800">Cài đặt Hệ thống</h1>
            </div>

            {message && (
                <div className={`p-4 rounded-lg ${message.type === 'success' ? 'bg-green-100 text-green-700' : 'bg-blue-100 text-blue-700'}`}>
                    {message.text}
                </div>
            )}

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* General Settings */}
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <div className="flex items-center gap-3 mb-6 pb-4 border-b border-gray-100">
                        <div className="p-2 bg-blue-50 text-blue-600 rounded-lg">
                            <FaCog />
                        </div>
                        <h2 className="text-lg font-semibold text-gray-800">Thông tin chung</h2>
                    </div>

                    <div className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Tên hệ thống</label>
                            <input
                                type="text"
                                name="systemName"
                                value={settings.systemName}
                                onChange={handleChange}
                                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Email liên hệ</label>
                            <input
                                type="email"
                                name="contactEmail"
                                value={settings.contactEmail}
                                onChange={handleChange}
                                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Số điện thoại</label>
                            <input
                                type="text"
                                name="contactPhone"
                                value={settings.contactPhone}
                                onChange={handleChange}
                                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            />
                        </div>
                    </div>
                </div>

                {/* Notification Settings */}
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <div className="flex items-center gap-3 mb-6 pb-4 border-b border-gray-100">
                        <div className="p-2 bg-yellow-50 text-yellow-600 rounded-lg">
                            <FaBell />
                        </div>
                        <h2 className="text-lg font-semibold text-gray-800">Thông báo</h2>
                    </div>

                    <div className="space-y-4">
                        <div className="flex items-center justify-between">
                            <span className="text-gray-700">Thông báo qua Email</span>
                            <label className="relative inline-flex items-center cursor-pointer">
                                <input
                                    type="checkbox"
                                    name="emailNotification"
                                    checked={settings.emailNotification}
                                    onChange={handleChange}
                                    className="sr-only peer"
                                />
                                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                            </label>
                        </div>
                        <div className="flex items-center justify-between">
                            <span className="text-gray-700">Thông báo Lịch hẹn mới</span>
                            <label className="relative inline-flex items-center cursor-pointer">
                                <input
                                    type="checkbox"
                                    name="appointmentNotification"
                                    checked={settings.appointmentNotification}
                                    onChange={handleChange}
                                    className="sr-only peer"
                                />
                                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                            </label>
                        </div>
                        <div className="flex items-center justify-between">
                            <span className="text-gray-700">Thông báo Người dùng mới</span>
                            <label className="relative inline-flex items-center cursor-pointer">
                                <input
                                    type="checkbox"
                                    name="userNotification"
                                    checked={settings.userNotification}
                                    onChange={handleChange}
                                    className="sr-only peer"
                                />
                                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                            </label>
                        </div>
                    </div>
                </div>

                {/* Security Settings */}
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <div className="flex items-center gap-3 mb-6 pb-4 border-b border-gray-100">
                        <div className="p-2 bg-red-50 text-red-600 rounded-lg">
                            <FaShieldAlt />
                        </div>
                        <h2 className="text-lg font-semibold text-gray-800">Bảo mật</h2>
                    </div>

                    <div className="space-y-4">
                        <div className="flex items-center justify-between">
                            <span className="text-gray-700">Xác thực 2 lớp (2FA)</span>
                            <label className="relative inline-flex items-center cursor-pointer">
                                <input
                                    type="checkbox"
                                    name="twoFactorAuth"
                                    checked={settings.twoFactorAuth}
                                    onChange={handleChange}
                                    className="sr-only peer"
                                />
                                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                            </label>
                        </div>
                        <div className="flex items-center justify-between">
                            <span className="text-gray-700">Yêu cầu đổi mật khẩu định kỳ</span>
                            <label className="relative inline-flex items-center cursor-pointer">
                                <input
                                    type="checkbox"
                                    name="passwordExpiry"
                                    checked={settings.passwordExpiry}
                                    onChange={handleChange}
                                    className="sr-only peer"
                                />
                                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                            </label>
                        </div>
                    </div>
                </div>

                {/* Appearance Settings */}
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <div className="flex items-center gap-3 mb-6 pb-4 border-b border-gray-100">
                        <div className="p-2 bg-purple-50 text-purple-600 rounded-lg">
                            <FaPalette />
                        </div>
                        <h2 className="text-lg font-semibold text-gray-800">Giao diện</h2>
                    </div>

                    <div className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Chế độ hiển thị</label>
                            <select
                                name="themeMode"
                                value={settings.themeMode}
                                onChange={handleChange}
                                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            >
                                <option value="light">Sáng</option>
                                <option value="dark">Tối</option>
                                <option value="auto">Tự động</option>
                            </select>
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Ngôn ngữ</label>
                            <select
                                name="language"
                                value={settings.language}
                                onChange={handleChange}
                                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            >
                                <option value="vi">Tiếng Việt</option>
                                <option value="en">English</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <div className="flex gap-4 pt-4">
                <button
                    onClick={handleSave}
                    className="flex items-center gap-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                    <FaSave /> Lưu thay đổi
                </button>
                <button
                    onClick={handleReset}
                    className="flex items-center gap-2 px-6 py-2 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition-colors"
                >
                    <FaUndo /> Đặt lại
                </button>
            </div>
        </div>
    );
}
