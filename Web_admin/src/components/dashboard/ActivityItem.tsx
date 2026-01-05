import { Activity, CheckCircle2, AlertCircle, XCircle, Clock } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { formatDistanceToNow } from "date-fns";
import { vi } from "date-fns/locale";

interface ActivityItemProps {
    activity: {
        user_name: string;
        action: string;
        user_email: string;
        status: string;
        timestamp: string;
    };
}

export function ActivityItem({ activity }: ActivityItemProps) {
    const getStatusIcon = () => {
        switch (activity.status) {
            case 'success':
            case 'completed':
                return <CheckCircle2 className="h-5 w-5 text-green-600" />;
            case 'pending':
                return <AlertCircle className="h-5 w-5 text-yellow-600" />;
            case 'cancelled':
            case 'failed':
                return <XCircle className="h-5 w-5 text-red-600" />;
            default:
                return <Activity className="h-5 w-5 text-blue-600" />;
        }
    };

    const getStatusBg = () => {
        switch (activity.status) {
            case 'success':
            case 'completed':
                return 'bg-green-100';
            case 'pending':
                return 'bg-yellow-100';
            case 'cancelled':
            case 'failed':
                return 'bg-red-100';
            default:
                return 'bg-blue-100';
        }
    };

    return (
        <div className="flex items-start gap-4 p-4 rounded-lg hover:bg-gray-50 transition-colors border border-transparent hover:border-gray-200">
            <div className={`h-10 w-10 rounded-full flex items-center justify-center shrink-0 ${getStatusBg()}`}>
                {getStatusIcon()}
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
    );
}
