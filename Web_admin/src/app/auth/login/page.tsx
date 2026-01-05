"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Activity, Loader2 } from "lucide-react";
import { apiCall } from "@/utils/api";

export default function LoginPage() {
    const [isLoading, setIsLoading] = useState(false);
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const router = useRouter();

    async function onSubmit(event: React.FormEvent<HTMLFormElement>) {
        event.preventDefault();
        setIsLoading(true);
        setError("");

        try {
            const data = await apiCall('/auth/login', 'POST', { email, password });

            if (data && data.token) {
                if (data.role !== 'admin') {
                    setError("Tài khoản của bạn không có quyền truy cập trang quản trị.");
                    setIsLoading(false);
                    return;
                }

                // Save token and user info
                localStorage.setItem('adminToken', data.token);
                localStorage.setItem('adminUser', JSON.stringify({ email: email, role: data.role }));

                // Redirect to dashboard
                router.push("/dashboard");
            } else {
                setError("Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.");
            }
        } catch (err: any) {
            setError(err.message || "Có lỗi xảy ra khi đăng nhập.");
        } finally {
            setIsLoading(false);
        }
    }

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-100">
            <Card className="w-[400px] shadow-lg">
                <CardHeader className="space-y-1 text-center">
                    <div className="flex justify-center mb-4">
                        <div className="p-3 bg-blue-100 rounded-full">
                            <Activity className="h-8 w-8 text-blue-600" />
                        </div>
                    </div>
                    <CardTitle className="text-2xl font-bold text-blue-600">HealthAI Admin</CardTitle>
                    <CardDescription>
                        Đăng nhập để truy cập hệ thống quản trị
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <form onSubmit={onSubmit}>
                        <div className="grid w-full items-center gap-4">
                            <div className="flex flex-col space-y-1.5">
                                <Label htmlFor="email">Email</Label>
                                <Input
                                    id="email"
                                    placeholder="admin@healthai.com"
                                    type="email"
                                    required
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                />
                            </div>
                            <div className="flex flex-col space-y-1.5">
                                <Label htmlFor="password">Mật khẩu</Label>
                                <Input
                                    id="password"
                                    type="password"
                                    required
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                />
                            </div>
                            {error && (
                                <div className="text-red-500 text-sm text-center">{error}</div>
                            )}
                        </div>
                        <Button className="w-full mt-6 bg-blue-600 hover:bg-blue-700" type="submit" disabled={isLoading}>
                            {isLoading ? (
                                <>
                                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                    Đang xử lý...
                                </>
                            ) : (
                                "Đăng nhập"
                            )}
                        </Button>
                    </form>
                </CardContent>
                <CardFooter className="flex justify-center">
                    <p className="text-xs text-gray-500">
                        Quên mật khẩu? Liên hệ quản trị viên hệ thống.
                    </p>
                </CardFooter>
            </Card>
        </div>
    );
}
