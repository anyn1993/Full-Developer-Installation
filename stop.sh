#!/bin/bash

echo "================================================"
echo "  Stopping Developer Tools Stack"
echo "================================================"
echo ""

echo "🛑 Stopping services..."

docker compose down

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All services stopped successfully!"
    echo ""
    echo "📝 Your data is preserved in Docker volumes."
    echo "   Run './start.sh' to start services again."
    echo ""
    echo "⚠️  To remove all data and volumes, run:"
    echo "   docker compose down -v"
    echo ""
else
    echo ""
    echo "❌ Failed to stop services. Check errors above."
    exit 1
fi
