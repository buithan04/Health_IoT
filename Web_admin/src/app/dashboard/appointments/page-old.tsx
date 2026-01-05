"use client";

import { useEffect, useState } from "react";
import { apiCall } from "@/utils/api";
import { FaCalendarCheck, FaClock, FaCheckCircle, FaTimesCircle, FaEye, FaSyncAlt } from "react-icons/fa";

interface Appointment {
    id: number;
    patient_name: string;
    patient_email: string;
    doctor_name: string;
    doctor_email: string;
    appointment_date: string;
    type_id: string;
    status: string;
    notes?: string;
    cancellation_reason?: string;
}

export default function AppointmentsPage() {
    const [appointments, setAppointments] = useState<Appointment[]>([]);
    const [filteredAppointments, setFilteredAppointments] = useState<Appointment[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");
    const [statusFilter, setStatusFilter] = useState("");
    const [dateFilter, setDateFilter] = useState("");

    // Stats
    const [stats, setStats] = useState({
        total: 0,
        pending: 0,
        completed: 0,
        cancelled: 0
    });

    useEffect(() => {
        loadAppointments();
    }, []);

    useEffect(() => {
        filterAppointments();
    }, [searchTerm, statusFilter, dateFilter, appointments]);

    const loadAppointments = async () => {
        setLoading(true);
        try {
            const response = await apiCall('/admin/appointments');
            let data: Appointment[] = [];
            if (response && response.appointments) {
                data = response.appointments;
            } else if (Array.isArray(response)) {
                data = response;
            }
            setAppointments(data);
            updateStats(data);
        } catch (error) {
            console.error("Error loading appointments", error);
        } finally {
            setLoading(false);
        }
    };

    const updateStats = (data: Appointment[]) => {
        const total = data.length;
        const pending = data.filter(a => a.status === 'pending').length;
        const completed = data.filter(a => a.status === 'completed').length;
        const cancelled = data.filter(a => a.status === 'cancelled').length;

        setStats({ total, pending, completed, cancelled });
    };

    const filterAppointments = () => {
        let result = [...appointments];

        if (searchTerm) {
            const lowerTerm = searchTerm.toLowerCase();
            result = result.filter(a =>
                (a.patient_name && a.patient_name.toLowerCase().includes(lowerTerm)) ||
                (a.doctor_name && a.doctor_name.toLowerCase().includes(lowerTerm)) ||
                (a.id.toString().includes(lowerTerm))
            );
        }

        if (statusFilter) {
            result = result.filter(a => a.status === statusFilter);
        }

        if (dateFilter) {
            result = result.filter(a => a.appointment_date.startsWith(dateFilter));
        }

        setFilteredAppointments(result);
    };

    const getStatusBadge = (status: string) => {
        switch (status) {
            case 'pending':
                return { text: 'Chờ xác nhận', class: 'bg-yellow-100 text-yellow-700' };
            case 'confirmed':
                return { text: 'Đã xác nhận', class: 'bg-blue-100 text-blue-700' };
            case 'completed':
                return { text: 'Đã hoàn thành', class: 'bg-green-100 text-green-700' };
            case 'cancelled':
                return { text: 'Đã hủy', class: 'bg-red-100 text-red-700' };
            default:
                return { text: status, class: 'bg-gray-100 text-gray-700' };
        }
    };

    const formatDate = (dateString: string) => {
        return new Date(dateString).toLocaleString('vi-VN', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold text-gray-800">Quản lý Lịch hẹn</h1>
                <div className="flex items-center gap-4">
                    <div className="relative">
                        <input
                            type="text"
                            placeholder="Tìm kiếm..."
                            className="pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                        />
                        <span className="absolute left-3 top-2.5 text-gray-400">🔍</span>
                    </div>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Tổng Lịch hẹn</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.total}</p>
                    </div>
                    <div className="p-3 bg-blue-50 rounded-full text-blue-600">
                        <FaCalendarCheck className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Chờ xác nhận</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.pending}</p>
                    </div>
                    <div className="p-3 bg-yellow-50 rounded-full text-yellow-600">
                        <FaClock className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Đã hoàn thành</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.completed}</p>
                    </div>
                    <div className="p-3 bg-green-50 rounded-full text-green-600">
                        <FaCheckCircle className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Đã hủy</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.cancelled}</p>
                    </div>
                    <div className="p-3 bg-red-50 rounded-full text-red-600">
                        <FaTimesCircle className="text-xl" />
                    </div>
                </div>
            </div>

            {/* Table Section */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="p-6 border-b border-gray-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <h2 className="text-lg font-semibold text-gray-800">Danh sách Lịch hẹn</h2>
                    <div className="flex gap-2">
                        <button
                            onClick={loadAppointments}
                            className="flex items-center gap-2 px-4 py-2 text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                        >
                            <FaSyncAlt /> Làm mới
                        </button>
                    </div>
                </div>

                <div className="p-4 bg-gray-50 border-b border-gray-100 grid grid-cols-1 md:grid-cols-3 gap-4">
                    <input
                        type="text"
                        placeholder="Tìm kiếm theo tên, ID..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                    <select
                        value={statusFilter}
                        onChange={(e) => setStatusFilter(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    >
                        <option value="">Tất cả trạng thái</option>
                        <option value="pending">Chờ xác nhận</option>
                        <option value="confirmed">Đã xác nhận</option>
                        <option value="completed">Đã hoàn thành</option>
                        <option value="cancelled">Đã hủy</option>
                    </select>
                    <input
                        type="date"
                        value={dateFilter}
                        onChange={(e) => setDateFilter(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-gray-50 text-gray-600 text-sm uppercase tracking-wider">
                                <th className="p-4 border-b font-medium">ID</th>
                                <th className="p-4 border-b font-medium">Bệnh nhân</th>
                                <th className="p-4 border-b font-medium">Bác sĩ</th>
                                <th className="p-4 border-b font-medium">Thời gian</th>
                                <th className="p-4 border-b font-medium">Loại khám</th>
                                <th className="p-4 border-b font-medium">Trạng thái</th>
                                <th className="p-4 border-b font-medium">Ghi chú</th>
                                <th className="p-4 border-b font-medium">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody className="text-gray-700 text-sm">
                            {loading ? (
                                <tr>
                                    <td colSpan={8} className="p-8 text-center text-gray-500">
                                        Đang tải dữ liệu...
                                    </td>
                                </tr>
                            ) : filteredAppointments.length === 0 ? (
                                <tr>
                                    <td colSpan={8} className="p-8 text-center text-gray-500">
                                        Không tìm thấy lịch hẹn nào
                                    </td>
                                </tr>
                            ) : (
                                filteredAppointments.map((apt) => {
                                    const statusBadge = getStatusBadge(apt.status);
                                    return (
                                        <tr key={apt.id} className="border-b hover:bg-gray-50 transition-colors">
                                            <td className="p-4">#{apt.id}</td>
                                            <td className="p-4">
                                                <div className="font-medium text-gray-900">{apt.patient_name}</div>
                                                <div className="text-xs text-gray-500">{apt.patient_email}</div>
                                            </td>
                                            <td className="p-4">
                                                <div className="font-medium text-gray-900">{apt.doctor_name}</div>
                                                <div className="text-xs text-gray-500">{apt.doctor_email}</div>
                                            </td>
                                            <td className="p-4">{formatDate(apt.appointment_date)}</td>
                                            <td className="p-4">
                                                <span className="px-2 py-1 bg-blue-50 text-blue-700 rounded text-xs font-medium">
                                                    {apt.type_id || 'Khám tổng quát'}
                                                </span>
                                            </td>
                                            <td className="p-4">
                                                <span className={`px-2 py-1 rounded-full text-xs font-medium ${statusBadge.class}`}>
                                                    {statusBadge.text}
                                                </span>
                                            </td>
                                            <td className="p-4 max-w-xs truncate" title={apt.notes}>
                                                {apt.notes || '-'}
                                            </td>
                                            <td className="p-4">
                                                <button className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg" title="Xem chi tiết">
                                                    <FaEye />
                                                </button>
                                            </td>
                                        </tr>
                                    );
                                })
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}
