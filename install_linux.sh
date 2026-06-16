#!/bin/bash
set -e

APP_NAME="ibrahim"
APP_ID="com.ibrahim.islamic.ibrahim"
APP_DISPLAY_NAME="إبراهيم — Ibrahim Islamic App"
APP_COMMENT="تطبيق إسلامي شامل للمسلم العصري"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build/linux/x64/release/bundle"

# 1. Verify build exists
if [ ! -f "$BUILD_DIR/$APP_NAME" ]; then
  echo "❌ Build not found. Run 'flutter build linux --release' first."
  exit 1
fi

echo "📦 Installing $APP_DISPLAY_NAME..."

# 2. Install to ~/.local/opt/ibrahim
INSTALL_DIR="$HOME/.local/opt/$APP_NAME"
mkdir -p "$INSTALL_DIR"
cp -r "$BUILD_DIR"/* "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/$APP_NAME"

echo "✅ Binary installed to $INSTALL_DIR"

# 3. Copy icon to app directory
cp "$SCRIPT_DIR/assets/images/app_icon.png" "$INSTALL_DIR/$APP_NAME.png"

echo "✅ App icon installed"

# 4. Install .desktop file
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_DIR/$APP_ID.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_DISPLAY_NAME
Comment=$APP_COMMENT
Exec=$INSTALL_DIR/$APP_NAME
Icon=$INSTALL_DIR/$APP_NAME.png
Terminal=false
Categories=Education;Religion;Utility;
Keywords=islam;quran;prayer;azkar;
StartupWMClass=$APP_NAME
EOF

chmod 644 "$DESKTOP_DIR/$APP_ID.desktop"

echo "✅ Desktop launcher created"

# 5. Update desktop database
update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

echo ""
echo "🎉 $APP_DISPLAY_NAME installed successfully!"
echo "🔍 Look for 'إبراهيم' in your application menu."
