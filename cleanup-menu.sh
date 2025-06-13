#!/bin/bash

echo "🧹 MENÚ DE LIMPIEZA DE PODS KUBERNETES"
echo "======================================"
echo ""
echo "Selecciona una opción:"
echo ""
echo "1. 🚀 Limpieza rápida (elimina pods específicos problemáticos)"
echo "2. 🔧 Limpieza inteligente (detecta y elimina pods con errores)"
echo "3. 🔥 Limpieza completa (elimina todo y redespliega desde cero)"
echo "4. 📊 Solo mostrar estado actual"
echo "5. 🚫 Cancelar"
echo ""

read -p "Ingresa tu opción (1-5): " option

case $option in
    1)
        echo ""
        echo "🚀 Ejecutando limpieza rápida..."
        ./quick-cleanup-pods.sh
        ;;
    2)
        echo ""
        echo "🔧 Ejecutando limpieza inteligente..."
        ./cleanup-duplicate-pods.sh
        ;;
    3)
        echo ""
        echo "🔥 Ejecutando limpieza completa..."
        ./force-cleanup-all.sh
        ;;
    4)
        echo ""
        echo "📊 Estado actual del cluster:"
        echo "=============================="
        echo ""
        echo "Pods en namespace ecommerce:"
        kubectl get pods -n ecommerce
        echo ""
        echo "Servicios en namespace ecommerce:"
        kubectl get svc -n ecommerce
        echo ""
        echo "Deployments en namespace ecommerce:"
        kubectl get deployments -n ecommerce
        ;;
    5)
        echo ""
        echo "🚫 Operación cancelada"
        ;;
    *)
        echo ""
        echo "❌ Opción inválida. Por favor selecciona 1-5."
        ;;
esac

echo ""
echo "💡 Comandos útiles:"
echo "   kubectl get pods -n ecommerce -w    # Monitorear pods en tiempo real"
echo "   kubectl logs -f POD_NAME -n ecommerce    # Ver logs de un pod específico" 