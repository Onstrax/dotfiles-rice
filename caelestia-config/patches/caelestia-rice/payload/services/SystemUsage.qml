pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real cpuPerc: 0
    property real lastCpuIdle: 0
    property real lastCpuTotal: 0
    property int refCount: 0

    Timer {
        running: root.refCount > 0
        interval: 700
        repeat: true
        triggeredOnStart: true
        onTriggered: stat.reload()
    }

    FileView {
        id: stat

        path: "/proc/stat"
        onLoaded: {
            const data = text().match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
            if (!data)
                return;

            const stats = data.slice(1).map(n => parseInt(n, 10));
            const total = stats.reduce((a, b) => a + b, 0);
            const idle = stats[3] + (stats[4] ?? 0);

            const totalDiff = total - root.lastCpuTotal;
            const idleDiff = idle - root.lastCpuIdle;

            root.cpuPerc = totalDiff > 0 ? Math.max(0, Math.min(1, 1 - idleDiff / totalDiff)) : 0;

            root.lastCpuTotal = total;
            root.lastCpuIdle = idle;
        }
    }
}
