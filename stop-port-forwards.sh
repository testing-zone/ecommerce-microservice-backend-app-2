#!/bin/bash

echo "🛑 DETENIENDO PORT-FORWARDS"
echo "==========================="

# Función para detener port-forwards por PID
stop_by_pids() {
    if [ -f "/tmp/ecommerce-port-forwards.pids" ]; then
        echo "🔍 Deteniendo port-forwards por PID guardado..."
        
        while read -r pid; do
            if [ -n "$pid" ] && ps -p "$pid" >/dev/null 2>&1; then
                echo "🛑 Deteniendo proceso $pid"
                kill "$pid" 2>/dev/null
                sleep 1
                
                if ps -p "$pid" >/dev/null 2>&1; then
                    echo "⚠️  Forzando detención del proceso $pid"
                    kill -9 "$pid" 2>/dev/null
                fi
            fi
        done < "/tmp/ecommerce-port-forwards.pids"
        
        rm -f "/tmp/ecommerce-port-forwards.pids"
    fi
}

# Función para detener port-forwards por nombre de proceso
stop_by_process_name() {
    echo "🔍 Buscando procesos kubectl port-forward..."
    
    # Buscar y detener procesos kubectl port-forward
    for pid in $(pgrep -f "kubectl.*port-forward" 2>/dev/null); do
        local cmd=$(ps -p $pid -o args= 2>/dev/null)
        echo "🛑 Deteniendo: $cmd"
        kill "$pid" 2>/dev/null
        sleep 1
        
        if ps -p "$pid" >/dev/null 2>&1; then
            echo "⚠️  Forzando detención del proceso $pid"
            kill -9 "$pid" 2>/dev/null
        fi
    done
}

# Función para liberar puertos específicos
stop_by_ports() {
    local ports=(8900 3000 9090 8080 8761 5601 16686)
    
    echo "🔍 Verificando puertos específicos..."
    
    for port in "${ports[@]}"; do
        local pid=$(lsof -ti :$port 2>/dev/null)
        if [ -n "$pid" ]; then
            local cmd=$(ps -p $pid -o comm= 2>/dev/null)
            echo "🛑 Liberando puerto $port (proceso: $cmd, PID: $pid)"
            kill "$pid" 2>/dev/null
            sleep 1
            
            if lsof -ti :$port >/dev/null 2>&1; then
                echo "⚠️  Forzando liberación del puerto $port"
                kill -9 "$pid" 2>/dev/null
            fi
        fi
    done
}

# Ejecutar todas las estrategias de limpieza
stop_by_pids
stop_by_process_name
stop_by_ports

echo ""
echo "🔍 Verificando estado final..."

# Verificar que los puertos estén libres
local freed_ports=()
local busy_ports=()

for port in 8900 3000 9090 8080 8761 5601 16686; do
    if lsof -ti :$port >/dev/null 2>&1; then
        busy_ports+=($port)
    else
        freed_ports+=($port)
    fi
done

if [ ${#freed_ports[@]} -gt 0 ]; then
    echo "✅ Puertos liberados: ${freed_ports[*]}"
fi

if [ ${#busy_ports[@]} -gt 0 ]; then
    echo "⚠️  Puertos aún ocupados: ${busy_ports[*]}"
    echo ""
    echo "🛠️ Para liberar manualmente:"
    for port in "${busy_ports[@]}"; do
        local pid=$(lsof -ti :$port 2>/dev/null)
        echo "   kill $pid  # Puerto $port"
    done
fi

echo ""
echo "📊 PORT-FORWARDS ACTIVOS RESTANTES:"
if pgrep -f "kubectl.*port-forward" >/dev/null 2>&1; then
    ps aux | grep "kubectl.*port-forward" | grep -v grep
else
    echo "   ✅ No hay port-forwards activos"
fi

echo ""
echo "🎉 Limpieza completada!"
echo ""
echo "🔄 Para volver a configurar port-forwards:"
echo "   ./setup-port-forwards.sh" 