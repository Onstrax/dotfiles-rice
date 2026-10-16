function imprimir --description 'Valida red poderoso, escala al tamaño del papel, fuerza Carta + Doble Cara, e imprime'
    # 1. Mostrar advertencia visual de red
    set_color yellow
    echo "⚠️  Recuerda: La red debe ser \"poderoso\", NO \"poderoso 2.4\" ni \"poderoso 5.0\"."
    set_color normal
    
    # 2. Obtener la IP limpia de la interfaz wlan0
    set -l ip_actual (ip -o -4 addr show dev wlan0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
    
    # 3. Validar si la IP pertenece al rango correcto (192.168.10.X)
    if string match -q "192.168.10.*" "$ip_actual"
        set_color green
        echo "✅ Red verificada correctamente (Tu IP: $ip_actual)."
        echo "🖨️  Configurando parámetros obligatorios (Carta + Doble Cara + Ajustar a la página)..."
        set_color normal
        
        # Ejecutar la impresión forzando el auto-ajuste de tamaño (-o fit-to-page)
        lp -d HP_Officejet_Pro_8620 \
                       -o OptionDuplex=True \
                       -o PageSize=Letter \
                       -o Duplex=DuplexNoTumble \
                       -o fit-to-page \
                       $argv
    else
        set_color red
        echo "❌ ERROR: No estás en la red correcta."
        echo "   Tu IP actual es: '$ip_actual' (Debería ser 192.168.10.X)"
        echo "   Por favor, conéctate a \"poderoso\" e inténtalo de nuevo."
        set_color normal
        return 1
    end
end
