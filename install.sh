#!/bin/sh
# Trình cài đặt term-autocopy — bôi đen bằng chuột trong terminal là tự copy.
#
# Cài bản mới nhất:
#   curl -fsSL https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest/download/install.sh | sh
# Cài một phiên bản cụ thể:
#   curl -fsSL https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest/download/install.sh | TERM_AUTOCOPY_VERSION=v1.0.0 sh
# Gỡ:
#   curl -fsSL https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest/download/install.sh | sh -s -- --uninstall
set -eu

REPO="tandat2909/mouse-select-text-auto-copy-in-terminal"
VERSION="${TERM_AUTOCOPY_VERSION:-latest}"
if [ "$VERSION" = "latest" ]; then
    DEFAULT_BASE_URL="https://github.com/$REPO/releases/latest/download"
else
    DEFAULT_BASE_URL="https://github.com/$REPO/releases/download/$VERSION"
fi
BASE_URL="${TERM_AUTOCOPY_BASE_URL:-$DEFAULT_BASE_URL}"
BIN_DIR="$HOME/.local/bin"
BIN="$BIN_DIR/term-autocopy"
AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
DESKTOP="$AUTOSTART_DIR/term-autocopy.desktop"

if [ -t 1 ]; then
    C_OK="$(printf '\033[32m')"; C_WARN="$(printf '\033[33m')"; C_ERR="$(printf '\033[31m')"; C_OFF="$(printf '\033[0m')"
else
    C_OK=""; C_WARN=""; C_ERR=""; C_OFF=""
fi
info() { printf '%s==>%s %s\n' "$C_OK" "$C_OFF" "$*"; }
warn() { printf '%s[!]%s %s\n' "$C_WARN" "$C_OFF" "$*" >&2; }
die()  { printf '%s[x]%s %s\n' "$C_ERR" "$C_OFF" "$*" >&2; exit 1; }

stop_running() {
    pkill -f "^python3 $BIN$" 2>/dev/null || true
}

uninstall() {
    stop_running
    rm -f "$BIN" "$DESKTOP"
    info "Đã gỡ term-autocopy."
    exit 0
}

has_deps() {
    command -v python3 >/dev/null 2>&1 \
        && command -v xprop >/dev/null 2>&1 \
        && python3 -c "import gi; gi.require_version('Gtk', '3.0'); from gi.repository import Gtk" >/dev/null 2>&1
}

install_deps() {
    if [ "$(id -u)" -eq 0 ]; then
        SUDO=""
    elif command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        die "Thiếu thư viện và không có sudo. Hãy tự cài: python3, PyGObject (GTK 3), xprop."
    fi
    if command -v apt-get >/dev/null 2>&1; then
        info "Cập nhật danh sách gói (apt-get update)..."
        $SUDO apt-get update -qq || die "apt-get update thất bại."
        set -- apt-get install -y python3 python3-gi gir1.2-gtk-3.0 x11-utils
    elif command -v dnf >/dev/null 2>&1; then
        set -- dnf install -y python3 python3-gobject gtk3 xprop
    elif command -v pacman >/dev/null 2>&1; then
        set -- pacman -S --needed --noconfirm python python-gobject gtk3 xorg-xprop
    elif command -v zypper >/dev/null 2>&1; then
        set -- zypper install -y python3 python3-gobject-Gdk typelib-1_0-Gtk-3_0 xprop
    else
        die "Không nhận ra trình quản lý gói. Hãy tự cài: python3, PyGObject (GTK 3), xprop."
    fi
    info "Cài thư viện còn thiếu: $*"
    $SUDO "$@" || die "Cài thư viện thất bại."
}

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | cut -d ' ' -f 1
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | cut -d ' ' -f 1
    fi
}

download() {
    # $1 = URL, $2 = file đích
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1" -o "$2"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$2" "$1"
    else
        die "Cần curl hoặc wget để tải file."
    fi
}

case "${1:-}" in
    --uninstall|uninstall) uninstall ;;
    ""|--install|install) ;;
    -h|--help)
        echo "Dùng: install.sh [--uninstall]"; exit 0 ;;
    *) die "Tham số không hợp lệ: $1 (dùng --uninstall để gỡ)" ;;
esac

[ "$(uname -s)" = "Linux" ] || die "term-autocopy chỉ chạy trên Linux."
if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    die "Phiên đăng nhập đang dùng Wayland — term-autocopy chỉ hỗ trợ X11 (Xorg)."
fi

# 1. thư viện
if ! has_deps; then
    install_deps
    has_deps || die "Vẫn thiếu thư viện sau khi cài (python3, PyGObject GTK 3, xprop)."
fi
info "Đã đủ thư viện (python3, GTK 3, xprop)."

# 2. lấy script: chạy từ bản clone thì dùng file cạnh install.sh,
#    còn lại tải từ GitHub Releases và kiểm tra SHA256
tmp="$(mktemp)"
sums="$(mktemp)"
trap 'rm -f "$tmp" "$sums"' EXIT
src_dir="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "")"
if [ -n "$src_dir" ] && [ -f "$src_dir/term-autocopy" ] && [ -f "$src_dir/install.sh" ]; then
    cp "$src_dir/term-autocopy" "$tmp"
    info "Dùng term-autocopy từ thư mục $src_dir"
else
    info "Tải term-autocopy ($VERSION) từ GitHub Releases..."
    download "$BASE_URL/term-autocopy" "$tmp" \
        || die "Không tải được $BASE_URL/term-autocopy (sai phiên bản hoặc mất mạng?)"
    download "$BASE_URL/SHA256SUMS" "$sums" || die "Không tải được SHA256SUMS."
    expected="$(grep ' term-autocopy$' "$sums" | cut -d ' ' -f 1)"
    actual="$(sha256_of "$tmp")"
    if [ -z "$actual" ]; then
        warn "Không có sha256sum/shasum — bỏ qua bước kiểm tra toàn vẹn."
    elif [ "$expected" != "$actual" ]; then
        die "Sai mã SHA256 — file tải về bị hỏng hoặc bị thay đổi, dừng cài đặt."
    else
        info "Đã kiểm tra SHA256: khớp."
    fi
fi
head -n 1 "$tmp" | grep -q "python3" || die "File tải về không hợp lệ."

mkdir -p "$BIN_DIR" "$AUTOSTART_DIR"
stop_running
install -m 755 "$tmp" "$BIN"
info "Đã cài $("$BIN" --version 2>/dev/null || echo term-autocopy) vào $BIN"

# 3. tự khởi động khi đăng nhập
cat > "$DESKTOP" <<EOF
[Desktop Entry]
Type=Application
Name=Terminal Auto Copy
Comment=Bôi đen trong terminal tự copy vào clipboard
Exec=$BIN
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=3
NoDisplay=false
Hidden=false
EOF
info "Đã bật tự khởi động: $DESKTOP"

# 4. chạy ngay
if [ -n "${DISPLAY:-}" ]; then
    (setsid nohup "$BIN" >/dev/null 2>&1 </dev/null &) 2>/dev/null \
        || (nohup "$BIN" >/dev/null 2>&1 </dev/null &)
    sleep 1
    if pgrep -f "^python3 $BIN$" >/dev/null 2>&1; then
        info "term-autocopy đang chạy."
    else
        warn "Chưa khởi động được, hãy thử chạy tay: $BIN"
    fi
else
    warn "Không có màn hình X (DISPLAY trống) — tool sẽ tự chạy ở lần đăng nhập sau."
fi

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) warn "$BIN_DIR chưa có trong PATH — thêm dòng sau vào ~/.bashrc để gõ lệnh ngắn:
      export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

echo
info "Xong! Bôi đen chữ trong terminal rồi bấm Ctrl+V ở nơi khác để dán."
