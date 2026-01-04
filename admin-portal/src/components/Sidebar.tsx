"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
    LayoutDashboard,
    UserCog,
    Users,
    Calendar,
    FileText,
    Pill,
    Settings,
    LogOut,
    Activity
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";

const menuItems = [
    { name: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
    { name: "Người dùng", href: "/dashboard/users", icon: Users },
    { name: "Bác sĩ", href: "/dashboard/doctors", icon: UserCog },
    { name: "Bệnh nhân", href: "/dashboard/patients", icon: Users },
    { name: "Lịch hẹn", href: "/dashboard/appointments", icon: Calendar },
    { name: "Đơn thuốc", href: "/dashboard/prescriptions", icon: FileText },
    { name: "Thuốc", href: "/dashboard/medications", icon: Pill },
    { name: "Cài đặt", href: "/dashboard/settings", icon: Settings },
];

export default function Sidebar() {
    const pathname = usePathname();

    return (
        <aside className="w-64 bg-gradient-to-b from-white to-gray-50 border-r border-gray-200 h-screen fixed left-0 top-0 flex flex-col z-50 shadow-sm">
            <div className="h-16 flex items-center px-6 border-b border-gray-200 bg-white">
                <div className="flex items-center gap-2">
                    <div className="h-8 w-8 rounded-lg bg-gradient-to-br from-blue-600 to-purple-600 flex items-center justify-center">
                        <Activity className="h-5 w-5 text-white" />
                    </div>
                    <span className="text-xl font-bold tracking-tight bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                        HealthAI
                    </span>
                </div>
            </div>

            <nav className="flex-1 overflow-y-auto py-6 px-3">
                <ul className="space-y-1">
                    {menuItems.map((item) => {
                        const isActive = pathname === item.href;
                        return (
                            <li key={item.href}>
                                <Link
                                    href={item.href}
                                    className={cn(
                                        "flex items-center gap-3 px-3 py-2.5 rounded-md transition-all duration-200 group",
                                        isActive
                                            ? "bg-primary/10 text-primary font-medium"
                                            : "text-muted-foreground hover:bg-muted hover:text-foreground"
                                    )}
                                >
                                    <item.icon className={cn("h-5 w-5", isActive ? "text-primary" : "text-muted-foreground group-hover:text-foreground")} />
                                    <span>{item.name}</span>
                                </Link>
                            </li>
                        );
                    })}
                </ul>
            </nav>

            <div className="p-4 border-t bg-gradient-to-r from-red-50 to-pink-50">
                <Button
                    variant="ghost"
                    className="w-full justify-start text-red-600 hover:text-red-700 hover:bg-red-100/50 font-medium"
                    onClick={() => {
                        localStorage.removeItem('adminToken');
                        window.location.href = '/auth/login';
                    }}
                >
                    <LogOut className="mr-2 h-4 w-4" />
                    Đăng xuất
                </Button>
            </div>
        </aside>
    );
}
