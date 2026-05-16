#ifndef THEME_H
#define THEME_H

// ── B&B Admin Design System ──────────────────────────────────────────────────
// Mirrors the mobile app's premium dark glassmorphism palette.

namespace Theme {

// Background layers
constexpr auto BG           = "#060B18";
constexpr auto SURFACE      = "#0D1424";
constexpr auto SURFACE_HIGH = "#131C30";
constexpr auto CARD         = "#111827";

// Accent / brand
constexpr auto ACCENT       = "#B69EFF";
constexpr auto ACCENT_DEEP  = "#7C5CFC";
constexpr auto ACCENT_SOFT  = "#1A1535";
constexpr auto CYAN         = "#4FC3F7";

// Text
constexpr auto TEXT_PRIMARY   = "#F0F4FF";
constexpr auto TEXT_SECONDARY = "#B0BDDA";
constexpr auto TEXT_MUTED     = "#6B7A9F";

// Status
constexpr auto SUCCESS = "#34D399";
constexpr auto WARNING = "#FBBF24";
constexpr auto ERROR   = "#FF5370";
constexpr auto ERROR_BG= "#2D0A12";

// Borders
constexpr auto BORDER  = "rgba(255,255,255,0.08)";
constexpr auto BORDER2 = "rgba(255,255,255,0.12)";

// Full application QSS stylesheet
inline const char* QSS = R"(

/* ── Global ────────────────────────────────────────────────────────────────── */
QWidget {
    background-color: #060B18;
    color: #F0F4FF;
    font-family: "Segoe UI", "Inter", sans-serif;
    font-size: 13px;
    selection-background-color: #7C5CFC;
    selection-color: #F0F4FF;
}

/* ── Main Window ────────────────────────────────────────────────────────────── */
QMainWindow {
    background-color: #060B18;
}

/* ── Tool Bar ───────────────────────────────────────────────────────────────── */
QToolBar {
    background-color: #0D1424;
    border-bottom: 1px solid rgba(255,255,255,0.07);
    padding: 4px 12px;
    spacing: 10px;
}
QToolBar QLabel {
    color: #F0F4FF;
    font-size: 15px;
    font-weight: 700;
    letter-spacing: -0.3px;
}
QToolBar::separator {
    background: rgba(255,255,255,0.08);
    width: 1px;
    margin: 6px 8px;
}

/* ── Status Bar ─────────────────────────────────────────────────────────────── */
QStatusBar {
    background-color: #0D1424;
    border-top: 1px solid rgba(255,255,255,0.07);
    color: #6B7A9F;
    font-size: 12px;
}

/* ── Sidebar (QListWidget) ──────────────────────────────────────────────────── */
QListWidget {
    background-color: #0D1424;
    border: none;
    border-right: 1px solid rgba(255,255,255,0.07);
    outline: none;
    padding: 8px 0;
}
QListWidget::item {
    color: #6B7A9F;
    padding: 11px 20px;
    border-radius: 10px;
    margin: 2px 8px;
    font-size: 13px;
    font-weight: 500;
    border: none;
}
QListWidget::item:hover {
    background-color: rgba(182,158,255,0.07);
    color: #B0BDDA;
}
QListWidget::item:selected {
    background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
        stop:0 #7C5CFC, stop:1 #4FC3F7);
    color: #FFFFFF;
    font-weight: 700;
}

/* ── Stacked Widget / Tabs ──────────────────────────────────────────────────── */
QStackedWidget {
    background-color: #060B18;
    border: none;
}

/* ── Labels ─────────────────────────────────────────────────────────────────── */
QLabel {
    color: #B0BDDA;
    background: transparent;
}
QLabel[role="title"] {
    color: #F0F4FF;
    font-size: 18px;
    font-weight: 700;
}
QLabel[role="muted"] {
    color: #6B7A9F;
    font-size: 12px;
}
QLabel[role="error"] {
    color: #FF5370;
    background: rgba(255,83,112,0.10);
    border: 1px solid rgba(255,83,112,0.25);
    border-radius: 8px;
    padding: 6px 10px;
}

/* ── Line Edit ──────────────────────────────────────────────────────────────── */
QLineEdit {
    background-color: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.10);
    border-radius: 10px;
    color: #F0F4FF;
    padding: 9px 14px;
    font-size: 14px;
    selection-background-color: #7C5CFC;
}
QLineEdit:focus {
    border: 1.5px solid #7C5CFC;
    background-color: rgba(124,92,252,0.06);
    outline: none;
}
QLineEdit:hover:!focus {
    border: 1px solid rgba(255,255,255,0.18);
}
QLineEdit[echoMode="2"] {
    /* password field — same styling */
    letter-spacing: 2px;
}

/* ── Push Button ────────────────────────────────────────────────────────────── */
QPushButton {
    background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
        stop:0 #7C5CFC, stop:1 #4FC3F7);
    color: #FFFFFF;
    border: none;
    border-radius: 10px;
    padding: 9px 20px;
    font-size: 13px;
    font-weight: 700;
}
QPushButton:hover {
    background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
        stop:0 #9370FF, stop:1 #65CFFB);
}
QPushButton:pressed {
    background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
        stop:0 #6A4CE0, stop:1 #38A8D8);
}
QPushButton:disabled {
    background: rgba(255,255,255,0.06);
    color: #6B7A9F;
}

/* Outline / secondary button variant (objectName="outlineBtn") */
QPushButton#outlineBtn {
    background: rgba(255,255,255,0.05);
    border: 1px solid rgba(255,255,255,0.12);
    color: #B0BDDA;
}
QPushButton#outlineBtn:hover {
    background: rgba(255,255,255,0.09);
    color: #F0F4FF;
}

/* Danger button (objectName="dangerBtn") */
QPushButton#dangerBtn {
    background: rgba(255,83,112,0.12);
    border: 1px solid rgba(255,83,112,0.30);
    color: #FF5370;
}
QPushButton#dangerBtn:hover {
    background: rgba(255,83,112,0.22);
}

/* ── Check Box ──────────────────────────────────────────────────────────────── */
QCheckBox {
    color: #B0BDDA;
    spacing: 8px;
}
QCheckBox::indicator {
    width: 18px;
    height: 18px;
    border: 1.5px solid rgba(255,255,255,0.18);
    border-radius: 5px;
    background: rgba(255,255,255,0.04);
}
QCheckBox::indicator:checked {
    background: #7C5CFC;
    border-color: #7C5CFC;
    image: none;
}
QCheckBox::indicator:hover {
    border-color: #7C5CFC;
}

/* ── Combo Box ──────────────────────────────────────────────────────────────── */
QComboBox {
    background-color: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.10);
    border-radius: 10px;
    color: #F0F4FF;
    padding: 7px 36px 7px 12px;
    font-size: 13px;
    min-width: 120px;
}
QComboBox:hover {
    border: 1px solid rgba(255,255,255,0.18);
}
QComboBox:focus {
    border: 1.5px solid #7C5CFC;
}
QComboBox::drop-down {
    subcontrol-origin: padding;
    subcontrol-position: top right;
    width: 28px;
    border: none;
    background: transparent;
}
QComboBox::down-arrow {
    width: 10px;
    height: 10px;
    border-left: 2px solid #6B7A9F;
    border-bottom: 2px solid #6B7A9F;
    transform: rotate(-45deg);
    margin-right: 6px;
}
QComboBox QAbstractItemView {
    background-color: #131C30;
    border: 1px solid rgba(255,255,255,0.10);
    border-radius: 10px;
    color: #F0F4FF;
    selection-background-color: rgba(124,92,252,0.25);
    outline: none;
    padding: 4px;
}
QComboBox QAbstractItemView::item {
    padding: 8px 12px;
    border-radius: 6px;
}

/* ── Date Edit ──────────────────────────────────────────────────────────────── */
QDateEdit {
    background-color: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.10);
    border-radius: 10px;
    color: #F0F4FF;
    padding: 7px 12px;
    font-size: 13px;
}
QDateEdit:focus {
    border: 1.5px solid #7C5CFC;
}
QDateEdit::drop-down {
    subcontrol-origin: padding;
    subcontrol-position: top right;
    width: 24px;
    border: none;
    background: transparent;
}
QCalendarWidget {
    background-color: #131C30;
    color: #F0F4FF;
    border: 1px solid rgba(255,255,255,0.10);
    border-radius: 10px;
}
QCalendarWidget QAbstractItemView {
    background-color: #131C30;
    color: #F0F4FF;
    selection-background-color: #7C5CFC;
}
QCalendarWidget QToolButton {
    background: transparent;
    color: #B69EFF;
    font-weight: 700;
}

/* ── Table Widget ───────────────────────────────────────────────────────────── */
QTableWidget {
    background-color: #0D1424;
    alternate-background-color: #111827;
    border: 1px solid rgba(255,255,255,0.07);
    border-radius: 12px;
    gridline-color: rgba(255,255,255,0.05);
    color: #F0F4FF;
    font-size: 13px;
    outline: none;
}
QTableWidget::item {
    padding: 10px 14px;
    border: none;
}
QTableWidget::item:selected {
    background: rgba(124,92,252,0.18);
    color: #F0F4FF;
}
QTableWidget::item:hover {
    background: rgba(255,255,255,0.04);
}
QHeaderView {
    background-color: #131C30;
    border: none;
}
QHeaderView::section {
    background-color: #131C30;
    color: #6B7A9F;
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.6px;
    padding: 10px 14px;
    border: none;
    border-bottom: 1px solid rgba(255,255,255,0.07);
    text-transform: uppercase;
}
QHeaderView::section:first {
    border-top-left-radius: 12px;
}
QHeaderView::section:last {
    border-top-right-radius: 12px;
}
QHeaderView::section:hover {
    background-color: rgba(182,158,255,0.06);
}

/* ── Scroll Bar ─────────────────────────────────────────────────────────────── */
QScrollBar:vertical {
    background: transparent;
    width: 6px;
    margin: 0;
}
QScrollBar::handle:vertical {
    background: rgba(255,255,255,0.12);
    border-radius: 3px;
    min-height: 30px;
}
QScrollBar::handle:vertical:hover {
    background: rgba(182,158,255,0.35);
}
QScrollBar::add-line:vertical,
QScrollBar::sub-line:vertical {
    height: 0;
    background: none;
}
QScrollBar:horizontal {
    background: transparent;
    height: 6px;
}
QScrollBar::handle:horizontal {
    background: rgba(255,255,255,0.12);
    border-radius: 3px;
    min-width: 30px;
}
QScrollBar::handle:horizontal:hover {
    background: rgba(182,158,255,0.35);
}
QScrollBar::add-line:horizontal,
QScrollBar::sub-line:horizontal {
    width: 0;
    background: none;
}

/* ── Frame ──────────────────────────────────────────────────────────────────── */
QFrame {
    background-color: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.09);
    border-radius: 16px;
}
QFrame[frameShape="0"] {
    /* NoFrame — treat as plain container */
    background: transparent;
    border: none;
    border-radius: 0;
}

/* ── Dialog ─────────────────────────────────────────────────────────────────── */
QDialog {
    background-color: #0D1424;
    color: #F0F4FF;
}

/* ── Message Box ────────────────────────────────────────────────────────────── */
QMessageBox {
    background-color: #0D1424;
    color: #F0F4FF;
}
QMessageBox QLabel {
    color: #F0F4FF;
}
QMessageBox QPushButton {
    min-width: 80px;
}

/* ── Menu / Context Menu ────────────────────────────────────────────────────── */
QMenu {
    background-color: #131C30;
    border: 1px solid rgba(255,255,255,0.10);
    border-radius: 12px;
    padding: 6px;
    color: #F0F4FF;
}
QMenu::item {
    padding: 8px 16px;
    border-radius: 7px;
    font-size: 13px;
}
QMenu::item:selected {
    background: rgba(124,92,252,0.20);
    color: #F0F4FF;
}
QMenu::separator {
    height: 1px;
    background: rgba(255,255,255,0.07);
    margin: 4px 0;
}

/* ── Tooltip ────────────────────────────────────────────────────────────────── */
QToolTip {
    background-color: #131C30;
    color: #F0F4FF;
    border: 1px solid rgba(255,255,255,0.12);
    border-radius: 8px;
    padding: 6px 10px;
}

/* ── Form Layout label ──────────────────────────────────────────────────────── */
QFormLayout QLabel {
    color: #6B7A9F;
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.3px;
    padding-right: 8px;
}

)";

} // namespace Theme
#endif // THEME_H
