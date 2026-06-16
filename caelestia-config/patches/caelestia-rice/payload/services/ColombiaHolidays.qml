pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property int startYear: 2026
    readonly property int endYear: 2045

    function pad(n: int): string {
        return n < 10 ? "0" + n : "" + n;
    }

    function keyFromDate(date: date): string {
        return date.getFullYear() + "-" + pad(date.getMonth() + 1) + "-" + pad(date.getDate());
    }

    function addDays(date: date, days: int): date {
        return new Date(date.getFullYear(), date.getMonth(), date.getDate() + days);
    }

    function nextMonday(date: date): date {
        const day = date.getDay();
        const delta = day === 1 ? 0 : (8 - day) % 7;
        return addDays(date, delta);
    }

    function easterSunday(year: int): date {
        const a = year % 19;
        const b = Math.floor(year / 100);
        const c = year % 100;
        const d = Math.floor(b / 4);
        const e = b % 4;
        const f = Math.floor((b + 8) / 25);
        const g = Math.floor((b - f + 1) / 3);
        const h = (19 * a + b - d - g + 15) % 30;
        const i = Math.floor(c / 4);
        const k = c % 4;
        const l = (32 + 2 * e + 2 * i - h - k) % 7;
        const m = Math.floor((a + 11 * h + 22 * l) / 451);
        const month = Math.floor((h + l - 7 * m + 114) / 31);
        const day = ((h + l - 7 * m + 114) % 31) + 1;
        return new Date(year, month - 1, day);
    }

    function addHoliday(map: var, date: date, name: string): void {
        const year = date.getFullYear();
        if (year < root.startYear || year > root.endYear)
            return;

        const key = keyFromDate(date);
        if (!map[key])
            map[key] = [];
        map[key].push(name);
    }

    function buildHolidays(): var {
        const map = {};

        for (let year = root.startYear; year <= root.endYear; year++) {
            const easter = easterSunday(year);

            addHoliday(map, new Date(year, 0, 1), "Año Nuevo");
            addHoliday(map, addDays(easter, -3), "Jueves Santo");
            addHoliday(map, addDays(easter, -2), "Viernes Santo");
            addHoliday(map, new Date(year, 4, 1), "Día del Trabajo");
            addHoliday(map, new Date(year, 6, 20), "Independencia de Colombia");
            addHoliday(map, new Date(year, 7, 7), "Batalla de Boyacá");
            addHoliday(map, new Date(year, 11, 8), "Inmaculada Concepción");
            addHoliday(map, new Date(year, 11, 25), "Navidad");

            addHoliday(map, nextMonday(new Date(year, 0, 6)), "Día de Reyes");
            addHoliday(map, nextMonday(new Date(year, 2, 19)), "Día de San José");
            addHoliday(map, nextMonday(addDays(easter, 39)), "Ascensión del Señor");
            addHoliday(map, nextMonday(addDays(easter, 60)), "Corpus Christi");
            addHoliday(map, nextMonday(addDays(easter, 68)), "Sagrado Corazón");
            addHoliday(map, nextMonday(new Date(year, 5, 29)), "San Pedro y San Pablo");
            addHoliday(map, nextMonday(new Date(year, 7, 15)), "Asunción de la Virgen");
            addHoliday(map, nextMonday(new Date(year, 9, 12)), "Día de la Diversidad Étnica y Cultural");
            addHoliday(map, nextMonday(new Date(year, 10, 1)), "Todos los Santos");
            addHoliday(map, nextMonday(new Date(year, 10, 11)), "Independencia de Cartagena");
            addHoliday(map, nextMonday(new Date(year, 6, 9)), "Nuestra Señora del Rosario de Chiquinquirá");
        }

        return map;
    }

    readonly property var holidays: buildHolidays()

    function namesFor(date: date): var {
        return holidays[keyFromDate(date)] ?? [];
    }

    function isHoliday(date: date): bool {
        return namesFor(date).length > 0;
    }

    function labelFor(date: date): string {
        return namesFor(date).join(", ");
    }
}
