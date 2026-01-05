"use client";

import { Bell, Search, User, Settings as SettingsIcon } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { useState, useEffect } from "react";

export default function Header() {
    const [adminInfo, setAdminInfo] = useState({ name: "Admin", email: "admin@healthai.com" });

    useEffect(() => {
        // Get admin info from localStorage or API
        const name = localStorage.getItem('adminName') || 'Admin User';
        const email = localStorage.getItem('adminEmail') || 'admin@healthai.com';
        setAdminInfo({ name, email });
    }, []);

    const handleLogout = () => {
        localStorage.removeItem('adminToken');
        localStorage.removeItem('adminName');
        localStorage.removeItem('adminEmail');
        window.location.href = '/auth/login';
    };

    return (
        <header className="bg-white border-b border-gray-200 h-16 flex items-center justify-between px-8 sticky top-0 z-40 shadow-sm">
            <div className="flex items-center gap-4 w-1/3">
                <div className="text-sm text-muted-foreground">
                    Chào mừng trở lại, <span className="font-semibold text-gray-900">{adminInfo.name}</span>
                </div>
            </div>

            <div className="flex items-center gap-3">
                {/* Notifications */}
                <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="icon" className="relative">
                            <Bell className="h-5 w-5 text-gray-500" />
                            <Badge className="absolute -top-1 -right-1 h-5 w-5 flex items-center justify-center p-0 bg-red-500 text-white text-xs">
                                3
                            </Badge>
                        </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent className="w-80" align="end">
                        <DropdownMenuLabel>Thông báo mới (3)</DropdownMenuLabel>
                        <DropdownMenuSeparator />
                        <div className="max-h-[300px] overflow-y-auto">
                            <DropdownMenuItem className="flex flex-col items-start p-3">
                                <div className="font-medium text-sm">Lịch hẹn mới</div>
                                <div className="text-xs text-muted-foreground">Bệnh nhân Nguyễn Văn A đã đặt lịch khám</div>
                                <div className="text-xs text-muted-foreground mt-1">5 phút trước</div>
                            </DropdownMenuItem>
                            <DropdownMenuItem className="flex flex-col items-start p-3">
                                <div className="font-medium text-sm">Bác sĩ mới đăng ký</div>
                                <div className="text-xs text-muted-foreground">BS. Trần Thị B đang chờ xác thực</div>
                                <div className="text-xs text-muted-foreground mt-1">1 giờ trước</div>
                            </DropdownMenuItem>
                            <DropdownMenuItem className="flex flex-col items-start p-3">
                                <div className="font-medium text-sm">Đơn thuốc mới</div>
                                <div className="text-xs text-muted-foreground">BS. Lê Văn C đã kê đơn thuốc</div>
                                <div className="text-xs text-muted-foreground mt-1">2 giờ trước</div>
                            </DropdownMenuItem>
                        </div>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem className="justify-center text-blue-600 font-medium">
                            Xem tất cả thông báo
                        </DropdownMenuItem>
                    </DropdownMenuContent>
                </DropdownMenu>

                {/* User Menu */}
                <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                        <Button variant="ghost" className="relative h-9 rounded-full pl-2 pr-3 hover:bg-gray-100">
                            <Avatar className="h-7 w-7 mr-2">
                                <AvatarFallback className="bg-gradient-to-br from-blue-500 to-purple-500 text-white text-xs font-bold">
                                    {adminInfo.name.charAt(0).toUpperCase()}
                                </AvatarFallback>
                            </Avatar>
                            <span className="text-sm font-medium hidden md:inline-block">{adminInfo.name}</span>
                        </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent className="w-56" align="end" forceMount>
                        <DropdownMenuLabel className="font-normal">
                            <div className="flex flex-col space-y-1">
                                <p className="text-sm font-medium leading-none">{adminInfo.name}</p>
                                <p className="text-xs leading-none text-muted-foreground">
                                    {adminInfo.email}
                                </p>
                            </div>
                        </DropdownMenuLabel>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem>
                            <User className="mr-2 h-4 w-4" />
                            Hồ sơ cá nhân
                        </DropdownMenuItem>
                        <DropdownMenuItem>
                            <SettingsIcon className="mr-2 h-4 w-4" />
                            Cài đặt
                        </DropdownMenuItem>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem className="text-red-600 focus:text-red-700" onClick={handleLogout}>
                            <svg className="mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                            </svg>
                            Đăng xuất
                        </DropdownMenuItem>
                    </DropdownMenuContent>
                </DropdownMenu>
            </div>
        </header>
    );
}
