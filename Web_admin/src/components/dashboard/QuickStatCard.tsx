import { Badge } from "@/components/ui/badge";
import { LucideIcon } from "lucide-react";

interface QuickStatCardProps {
    icon: LucideIcon;
    label: string;
    value: number | string;
    badge: string;
    bgColor: string;
    iconBgColor: string;
    iconColor: string;
    badgeColor: string;
}

export function QuickStatCard({
    icon: Icon,
    label,
    value,
    badge,
    bgColor,
    iconBgColor,
    iconColor,
    badgeColor
}: QuickStatCardProps) {
    return (
        <div className={`flex items-center justify-between p-3 ${bgColor} rounded-lg`}>
            <div className="flex items-center gap-3">
                <div className={`h-10 w-10 rounded-full ${iconBgColor} flex items-center justify-center`}>
                    <Icon className={`h-5 w-5 ${iconColor}`} />
                </div>
                <div>
                    <p className="text-xs text-gray-600">{label}</p>
                    <p className="text-lg font-bold">{value}</p>
                </div>
            </div>
            <Badge variant="default" className={badgeColor}>
                {badge}
            </Badge>
        </div>
    );
}
