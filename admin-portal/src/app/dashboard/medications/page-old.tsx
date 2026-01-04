"use client";

import { useEffect, useState } from "react";
import { apiCall } from "@/utils/api";
import { FaPills, FaBoxOpen, FaExclamationTriangle, FaTimesCircle, FaPlus, FaEdit, FaTrash, FaSyncAlt } from "react-icons/fa";

interface Medication {
    id: number;
    name: string;
    category: string;
    active_ingredient?: string;
    unit: string;
    price: number;
    stock: number;
    min_stock: number;
    description?: string;
}

interface Category {
    id: number;
    name: string;
}

export default function MedicationsPage() {
    const [medications, setMedications] = useState<Medication[]>([]);
    const [filteredMedications, setFilteredMedications] = useState<Medication[]>([]);
    const [categories, setCategories] = useState<Category[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");
    const [categoryFilter, setCategoryFilter] = useState("");

    // Stats
    const [stats, setStats] = useState({
        total: 0,
        available: 0,
        lowStock: 0,
        outOfStock: 0
    });

    useEffect(() => {
        loadMedications();
        loadCategories();
    }, []);

    useEffect(() => {
        filterMedications();
    }, [searchTerm, categoryFilter, medications]);

    const loadMedications = async () => {
        setLoading(true);
        try {
            const response = await apiCall('/admin/medications');
            let data: Medication[] = [];
            if (Array.isArray(response)) {
                data = response;
            } else if (response && response.medications) {
                data = response.medications;
            }
            setMedications(data);
            updateStats(data);
        } catch (error) {
            console.error("Error loading medications", error);
        } finally {
            setLoading(false);
        }
    };

    const loadCategories = async () => {
        try {
            const response = await apiCall('/admin/medication-categories');
            if (Array.isArray(response)) {
                setCategories(response);
            } else if (response && response.categories) {
                setCategories(response.categories);
            }
        } catch (error) {
            console.error("Error loading categories", error);
        }
    };

    const updateStats = (data: Medication[]) => {
        const total = data.length;
        const available = data.filter(m => m.stock > m.min_stock).length;
        const lowStock = data.filter(m => m.stock > 0 && m.stock <= m.min_stock).length;
        const outOfStock = data.filter(m => m.stock === 0).length;

        setStats({ total, available, lowStock, outOfStock });
    };

    const filterMedications = () => {
        let result = [...medications];

        if (searchTerm) {
            const lowerTerm = searchTerm.toLowerCase();
            result = result.filter(m =>
                (m.name && m.name.toLowerCase().includes(lowerTerm)) ||
                (m.category && m.category.toLowerCase().includes(lowerTerm)) ||
                (m.active_ingredient && m.active_ingredient.toLowerCase().includes(lowerTerm))
            );
        }

        if (categoryFilter) {
            result = result.filter(m => m.category === categoryFilter);
        }

        setFilteredMedications(result);
    };

    const getStockStatus = (stock: number, minStock: number) => {
        if (stock === 0) {
            return { text: 'Hết hàng', class: 'bg-red-100 text-red-700' };
        } else if (stock <= minStock) {
            return { text: 'Sắp hết', class: 'bg-yellow-100 text-yellow-700' };
        } else {
            return { text: 'Còn hàng', class: 'bg-green-100 text-green-700' };
        }
    };

    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold text-gray-800">Quản lý Thuốc</h1>
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
                        <h3 className="text-gray-500 text-sm font-medium">Tổng số thuốc</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.total}</p>
                    </div>
                    <div className="p-3 bg-blue-50 rounded-full text-blue-600">
                        <FaPills className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Còn hàng</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.available}</p>
                    </div>
                    <div className="p-3 bg-green-50 rounded-full text-green-600">
                        <FaBoxOpen className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Sắp hết hàng</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.lowStock}</p>
                    </div>
                    <div className="p-3 bg-yellow-50 rounded-full text-yellow-600">
                        <FaExclamationTriangle className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Hết hàng</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.outOfStock}</p>
                    </div>
                    <div className="p-3 bg-red-50 rounded-full text-red-600">
                        <FaTimesCircle className="text-xl" />
                    </div>
                </div>
            </div>

            {/* Table Section */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="p-6 border-b border-gray-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <h2 className="text-lg font-semibold text-gray-800">Danh sách Thuốc</h2>
                    <div className="flex gap-2">
                        <button
                            onClick={loadMedications}
                            className="flex items-center gap-2 px-4 py-2 text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                        >
                            <FaSyncAlt /> Làm mới
                        </button>
                        <button className="flex items-center gap-2 px-4 py-2 text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-colors">
                            <FaPlus /> Thêm Thuốc
                        </button>
                    </div>
                </div>

                <div className="p-4 bg-gray-50 border-b border-gray-100 grid grid-cols-1 md:grid-cols-3 gap-4">
                    <input
                        type="text"
                        placeholder="Tìm kiếm thuốc..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                    <select
                        value={categoryFilter}
                        onChange={(e) => setCategoryFilter(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    >
                        <option value="">Tất cả danh mục</option>
                        {categories.map(cat => (
                            <option key={cat.id || cat.name} value={cat.name}>{cat.name}</option>
                        ))}
                    </select>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-gray-50 text-gray-600 text-sm uppercase tracking-wider">
                                <th className="p-4 border-b font-medium">ID</th>
                                <th className="p-4 border-b font-medium">Tên thuốc</th>
                                <th className="p-4 border-b font-medium">Danh mục</th>
                                <th className="p-4 border-b font-medium">Hoạt chất</th>
                                <th className="p-4 border-b font-medium">Đơn vị</th>
                                <th className="p-4 border-b font-medium">Giá</th>
                                <th className="p-4 border-b font-medium">Tồn kho</th>
                                <th className="p-4 border-b font-medium">Trạng thái</th>
                                <th className="p-4 border-b font-medium">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody className="text-gray-700 text-sm">
                            {loading ? (
                                <tr>
                                    <td colSpan={9} className="p-8 text-center text-gray-500">
                                        Đang tải dữ liệu...
                                    </td>
                                </tr>
                            ) : filteredMedications.length === 0 ? (
                                <tr>
                                    <td colSpan={9} className="p-8 text-center text-gray-500">
                                        Không tìm thấy thuốc nào
                                    </td>
                                </tr>
                            ) : (
                                filteredMedications.map((med) => {
                                    const stockStatus = getStockStatus(med.stock, med.min_stock);
                                    return (
                                        <tr key={med.id} className="border-b hover:bg-gray-50 transition-colors">
                                            <td className="p-4">#{med.id}</td>
                                            <td className="p-4 font-medium text-gray-900">{med.name}</td>
                                            <td className="p-4">
                                                <span className="px-2 py-1 bg-blue-50 text-blue-700 rounded text-xs font-medium">
                                                    {med.category}
                                                </span>
                                            </td>
                                            <td className="p-4">{med.active_ingredient || '-'}</td>
                                            <td className="p-4">{med.unit}</td>
                                            <td className="p-4">{formatCurrency(med.price)}</td>
                                            <td className="p-4 font-medium">{med.stock}</td>
                                            <td className="p-4">
                                                <span className={`px-2 py-1 rounded-full text-xs font-medium ${stockStatus.class}`}>
                                                    {stockStatus.text}
                                                </span>
                                            </td>
                                            <td className="p-4 flex gap-2">
                                                <button className="p-2 text-yellow-600 hover:bg-yellow-50 rounded-lg" title="Sửa">
                                                    <FaEdit />
                                                </button>
                                                <button className="p-2 text-red-600 hover:bg-red-50 rounded-lg" title="Xóa">
                                                    <FaTrash />
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
