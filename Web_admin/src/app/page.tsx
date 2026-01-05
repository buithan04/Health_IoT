"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";

export default function HomePage() {
    const router = useRouter();

    useEffect(() => {
        // Check if user is authenticated
        const token = localStorage.getItem('adminToken');

        if (token) {
            // If authenticated, redirect to dashboard
            router.replace('/dashboard');
        } else {
            // If not authenticated, redirect to login
            router.replace('/auth/login');
        }
    }, [router]);

    // Show loading state while redirecting
    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-100">
            <div className="text-center">
                <Loader2 className="h-8 w-8 animate-spin text-blue-600 mx-auto" />
                <p className="mt-2 text-gray-600">Đang chuyển hướng...</p>
            </div>
        </div>
    );
}
