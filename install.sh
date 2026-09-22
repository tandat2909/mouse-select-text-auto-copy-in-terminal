#!/bin/sh
# Trình cài đặt term-autocopy — bôi đen bằng chuột trong terminal là tự copy.
#
# - Phiên X11 (Xorg): cài daemon term-autocopy (Python/GTK).
# - Ubuntu / GNOME trên Wayland: cài GNOME Shell extension (GNOME 45+).
#
# Cài bản mới nhất:
#   curl -fsSL https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest/download/install.sh | sh
# Cài một phiên bản cụ thể:
#   curl -fsSL https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest/download/install.sh | TERM_AUTOCOPY_VERSION=v1.1.0 sh
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

EXT_UUID="term-autocopy@tandat2909.github.io"
EXT_ZIP="$EXT_UUID.shell-extension.zip"
EXT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/gnome-shell/extensions/$EXT_UUID"
MIN_GNOME=45

if [ -t 1 ]; then
    C_OK="$(printf '\033[32m')"; C_WARN="$(printf '\033[33m')"; C_ERR="$(printf '\033[31m')"; C_OFF="$(printf '\033[0m')"
else
    C_OK=""; C_WARN=""; C_ERR=""; C_OFF=""
fi
info() { printf '%s==>%s %s\n' "$C_OK" "$C_OFF" "$*"; }
warn() { printf '%s[!]%s %s\n' "$C_WARN" "$C_OFF" "$*" >&2; }
die()  { printf '%s[x]%s %s\n' "$C_ERR" "$C_OFF" "$*" >&2; exit 1; }

# ---------------------------------------------------------------- tiện ích

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

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
SUMS_READY=""

# Tải một file đính kèm của Release về $TMP_DIR/$1 và kiểm tra SHA256
fetch_asset() {
    name="$1"
    info "Tải $name ($VERSION) từ GitHub Releases..."
    download "$BASE_URL/$name" "$TMP_DIR/$name" \
        || die "Không tải được $BASE_URL/$name (sai phiên bản hoặc mất mạng?)"
    if [ -z "$SUMS_READY" ]; then
        download "$BASE_URL/SHA256SUMS" "$TMP_DIR/SHA256SUMS" || die "Không tải được SHA256SUMS."
        SUMS_READY=1
    fi
    expected="$(grep " $name\$" "$TMP_DIR/SHA256SUMS" | cut -d ' ' -f 1)"
    actual="$(sha256_of "$TMP_DIR/$name")"
    if [ -z "$actual" ]; then
        warn "Không có sha256sum/shasum — bỏ qua bước kiểm tra toàn vẹn."
    elif [ "$expected" != "$actual" ]; then
        die "Sai mã SHA256 của $name — file tải về bị hỏng hoặc bị thay đổi, dừng cài đặt."
    else
        info "Đã kiểm tra SHA256 của $name: khớp."
    fi
}

# Thư mục chứa install.sh khi chạy từ bản clone (rỗng khi chạy qua curl | sh)
SRC_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "")"
[ -n "$SRC_DIR" ] && [ -f "$SRC_DIR/install.sh" ] && [ -f "$SRC_DIR/term-autocopy" ] || SRC_DIR=""

# ---------------------------------------------------------------- GNOME extension

gnome_major_version() {
    gnome-shell --version 2>/dev/null | sed -n 's/^[^0-9]*\([0-9][0-9]*\).*/\1/p'
}

enabled_extensions_add() {
    cur="$(gsettings get org.gnome.shell enabled-extensions)"
    case "$cur" in
        *"'$EXT_UUID'"*) return 0 ;;
        "@as []"|"[]") new="['$EXT_UUID']" ;;
        *) new="${cur%]}, '$EXT_UUID']" ;;
    esac
    gsettings set org.gnome.shell enabled-extensions "$new"
}

enabled_extensions_remove() {
    cur="$(gsettings get org.gnome.shell enabled-extensions)"
    case "$cur" in *"'$EXT_UUID'"*) ;; *) return 0 ;; esac
    new="$(printf '%s' "$cur" | sed "s/, '$EXT_UUID'//; s/'$EXT_UUID', //; s/'$EXT_UUID'//")"
    [ "$new" = "[]" ] && new="@as []"
    gsettings set org.gnome.shell enabled-extensions "$new"
}

extract_zip() {
    # $1 = file zip, $2 = thư mục đích
    if command -v unzip >/dev/null 2>&1; then
        unzip -oq "$1" -d "$2"
    elif command -v python3 >/dev/null 2>&1; then
        python3 -m zipfile -e "$1" "$2"
    else
        die "Cần unzip hoặc python3 để giải nén extension."
    fi
}

install_gnome_extension() {
    command -v gnome-shell >/dev/null 2>&1 || die "Không tìm thấy gnome-shell."
    major="$(gnome_major_version)"
    [ -n "$major" ] || die "Không xác định được phiên bản GNOME Shell."
    if [ "$major" -lt "$MIN_GNOME" ]; then
        die "GNOME $major quá cũ cho extension (cần GNOME $MIN_GNOME+, tức Ubuntu 24.04 trở lên).
    Hãy đăng xuất, bấm biểu tượng ⚙️ ở màn hình đăng nhập, chọn \"Ubuntu on Xorg\" rồi chạy lại lệnh cài."
    fi
    info "GNOME Shell $major trên Wayland — cài GNOME Shell extension."

    # chuẩn bị bản mới trong thư mục tạm, kiểm tra xong mới thay bản đang cài
    staged="$TMP_DIR/extension"
    mkdir -p "$staged"
    if [ -n "$SRC_DIR" ] && [ -f "$SRC_DIR/gnome-extension/$EXT_UUID/metadata.json" ]; then
        cp -R "$SRC_DIR/gnome-extension/$EXT_UUID/." "$staged/"
        info "Dùng extension từ thư mục $SRC_DIR"
    else
        fetch_asset "$EXT_ZIP"
        extract_zip "$TMP_DIR/$EXT_ZIP" "$staged"
    fi
    [ -f "$staged/metadata.json" ] && [ -f "$staged/extension.js" ] || die "Gói extension không đầy đủ."
    rm -rf "$EXT_DIR"
    mkdir -p "$(dirname "$EXT_DIR")"
    cp -R "$staged" "$EXT_DIR"
    info "Đã cài extension vào $EXT_DIR"

    if command -v gsettings >/dev/null 2>&1; then
        enabled_extensions_add || warn "Không bật được extension qua gsettings."
        if [ "$(gsettings get org.gnome.shell disable-user-extensions 2>/dev/null)" = "true" ]; then
            warn "GNOME đang tắt toàn bộ extension của người dùng. Bật lại bằng lệnh:
      gsettings set org.gnome.shell disable-user-extensions false"
        fi
        # nếu GNOME đã nhận extension (vd. cài lại) thì bật ngay, không cần đăng nhập lại
        gnome-extensions enable "$EXT_UUID" >/dev/null 2>&1 || true
        info "Đã bật extension $EXT_UUID"
    else
        warn "Không có gsettings — hãy bật extension bằng ứng dụng Extensions sau khi đăng nhập lại."
    fi

    echo
    info "Xong! ĐĂNG XUẤT rồi ĐĂNG NHẬP LẠI để GNOME nạp extension (Wayland không nạp nóng được)."
    info "Sau đó bôi đen chữ trong terminal rồi bấm Ctrl+V ở nơi khác để dán."
}

uninstall_gnome_extension() {
    [ -d "$EXT_DIR" ] || return 0
    gnome-extensions disable "$EXT_UUID" >/dev/null 2>&1 || true
    if command -v gsettings >/dev/null 2>&1; then
        enabled_extensions_remove >/dev/null 2>&1 || true
    fi
    rm -rf "$EXT_DIR"
    info "Đã gỡ GNOME Shell extension."
}

# ---------------------------------------------------------------- bản X11 (Python/GTK)

stop_running() {
    pkill -f "^python3 $BIN\$" 2>/dev/null || true
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

install_x11() {
    if ! has_deps; then
        install_deps
        has_deps || die "Vẫn thiếu thư viện sau khi cài (python3, PyGObject GTK 3, xprop)."
    fi
    info "Đã đủ thư viện (python3, GTK 3, xprop)."

    if [ -n "$SRC_DIR" ]; then
        cp "$SRC_DIR/term-autocopy" "$TMP_DIR/term-autocopy"
        info "Dùng term-autocopy từ thư mục $SRC_DIR"
    else
        fetch_asset term-autocopy
    fi
    head -n 1 "$TMP_DIR/term-autocopy" | grep -q "python3" || die "File tải về không hợp lệ."

    mkdir -p "$BIN_DIR" "$AUTOSTART_DIR"
    stop_running
    install -m 755 "$TMP_DIR/term-autocopy" "$BIN"
    info "Đã cài $("$BIN" --version 2>/dev/null || echo term-autocopy) vào $BIN"

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

    if [ -n "${DISPLAY:-}" ]; then
        (setsid nohup "$BIN" >/dev/null 2>&1 </dev/null &) 2>/dev/null \
            || (nohup "$BIN" >/dev/null 2>&1 </dev/null &)
        sleep 1
        if pgrep -f "^python3 $BIN\$" >/dev/null 2>&1; then
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
}

uninstall_x11() {
    [ -e "$BIN" ] || [ -e "$DESKTOP" ] || return 0
    stop_running
    rm -f "$BIN" "$DESKTOP"
    info "Đã gỡ term-autocopy (bản X11)."
}

# ---------------------------------------------------------------- chạy

case "${1:-}" in
    --uninstall|uninstall)
        uninstall_x11
        uninstall_gnome_extension
        info "Đã gỡ xong."
        exit 0 ;;
    ""|--install|install) ;;
    -h|--help)
        echo "Dùng: install.sh [--uninstall]"; exit 0 ;;
    *) die "Tham số không hợp lệ: $1 (dùng --uninstall để gỡ)" ;;
esac

[ "$(uname -s)" = "Linux" ] || die "term-autocopy chỉ chạy trên Linux."

if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    desktop="$(printf '%s' "${XDG_CURRENT_DESKTOP:-}" | tr '[:upper:]' '[:lower:]')"
    case "$desktop" in
        *gnome*)
            install_gnome_extension ;;
        *kde*)
            die "KDE Plasma trên Wayland đã có sẵn tính năng này, không cần cài:
    chuột phải biểu tượng Clipboard ở khay hệ thống → Cấu hình → bật
    \"Đồng bộ nội dung của clipboard và vùng chọn\" (Synchronize contents of the clipboard and the selection)." ;;
        *)
            die "Wayland với desktop \"${XDG_CURRENT_DESKTOP:-không rõ}\" chưa được hỗ trợ.
    Với Sway/Hyprland (wlroots) có thể dùng: wl-paste --primary --watch wl-copy
    hoặc đăng nhập bằng phiên X11 rồi chạy lại lệnh cài." ;;
    esac
else
    install_x11
fi
