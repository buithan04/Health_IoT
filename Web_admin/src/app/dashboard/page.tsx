"use client";

import { useRouter } from "next/navigation";
import { apiCall } from "@/utils/api";
import {
  Users,
  UserCog,
  Calendar,
  Pill,
  Search,
  TrendingUp,
  Activity,
  Clock,
  Loader2,
  RefreshCw,
  ArrowUpRight,
  AlertCircle,
  CheckCircle2,
  XCircle,
  Filter
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { formatDistanceToNow } from "date-fns";
import { vi } from "date-fns/locale";
import { useQuery } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import Link from "next/link";

export default function Home() {
  const router = useRouter();
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('adminToken');
    if (!token) {
      router.push('/auth/login');
    }
  }, [router]);

  const { data: stats, isLoading: statsLoading, refetch: refetchStats } = useQuery({
    queryKey: ['dashboardStats'],
    queryFn: async () => {
      const res = await apiCall('/admin/dashboard/stats');
      return res?.stats || {
        totalUsers: 0,
        activeDoctors: 0,
        todayAppointments: 0,
        monthPrescriptions: 0,
        pendingAppointments: 0
      };
    },
    refetchInterval: 30000, // Auto-refresh every 30 seconds
  });

  const { data: activities, isLoading: activitiesLoading, refetch: refetchActivities } = useQuery({
    queryKey: ['recentActivities'],
    queryFn: async () => {
      const res = await apiCall('/admin/dashboard/activities');
      return res?.activities || [];
    },
    refetchInterval: 30000, // Auto-refresh every 30 seconds
  });

  const { data: users } = useQuery({
    queryKey: ['allUsers'],
    queryFn: async () => {
      const res = await apiCall('/admin/users');
      return res?.users || [];
    }
  });

  const { data: appointments } = useQuery({
    queryKey: ['allAppointments'],
    queryFn: async () => {
      const res = await apiCall('/admin/appointments');
      return res?.appointments || [];
    }
  });

  const handleRefresh = async () => {
    setRefreshing(true);
    await Promise.all([refetchStats(), refetchActivities()]);
    setTimeout(() => setRefreshing(false), 500);
  };

  const isLoading = statsLoading || activitiesLoading;

  const statCards = [
    {
      title: "Tổng Người dùng",
      value: stats?.totalUsers || 0,
      icon: Users,
      color: "text-blue-600",
      bg: "bg-blue-50",
      border: "border-blue-200",
      change: "+12%",
      changeType: "increase",
      description: "Tổng số người dùng hệ thống",
      link: "/users"
    },
    {
      title: "Bác sĩ Hoạt động",
      value: stats?.activeDoctors || 0,
      icon: UserCog,
      color: "text-emerald-600",
      bg: "bg-emerald-50",
      border: "border-emerald-200",
      change: "+3",
      changeType: "increase",
      description: "Đã xác thực và đang hoạt động",
      link: "/doctors"
    },
    {
      title: "Lịch hẹn Hôm nay",
      value: stats?.todayAppointments || 0,
      icon: Calendar,
      color: "text-purple-600",
      bg: "bg-purple-50",
      border: "border-purple-200",
      change: `${stats?.pendingAppointments || 0} chờ`,
      changeType: "neutral",
      description: `Chờ duyệt: ${stats?.pendingAppointments || 0}`,
      link: "/appointments"
    },
    {
      title: "Đơn thuốc Tháng này",
      value: stats?.monthPrescriptions || 0,
      icon: Pill,
      color: "text-amber-600",
      bg: "bg-amber-50",
      border: "border-amber-200",
      change: "+28%",
      changeType: "increase",
      description: "Đơn thuốc đã kê trong tháng",
      link: "/prescriptions"
    }
  ];

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-[calc(100vh-100px)]">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
            Dashboard
          </h1>
          <p className="text-muted-foreground mt-2">
            Tổng quan về hoạt động của hệ thống HealthAI
          </p>
        </div>
        <div className="flex items-center gap-3">
          <div className="relative w-full md:w-64">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              type="search"
              placeholder="Tìm kiếm..."
              className="pl-10 bg-white border-gray-200 focus:border-blue-500"
            />
          </div>
          <Button
            onClick={handleRefresh}
            variant="outline"
            size="icon"
            className="shrink-0"
            disabled={refreshing}
          >
            <RefreshCw className={`h-4 w-4 ${refreshing ? 'animate-spin' : ''}`} />
          </Button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statCards.map((stat, index) => (
          <Link href={stat.link} key={index}>
            <Card className={`hover:shadow-lg transition-all duration-300 border-2 ${stat.border} cursor-pointer group`}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-gray-600">
                  {stat.title}
                </CardTitle>
                <div className={`p-3 rounded-xl ${stat.bg} group-hover:scale-110 transition-transform`}>
                  <stat.icon className={`h-5 w-5 ${stat.color}`} />
                </div>
              </CardHeader>
              <CardContent>
                <div className="flex items-baseline justify-between">
                  <div className="text-3xl font-bold text-gray-900">{stat.value}</div>
                  <Badge
                    variant={stat.changeType === 'increase' ? 'default' : 'secondary'}
                    className="text-xs"
                  >
                    {stat.change}
                  </Badge>
                </div>
                <p className="text-xs text-muted-foreground mt-2 flex items-center">
                  {stat.description}
                  <ArrowUpRight className="h-3 w-3 ml-1 opacity-0 group-hover:opacity-100 transition-opacity" />
                </p>
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Activities - Takes 2 columns */}
        <Card className="col-span-1 lg:col-span-2 border-2">
          <CardHeader className="border-b bg-gradient-to-r from-blue-50 to-purple-50">
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="flex items-center gap-2">
                  <Activity className="h-5 w-5 text-blue-600" />
                  Hoạt động Gần đây
                </CardTitle>
                <CardDescription className="mt-1">
                  Theo dõi các hoạt động mới nhất trong hệ thống
                </CardDescription>
              </div>
              <Button variant="ghost" size="sm">
                <Filter className="h-4 w-4 mr-2" />
                Lọc
              </Button>
            </div>
          </CardHeader>
          <CardContent className="pt-6">
            <div className="space-y-4 max-h-[500px] overflow-y-auto pr-2">
              {activities?.length === 0 ? (
                <div className="text-center py-12">
                  <Activity className="h-12 w-12 mx-auto text-gray-300 mb-3" />
                  <p className="text-sm text-muted-foreground">Chưa có hoạt động nào</p>
                </div>
              ) : (
                activities?.map((activity: any, i: number) => (
                  <div key={i} className="flex items-start gap-4 p-4 rounded-lg hover:bg-gray-50 transition-colors border border-transparent hover:border-gray-200">
                    <div className={`h-10 w-10 rounded-full flex items-center justify-center shrink-0 ${activity.status === 'success' ? 'bg-green-100' :
                      activity.status === 'pending' ? 'bg-yellow-100' :
                        activity.status === 'cancelled' ? 'bg-red-100' : 'bg-blue-100'
                      }`}>
                      {activity.status === 'success' ? (
                        <CheckCircle2 className="h-5 w-5 text-green-600" />
                      ) : activity.status === 'pending' ? (
                        <AlertCircle className="h-5 w-5 text-yellow-600" />
                      ) : activity.status === 'cancelled' ? (
                        <XCircle className="h-5 w-5 text-red-600" />
                      ) : (
                        <Activity className="h-5 w-5 text-blue-600" />
                      )}
                    </div>
                    <div className="space-y-1 flex-1 min-w-0">
                      <p className="text-sm font-medium leading-none">
                        <span className="font-bold text-gray-900">{activity.user_name}</span>
                        <span className="text-gray-600 ml-1">{activity.action?.toLowerCase()}</span>
                      </p>
                      <p className="text-xs text-muted-foreground truncate">
                        {activity.user_email}
                      </p>
                      <Badge variant="outline" className="text-xs mt-1">
                        {activity.status}
                      </Badge>
                    </div>
                    <div className="text-xs text-muted-foreground flex items-center gap-1 shrink-0">
                      <Clock className="h-3 w-3" />
                      {formatDistanceToNow(new Date(activity.timestamp), { addSuffix: true, locale: vi })}
                    </div>
                  </div>
                ))
              )}
            </div>
          </CardContent>
        </Card>

        {/* Quick Stats - Takes 1 column */}
        <div className="space-y-6">
          <Card className="border-2">
            <CardHeader className="border-b bg-gradient-to-r from-emerald-50 to-teal-50">
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="h-5 w-5 text-emerald-600" />
                Thống kê Nhanh
              </CardTitle>
            </CardHeader>
            <CardContent className="pt-6">
              <div className="space-y-4">
                <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                  <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center">
                      <Users className="h-5 w-5 text-blue-600" />
                    </div>
                    <div>
                      <p className="text-xs text-gray-600">Người dùng mới</p>
                      <p className="text-lg font-bold">+{Math.floor((users?.length || 0) * 0.15)}</p>
                    </div>
                  </div>
                  <Badge variant="default" className="bg-blue-600">Tháng này</Badge>
                </div>

                <div className="flex items-center justify-between p-3 bg-purple-50 rounded-lg">
                  <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-full bg-purple-100 flex items-center justify-center">
                      <Calendar className="h-5 w-5 text-purple-600" />
                    </div>
                    <div>
                      <p className="text-xs text-gray-600">Lịch hẹn hoàn thành</p>
                      <p className="text-lg font-bold">{Math.floor((appointments?.length || 0) * 0.7)}</p>
                    </div>
                  </div>
                  <Badge variant="default" className="bg-purple-600">Tuần này</Badge>
                </div>

                <div className="flex items-center justify-between p-3 bg-emerald-50 rounded-lg">
                  <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-full bg-emerald-100 flex items-center justify-center">
                      <UserCog className="h-5 w-5 text-emerald-600" />
                    </div>
                    <div>
                      <p className="text-xs text-gray-600">Tỷ lệ hài lòng</p>
                      <p className="text-lg font-bold">96%</p>
                    </div>
                  </div>
                  <Badge variant="default" className="bg-emerald-600">Excellent</Badge>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="border-2">
            <CardHeader className="border-b bg-gradient-to-r from-amber-50 to-orange-50">
              <CardTitle className="text-sm">Truy cập Nhanh</CardTitle>
            </CardHeader>
            <CardContent className="pt-4">
              <div className="space-y-2">
                <Link href="/dashboard/users">
                  <Button variant="outline" className="w-full justify-start" size="sm">
                    <Users className="h-4 w-4 mr-2" />
                    Quản lý Người dùng
                  </Button>
                </Link>
                <Link href="/dashboard/doctors">
                  <Button variant="outline" className="w-full justify-start" size="sm">
                    <UserCog className="h-4 w-4 mr-2" />
                    Quản lý Bác sĩ
                  </Button>
                </Link>
                <Link href="/dashboard/appointments">
                  <Button variant="outline" className="w-full justify-start" size="sm">
                    <Calendar className="h-4 w-4 mr-2" />
                    Quản lý Lịch hẹn
                  </Button>
                </Link>
                <Link href="/dashboard/prescriptions">
                  <Button variant="outline" className="w-full justify-start" size="sm">
                    <Pill className="h-4 w-4 mr-2" />
                    Quản lý Đơn thuốc
                  </Button>
                </Link>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
