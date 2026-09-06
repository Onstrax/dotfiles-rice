function check-reboot
    echo -e "\n\033[1;34m[1/4] Verificando Kernel e Initramfs...\033[0m"
    if sudo sh -c 'ls /boot/vmlinuz* /boot/initramfs*.img' >/dev/null 2>&1
        echo -e "\033[1;32m  ✔ Archivos de arranque presentes en /boot\033[0m"
    else
        echo -e "\033[1;31m  ✖ ALERTA: Faltan archivos críticos en /boot\033[0m"
    end
    
    echo -e "\n\033[1;34m[2/4] Verificando estado de DKMS...\033[0m"
    set -l dkms_error (dkms status 2>&1 | grep -iE "error|broken|missing")
    if test -z "$dkms_error"
        echo -e "\033[1;32m  ✔ Módulos DKMS en estado correcto\033[0m"
    else
        echo -e "\033[1;31m  ✖ ALERTA: Errores detectados en módulos DKMS\033[0m"
    end
    
    echo -e "\n\033[1;34m[3/4] Verificando sintaxis de /etc/fstab...\033[0m"
    if findmnt --verify >/dev/null 2>&1
        echo -e "\033[1;32m  ✔ Montajes en fstab verificados sin errores\033[0m"
    else
        echo -e "\033[1;31m  ✖ ALERTA: Problemas detectados en /etc/fstab\033[0m"
    end
    
    echo -e "\n\033[1;34m[4/4] Verificando estado de systemd-boot...\033[0m"
    if sudo bootctl status >/dev/null 2>&1
        echo -e "\033[1;32m  ✔ systemd-boot responde correctamente\033[0m"
    else
        echo -e "\033[1;31m  ✖ ALERTA: Problemas en la configuración del Boot Loader\033[0m"
    end
    echo ""
end
