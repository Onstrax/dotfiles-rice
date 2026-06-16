pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property int tick: 0

    property int stopwatchElapsedMs: 0
    property bool stopwatchRunning: false
    property double stopwatchStartedAt: 0

    readonly property int stopwatchDisplayMs: root.tick >= 0
        ? (root.stopwatchRunning
            ? root.stopwatchElapsedMs + Math.max(0, Math.floor(Date.now() - root.stopwatchStartedAt))
            : root.stopwatchElapsedMs)
        : root.stopwatchElapsedMs

    property int timerDurationSeconds: 5 * 60
    property int timerRemainingSeconds: timerDurationSeconds
    property int timerBaseRemainingSeconds: timerDurationSeconds
    property bool timerRunning: false
    property bool timerFinished: false
    property bool timerNotified: false
    property double timerStartedAt: 0

    readonly property int timerDisplaySeconds: root.tick >= 0
        ? (root.timerRunning
            ? Math.max(0, root.timerBaseRemainingSeconds - Math.floor((Date.now() - root.timerStartedAt) / 1000))
            : root.timerRemainingSeconds)
        : root.timerRemainingSeconds

    Timer {
        interval: 250
        repeat: true
        running: root.stopwatchRunning || root.timerRunning
        onTriggered: {
            root.tick++;

            if (root.timerRunning) {
                const remaining = root.timerBaseRemainingSeconds - Math.floor((Date.now() - root.timerStartedAt) / 1000);

                if (remaining <= 0) {
                    root.timerRemainingSeconds = 0;
                    root.timerRunning = false;
                    root.timerFinished = true;
                    root.notifyTimerFinished();
                } else {
                    root.timerRemainingSeconds = remaining;
                }
            }
        }
    }

    function notifyTimerFinished(): void {
        if (root.timerNotified)
            return;

        root.timerNotified = true;
        Quickshell.execDetached(["bash", Quickshell.shellPath("scripts/timer_finished.sh")]);
    }

    function startStopwatch(): void {
        if (root.stopwatchRunning)
            return;

        root.stopwatchStartedAt = Date.now();
        root.stopwatchRunning = true;
    }

    function pauseStopwatch(): void {
        if (!root.stopwatchRunning)
            return;

        root.stopwatchElapsedMs = root.stopwatchDisplayMs;
        root.stopwatchRunning = false;
    }

    function toggleStopwatch(): void {
        if (root.stopwatchRunning)
            pauseStopwatch();
        else
            startStopwatch();
    }

    function resetStopwatch(): void {
        root.stopwatchRunning = false;
        root.stopwatchElapsedMs = 0;
        root.stopwatchStartedAt = 0;
        root.tick++;
    }

    function setTimerDuration(seconds: int): void {
        const next = Math.max(1, Math.min(seconds, 24 * 60 * 60));
        root.timerDurationSeconds = next;
        root.timerFinished = false;
        root.timerNotified = false;

        if (!root.timerRunning)
            root.timerRemainingSeconds = next;

        root.tick++;
    }

    function startTimer(): void {
        if (root.timerRunning)
            return;

        if (root.timerRemainingSeconds <= 0)
            root.timerRemainingSeconds = root.timerDurationSeconds;

        root.timerBaseRemainingSeconds = root.timerRemainingSeconds;
        root.timerStartedAt = Date.now();
        root.timerRunning = true;
        root.timerFinished = false;
        root.timerNotified = false;
        root.tick++;
    }

    function pauseTimer(): void {
        if (!root.timerRunning)
            return;

        root.timerRemainingSeconds = root.timerDisplaySeconds;
        root.timerRunning = false;
        root.tick++;
    }

    function toggleTimer(): void {
        if (root.timerRunning)
            pauseTimer();
        else
            startTimer();
    }

    function resetTimer(): void {
        root.timerRunning = false;
        root.timerFinished = false;
        root.timerNotified = false;
        root.timerRemainingSeconds = root.timerDurationSeconds;
        root.timerBaseRemainingSeconds = root.timerDurationSeconds;
        root.timerStartedAt = 0;
        root.tick++;
    }

    function two(n: int): string {
        return n < 10 ? "0" + n : "" + n;
    }

    function formatSeconds(totalSeconds: int): string {
        const safe = Math.max(0, totalSeconds);
        const hours = Math.floor(safe / 3600);
        const minutes = Math.floor((safe % 3600) / 60);
        const seconds = safe % 60;

        return hours > 0
            ? hours + ":" + two(minutes) + ":" + two(seconds)
            : two(minutes) + ":" + two(seconds);
    }

    function formatMs(ms: int): string {
        return formatSeconds(Math.floor(ms / 1000));
    }
}
