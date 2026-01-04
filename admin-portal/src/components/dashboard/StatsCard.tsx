import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ArrowUpRight, LucideIcon } from "lucide-react";
import Link from "next/link";

interface StatsCardProps {
    title: string;
    value: number | string;
    icon: LucideIcon;
    color: string;
    bg: string;
    border: string;
    change?: string;
    changeType?: "increase" | "decrease" | "neutral";
    description: string;
    link?: string;
}

export function StatsCard({
    title,
    value,
    icon: Icon,
    color,
    bg,
    border,
    change,
    changeType = "neutral",
    description,
    link = "#"
}: StatsCardProps) {
    return (
        <Link href={link}>
            <Card className={`hover:shadow-lg transition-all duration-300 border-2 ${border} cursor-pointer group h-full`}>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                    <CardTitle className="text-sm font-medium text-gray-600">
                        {title}
                    </CardTitle>
                    <div className={`p-3 rounded-xl ${bg} group-hover:scale-110 transition-transform`}>
                        <Icon className={`h-5 w-5 ${color}`} />
                    </div>
                </CardHeader>
                <CardContent>
                    <div className="flex items-baseline justify-between">
                        <div className="text-3xl font-bold text-gray-900">{value}</div>
                        {change && (
                            <Badge
                                variant={changeType === 'increase' ? 'default' : changeType === 'decrease' ? 'destructive' : 'secondary'}
                                className="text-xs"
                            >
                                {change}
                            </Badge>
                        )}
                    </div>
                    <p className="text-xs text-muted-foreground mt-2 flex items-center">
                        {description}
                        <ArrowUpRight className="h-3 w-3 ml-1 opacity-0 group-hover:opacity-100 transition-opacity" />
                    </p>
                </CardContent>
            </Card>
        </Link>
    );
}
