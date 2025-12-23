#!/bin/sh
set -e

echo "==> Preparing database..."
bin/rails db:prepare

echo "==> Building Tailwind CSS..."
bin/rails tailwindcss:build

echo "==> Starting Rails server..."
exec bin/rails server -b 0.0.0.0

