import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

interface Metrics {
  time: string;
  cpu: number;
  ram_used: number;
  ram_total: number;
  disk_used: number;
  disk_total: number;
  net_rx: number;
  net_tx: number;
}

function App() {
  const [data, setData] = useState<Metrics[]>([]);

  const fetchMetrics = async () => {
    try {
      const res = await fetch("http://103.160.37.103:9000/api/latest");
      const json = await res.json();

      if (json.status === "ok") {
        const cleaned = json.data.map((d: any) => ({
          time: d.time,
          cpu: d.cpu,
          ram_used: d.ram_used,
          ram_total: d.ram_total,
          disk_used: Number(d.disk_used.replace("G", "")),
          disk_total: Number(d.disk_total.replace("G", "")),
          net_rx: d.net_rx,
          net_tx: d.net_tx,
        }));

        // Urutkan dari lama → baru supaya grafik tampil dengan benar
        setData(cleaned.reverse());
      }
    } catch (err) {
      console.error("Error fetch:", err);
    }
  };

  useEffect(() => {
    fetchMetrics();
    const interval = setInterval(fetchMetrics, 3600000);
    return () => clearInterval(interval);
  }, []);

  const latest = data.length > 0 ? data[data.length - 1] : null;

  return (
    <div className="min-h-screen w-full bg-gray-900 text-white p-6">
      <h1 className="text-4xl font-bold mb-8">Server Monitoring Dashboard</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 w-full">

        {/* CPU */}
        <Card className="bg-gray-800 p-4">
          <CardHeader><CardTitle>CPU Usage (%)</CardTitle></CardHeader>
          <CardContent>
            {latest && (
              <div className="mb-2 text-sm text-gray-300">
                {`CPU: ${latest.cpu} %`}
              </div>
            )}
            <ResponsiveContainer width="100%" height={150}>
              <LineChart data={data}>
                <Line type="monotone" dataKey="cpu" stroke="#22d3ee" />
                <XAxis dataKey="time" hide />
                <YAxis hide />
                <Tooltip />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* RAM */}
        <Card className="bg-gray-800 p-4">
          <CardHeader><CardTitle>RAM Usage (MB)</CardTitle></CardHeader>
          <CardContent>
            {latest && (
              <div className="mb-2 text-sm text-gray-300">
                {`Used: ${latest.ram_used} MB / Total: ${latest.ram_total} MB`}
              </div>
            )}
            <ResponsiveContainer width="100%" height={150}>
              <LineChart data={data}>
                <Line type="monotone" dataKey="ram_used" stroke="#60a5fa" />
                <XAxis dataKey="time" hide />
                <YAxis hide />
                <Tooltip />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Disk */}
        <Card className="bg-gray-800 p-4">
          <CardHeader><CardTitle>Disk Usage (GB)</CardTitle></CardHeader>
          <CardContent>
            {latest && (
              <div className="mb-2 text-sm text-gray-300">
                {`Used: ${latest.disk_used} GB / Total: ${latest.disk_total} GB`}
              </div>
            )}
            <ResponsiveContainer width="100%" height={150}>
              <LineChart data={data}>
                <Line type="monotone" dataKey="disk_used" stroke="#fbbf24" />
                <XAxis dataKey="time" hide />
                <YAxis hide />
                <Tooltip />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Network */}
        <Card className="bg-gray-800 p-4">
          <CardHeader><CardTitle>Network (RX / TX)</CardTitle></CardHeader>
          <CardContent>
            {latest && (
              <div className="mb-2 text-sm text-gray-300">
                {`RX: ${latest.net_rx}  TX: ${latest.net_tx}`}
              </div>
            )}
            <ResponsiveContainer width="100%" height={150}>
              <LineChart data={data}>
                <Line type="monotone" dataKey="net_rx" stroke="#a855f7" />
                <Line type="monotone" dataKey="net_tx" stroke="#ec4899" />
                <XAxis dataKey="time" hide />
                <YAxis hide />
                <Tooltip />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

      </div>
    </div>
  );
}

export default App;

