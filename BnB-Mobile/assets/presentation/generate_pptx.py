"""
B&B Real Estate & Home Services — Premium Presentation Generator
12-slide dark-luxury .pptx using real app screenshots and logo assets.
"""

import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from lxml import etree

# ── Palette ───────────────────────────────────────────────────────────────────
BG           = RGBColor(0x06, 0x0B, 0x18)
SURFACE      = RGBColor(0x0D, 0x14, 0x24)
SURFACE2     = RGBColor(0x13, 0x1C, 0x30)
ACCENT       = RGBColor(0x7C, 0x5C, 0xFC)
ACCENT_LIGHT = RGBColor(0xB6, 0x9E, 0xFF)
CYAN         = RGBColor(0x4F, 0xC3, 0xF7)
TEXT_PRI     = RGBColor(0xF0, 0xF4, 0xFF)
TEXT_SEC     = RGBColor(0xB0, 0xBD, 0xDA)
TEXT_MUTED   = RGBColor(0x6B, 0x7A, 0x9F)
SUCCESS      = RGBColor(0x34, 0xD3, 0x99)
WARNING      = RGBColor(0xFB, 0xBF, 0x24)
ERROR        = RGBColor(0xFF, 0x53, 0x70)

# ── Paths ─────────────────────────────────────────────────────────────────────
SS   = "D:/screenshopts/screenshopts_Mobile"
LOGO = "D:/BnB/BnB-Mobile/assets/logo"
OUT  = "D:/BnB/BnB-Mobile/assets/presentation/BnB_Presentation.pptx"

def sc(name): return os.path.join(SS,   name)
def lg(name): return os.path.join(LOGO, name)

W, H = Inches(13.33), Inches(7.5)
NS   = 'http://schemas.openxmlformats.org/drawingml/2006/main'

prs = Presentation()
prs.slide_width  = W
prs.slide_height = H
blank = prs.slide_layouts[6]

TOTAL_SLIDES = 12

# ── Primitives ────────────────────────────────────────────────────────────────
def bg(slide, color=BG):
    f = slide.background.fill
    f.solid()
    f.fore_color.rgb = color

def rect(slide, l, t, w, h, fill=None, border=None, bw=Pt(0.75), r=0):
    sh = slide.shapes.add_shape(1, l, t, w, h)
    sh.line.width = bw
    if fill:
        sh.fill.solid(); sh.fill.fore_color.rgb = fill
    else:
        sh.fill.background()
    if border:
        sh.line.color.rgb = border
    else:
        sh.line.fill.background()
    if r:
        sp   = sh.element
        spPr = sp.find(f'{{{NS}}}spPr')
        if spPr is not None:
            pg = spPr.find(f'{{{NS}}}prstGeom')
            if pg is not None:
                pg.set('prst', 'roundRect')
                for old in pg.findall(f'{{{NS}}}avLst'):
                    pg.remove(old)
                av = etree.SubElement(pg, f'{{{NS}}}avLst')
                gd = etree.SubElement(av,  f'{{{NS}}}gd')
                gd.set('name', 'adj')
                gd.set('fmla', f'val {r}')
    return sh

def txt(slide, text, l, t, w, h, sz=Pt(12), bold=False, color=None,
        align=PP_ALIGN.LEFT, italic=False, wrap=True):
    tb = slide.shapes.add_textbox(l, t, w, h)
    tf = tb.text_frame
    tf.word_wrap = wrap
    p  = tf.paragraphs[0]
    p.alignment = align
    rn = p.add_run()
    rn.text           = text
    rn.font.size      = sz
    rn.font.bold      = bold
    rn.font.italic    = italic
    rn.font.color.rgb = color or TEXT_PRI
    return tb

def img(slide, path, l, t, w, h):
    if os.path.exists(path):
        slide.shapes.add_picture(path, l, t, w, h)
    else:
        rect(slide, l, t, w, h, fill=SURFACE2, border=ACCENT, bw=Pt(0.5), r=3000)

def card(slide, l, t, w, h, bcolor=ACCENT, bw=Pt(0.6)):
    rect(slide, l, t, w, h, fill=SURFACE, border=bcolor, bw=bw, r=5000)

def chip(slide, label, l, t, w=Inches(1.7), h=Inches(0.30), color=ACCENT_LIGHT):
    rect(slide, l, t, w, h, fill=SURFACE2, border=ACCENT, bw=Pt(0.5), r=20000)
    txt(slide, label, l, t, w, h, sz=Pt(8.5), bold=True, color=color, align=PP_ALIGN.CENTER)

def slide_num(slide, n):
    txt(slide, f"0{n} / {TOTAL_SLIDES:02d}", W - Inches(1.6), Inches(7.1),
        Inches(1.4), Inches(0.3), sz=Pt(9), color=TEXT_MUTED, align=PP_ALIGN.RIGHT)
    txt(slide, "B&B  Real Estate & Home Services",
        Inches(0.7), Inches(7.1), Inches(5), Inches(0.3),
        sz=Pt(8), color=TEXT_MUTED)

def header(slide, section, title, accent_w=Inches(4.2)):
    rect(slide, Inches(0.45), Inches(0.55), Inches(0.055), Inches(6.4), fill=ACCENT)
    txt(slide, section, Inches(0.7), Inches(0.52), Inches(11), Inches(0.3),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)
    txt(slide, title, Inches(0.7), Inches(0.85), Inches(11), Inches(0.7),
        sz=Pt(34), bold=True, color=TEXT_PRI)
    rect(slide, Inches(0.7), Inches(1.6), accent_w, Inches(0.028), fill=ACCENT)

def logo_sm(slide):
    img(slide, lg("Logo_padded.png"), W - Inches(1.55), Inches(0.18), Inches(1.0), Inches(1.0))

def phone_frame(slide, path, l, t, fw, fh, label=""):
    rect(slide, l - Inches(0.08), t - Inches(0.08),
         fw + Inches(0.16), fh + Inches(0.16),
         fill=SURFACE, border=ACCENT, bw=Pt(0.8), r=4500)
    img(slide, path, l, t, fw, fh)
    if label:
        txt(slide, label, l, t + fh + Inches(0.13), fw, Inches(0.28),
            sz=Pt(9.5), color=TEXT_MUTED, align=PP_ALIGN.CENTER)

def feature_row(slide, icon, title, body, l, t, w=Inches(6.2), h=Inches(0.72)):
    card(slide, l, t, w, h, bcolor=ACCENT, bw=Pt(0.4))
    txt(slide, icon, l + Inches(0.14), t + Inches(0.04), Inches(0.55), h,
        sz=Pt(20), align=PP_ALIGN.CENTER)
    txt(slide, title, l + Inches(0.72), t + Inches(0.05), w - Inches(0.85), Inches(0.3),
        sz=Pt(11.5), bold=True, color=TEXT_PRI)
    txt(slide, body,  l + Inches(0.72), t + Inches(0.34), w - Inches(0.85), Inches(0.3),
        sz=Pt(9.5), color=TEXT_MUTED)

def stat_card(slide, val, label, l, t, c=ACCENT_LIGHT):
    card(slide, l, t, Inches(1.9), Inches(1.3))
    txt(slide, val, l, t + Inches(0.08), Inches(1.9), Inches(0.62),
        sz=Pt(28), bold=True, color=c, align=PP_ALIGN.CENTER)
    txt(slide, label, l, t + Inches(0.72), Inches(1.9), Inches(0.38),
        sz=Pt(9.5), color=TEXT_MUTED, align=PP_ALIGN.CENTER)

# ─────────────────────────────────────────────────────────────────────────────
# SLIDE 01 — Cover
# ─────────────────────────────────────────────────────────────────────────────
def make_cover():
    slide = prs.slides.add_slide(blank)
    bg(slide)
    rect(slide, Inches(0.45), Inches(0.55), Inches(0.055), Inches(6.4), fill=ACCENT)

    # Large logo
    img(slide, lg("Logo_padded.png"), Inches(0.75), Inches(1.65), Inches(2.25), Inches(2.25))

    # Brand headline
    txt(slide, "B&B", Inches(3.25), Inches(1.42), Inches(7), Inches(1.4),
        sz=Pt(92), bold=True, color=ACCENT_LIGHT)
    txt(slide, "REAL ESTATE & HOME SERVICES",
        Inches(3.25), Inches(2.92), Inches(9.5), Inches(0.42),
        sz=Pt(13.5), color=TEXT_MUTED)
    rect(slide, Inches(3.25), Inches(3.42), Inches(7.8), Inches(0.025), fill=ACCENT)
    txt(slide, "Premium Property & Service Platform  |  Mobile Application",
        Inches(3.25), Inches(3.55), Inches(9), Inches(0.4),
        sz=Pt(12.5), color=TEXT_SEC)

    # Team card
    CL, CT, CW, CH = Inches(3.25), Inches(4.12), Inches(9.8), Inches(2.98)
    card(slide, CL, CT, CW, CH, bcolor=ACCENT, bw=Pt(0.7))
    rect(slide, CL, CT, CW, Inches(0.025), fill=ACCENT)

    txt(slide, "TEAM LEADER",
        CL + Inches(0.28), CT + Inches(0.2), Inches(5), Inches(0.28),
        sz=Pt(8), bold=True, color=TEXT_MUTED)
    txt(slide, "يوسف حسن محمد محمود",
        CL + Inches(0.28), CT + Inches(0.47), Inches(5.5), Inches(0.45),
        sz=Pt(19), bold=True, color=ACCENT_LIGHT)
    txt(slide, "Team Leader  |  ID: 2320751",
        CL + Inches(0.28), CT + Inches(0.9), Inches(5), Inches(0.32),
        sz=Pt(11), color=CYAN)

    rect(slide, CL + Inches(0.28), CT + Inches(1.27), CW - Inches(0.56), Inches(0.015), fill=SURFACE2)

    txt(slide, "TEAM MEMBERS",
        CL + Inches(0.28), CT + Inches(1.37), Inches(5), Inches(0.28),
        sz=Pt(8), bold=True, color=TEXT_MUTED)

    members_L = [
        "ياسر علاء إبراهيم  —  2320731  |  Sec 4",
        "يوسف محمد عيد رزق  —  2320766  |  Sec 4",
        "يوسف مصطفى كامل  —  2320771  |  Sec 4",
        "عمر ذكي محمد ذكي  —  2320405  |  Sec 4",
        "رحمه عبدالحميد فؤاد  —  2320223",
    ]
    members_R = [
        "أحمد محمد محمود عبدالكريم  —  2320904  |  Sec 4",
        "بثينة مجدي أحمد محمد  —  2320157  |  Sec 1",
        "مازن محمد إسماعيل أحمد  —  2320470  |  Sec 2",
        "خلود عاطف عبداللطيف والى  —  2320213",
    ]
    y0 = CT + Inches(1.65)
    for i, m in enumerate(members_L):
        txt(slide, m, CL + Inches(0.28), y0 + Inches(i * 0.235), Inches(4.65), Inches(0.24),
            sz=Pt(10), color=TEXT_SEC)
    for i, m in enumerate(members_R):
        txt(slide, m, CL + Inches(5.1), y0 + Inches(i * 0.235), Inches(4.5), Inches(0.24),
            sz=Pt(10), color=TEXT_SEC)

    txt(slide, "2026", W - Inches(1.0), Inches(0.22), Inches(0.85), Inches(0.3),
        sz=Pt(10), bold=True, color=TEXT_MUTED, align=PP_ALIGN.RIGHT)
    slide_num(slide, 1)

make_cover()

# ─────────────────────────────────────────────────────────────────────────────
# SLIDE 02 — Project Overview
# ─────────────────────────────────────────────────────────────────────────────
def make_overview():
    slide = prs.slides.add_slide(blank)
    bg(slide)
    header(slide, "PROJECT OVERVIEW", "What is B&B?")
    logo_sm(slide)

    txt(slide,
        "B&B is a full-stack real estate and home services platform connecting property owners,\n"
        "buyers, and skilled workers through an elegant, premium mobile experience.",
        Inches(0.7), Inches(1.78), Inches(11.5), Inches(0.75),
        sz=Pt(13), color=TEXT_SEC, wrap=True)

    # Stats
    stats = [
        ("12",      "App Screens",    ACCENT_LIGHT),
        ("3",       "User Roles",     CYAN),
        ("REST",    "Laravel API",    SUCCESS),
        ("Flutter", "Framework",      WARNING),
        ("MySQL",   "Database",       ACCENT),
        ("GoRouter","Navigation",     TEXT_SEC),
    ]
    for i, (val, lbl, c) in enumerate(stats):
        stat_card(slide, val, lbl, Inches(0.7 + i * 2.08), Inches(2.65), c)

    # Tech stack
    txt(slide, "TECH STACK", Inches(0.7), Inches(4.15), Inches(12), Inches(0.28),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)
    tech = ["Flutter 3.x", "Dart", "Laravel 11", "PHP 8.2", "MySQL 8", "REST API",
            "Sanctum Auth", "Provider", "GoRouter", "http package"]
    for i, t in enumerate(tech):
        chip(slide, t, Inches(0.7 + (i % 5) * 2.5), Inches(4.48 + (i // 5) * 0.42),
             w=Inches(2.32))

    # User roles
    txt(slide, "USER ROLES", Inches(0.7), Inches(5.5), Inches(12), Inches(0.28),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)
    roles = [
        ("User", "Browse listings, request home services,\nmanage profile and track requests", ACCENT_LIGHT),
        ("Worker", "List services with pricing, accept bookings,\nmanage active service requests", CYAN),
        ("Admin", "Full control: manage users, properties,\nservices, reviews and system stats", WARNING),
    ]
    for i, (role, desc, c) in enumerate(roles):
        x = Inches(0.7 + i * 4.22)
        card(slide, x, Inches(5.86), Inches(3.95), Inches(1.3), bcolor=c, bw=Pt(0.8))
        rect(slide, x, Inches(5.86), Inches(3.95), Inches(0.025), fill=c)
        txt(slide, role, x + Inches(0.2), Inches(5.97), Inches(3.5), Inches(0.35),
            sz=Pt(15), bold=True, color=c)
        txt(slide, desc, x + Inches(0.2), Inches(6.35), Inches(3.7), Inches(0.7),
            sz=Pt(10), color=TEXT_SEC, wrap=True)

    slide_num(slide, 2)

make_overview()

# ─────────────────────────────────────────────────────────────────────────────
# SLIDE 03 — Onboarding (Splash + Auth)
# ─────────────────────────────────────────────────────────────────────────────
def make_onboarding():
    slide = prs.slides.add_slide(blank)
    bg(slide)
    header(slide, "ONBOARDING", "First Impressions")
    logo_sm(slide)

    txt(slide,
        "A seamless dark-luxury onboarding experience from the very first native pixel.",
        Inches(0.7), Inches(1.75), Inches(9), Inches(0.4),
        sz=Pt(12.5), color=TEXT_SEC)

    screens = [
        (sc("00_native_splashs_creen.png"), "Native Splash"),
        (sc("01_splash_screen.png"),         "Animated Splash"),
        (sc("02_login_screen.png"),          "Sign In"),
        (sc("03_register_screen.png"),       "Sign Up"),
    ]
    # Smaller phones to leave room for callout text below
    FW, FH = Inches(2.18), Inches(3.6)
    for i, (path, label) in enumerate(screens):
        x = Inches(0.7 + i * 2.56)
        phone_frame(slide, path, x, Inches(2.25), FW, FH, label)

    # Callouts sit at y=6.1 — well clear of phone bottom (2.25+3.6=5.85)
    callouts = [
        ("Dark Native Splash",   "Pixel-perfect dark background\nmatching in-app Flutter splash"),
        ("Glassmorphism UI",     "Ambient orbs, blur layers and\npremium gradient typography"),
        ("Animated Entry",       "Elastic scale + fade + progress\nbar animation over 2.8 seconds"),
        ("Dual Auth Flow",       "Email/password auth with role\nselection: User or Worker"),
    ]
    for i, (title, body) in enumerate(callouts):
        x = Inches(0.7 + i * 2.56)
        txt(slide, title, x, Inches(6.1), Inches(2.35), Inches(0.3),
            sz=Pt(9.5), bold=True, color=ACCENT_LIGHT)
        txt(slide, body, x, Inches(6.42), Inches(2.38), Inches(0.6),
            sz=Pt(8.5), color=TEXT_MUTED, wrap=True)

    slide_num(slide, 3)

make_onboarding()

# ─────────────────────────────────────────────────────────────────────────────
# SLIDE 04 — Home Dashboard
# ─────────────────────────────────────────────────────────────────────────────
def make_home():
    slide = prs.slides.add_slide(blank)
    bg(slide)
    header(slide, "HOME DASHBOARD", "Browse & Discover")
    logo_sm(slide)

    txt(slide, "A curated feed of premium properties and on-demand services, personalised by role.",
        Inches(0.7), Inches(1.75), Inches(7), Inches(0.4), sz=Pt(12.5), color=TEXT_SEC)

    # Phone starts at y=2.2 (below subtitle at y=1.75+0.4=2.15), slightly smaller
    FW, FH = Inches(2.4), Inches(4.6)
    phone_frame(slide, sc("04_home_screen.png"), Inches(0.7), Inches(2.25), FW, FH, "Home Dashboard")

    fx_x = Inches(4.0)
    txt(slide, "HOME SCREEN FEATURES", fx_x, Inches(2.25), Inches(9.0), Inches(0.28),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)

    feats = [
        ("🏠", "Featured Properties",    "Curated hero cards with real imagery, instant pricing & city tags"),
        ("🔍", "Smart Global Search",    "Real-time search across all properties and available services"),
        ("⚡", "Available Services",     "Browse and book home services with a single tap from the home screen"),
        ("📌", "City-Based Filters",     "Filter by Cairo, Giza, Alexandria, Luxor, Sharm El-Sheikh and more"),
        ("👤", "Role-Aware UI",          "Dashboard content adapts to User / Worker / Admin role automatically"),
        ("🎨", "Glassmorphism Cards",    "Layered dark cards with border glow and ambient background gradients"),
    ]
    for i, (icon, title, body) in enumerate(feats):
        feature_row(slide, icon, title, body, fx_x, Inches(2.62 + i * 0.8), w=Inches(8.9))

    slide_num(slide, 4)

make_home()

# ─────────────────────────────────────────────────────────────────────────────
# SLIDE 05 — Property Listings
# ─────────────────────────────────────────────────────────────────────────────
def make_listings():
    slide = prs.slides.add_slide(blank)
    bg(slide)
    header(slide, "PROPERTIES", "Property Listings")
    logo_sm(slide)

    txt(slide, "Searchable, filterable property listings with full detail views and status management.",
        Inches(0.7), Inches(1.75), Inches(8), Inches(0.4), sz=Pt(12.5), color=TEXT_SEC)

    FW, FH = Inches(2.4), Inches(4.6)
    phone_frame(slide, sc("05_property_list_screen.png"), Inches(0.7), Inches(2.25), FW, FH, "Property Listings")

    fx_x = Inches(4.0)
    txt(slide, "LISTINGS FEATURES", fx_x, Inches(2.25), Inches(9.0), Inches(0.28),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)

    feats = [
        ("🔎", "Search by Title / City",  "Instant filter by property title, city or location keyword"),
        ("🏙️", "City Filter Chips",       "One-tap city filters: All, Cairo, Giza, Alexandria, Luxor"),
        ("🖼️", "Full-Bleed Image Cards",  "Hero images with overlay gradient, price badge and status chip"),
        ("💰", "Formatted Pricing",       "Currency-formatted price display with room and area metadata"),
        ("📊", "Live Count",              "Listing count badge always reflects the current filtered results"),
        ("➕", "Quick Add Button",        "Floating action button for owners to add a new property instantly"),
    ]
    for i, (icon, title, body) in enumerate(feats):
        feature_row(slide, icon, title, body, fx_x, Inches(2.62 + i * 0.8), w=Inches(8.9))

    slide_num(slide, 5)

make_listings()

# ─────────────────────────────────────────────────────────────────────────────
# SLIDE 06 — Property Details & Add Property
# ─────────────────────────────────────────────────────────────────────────────
def make_properties():
    slide = prs.slides.add_slide(blank)
    bg(slide)
    header(slide, "PROPERTY MANAGEMENT", "Details & Creation", accent_w=Inches(5.2))
    logo_sm(slide)

    txt(slide, "Full property lifecycle — view, create and manage listings with rich metadata.",
        Inches(0.7), Inches(1.75), Inches(8), Inches(0.4), sz=Pt(12.5), color=TEXT_SEC)

    FW, FH = Inches(2.3), Inches(4.35)
    for i, (path, label) in enumerate([
        (sc("06_property_details_screen.png"), "Property Details"),
        (sc("07_add_property_screen.png"),      "Add Property"),
    ]):
        x = Inches(0.7 + i * 2.6)
        phone_frame(slide, path, x, Inches(2.25), FW, FH, label)

    fx_x = Inches(6.3)
    txt(slide, "PROPERTY DETAIL FEATURES", fx_x, Inches(2.25), Inches(6.8), Inches(0.28),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)

    feats = [
        ("📷", "Photo Gallery",       "Swipeable image gallery with full-bleed hero layout"),
        ("💰", "Price & Specs",       "Rooms, area m2, city — clean formatted data display"),
        ("🏷️", "Status Transitions", "Available / Pending / Sold — one-tap segmented control"),
        ("👤", "Owner Profile",       "Linked owner details with name, avatar and contact access"),
        ("⭐", "Review System",       "Integrated star ratings and text reviews from verified users"),
        ("📝", "Add Property Form",   "Full form: title, description, price, rooms, area, city, photos"),
    ]
    for i, (icon, title, body) in enumerate(feats):
        feature_row(slide, icon, title, body, fx_x, Inches(2.62 + i * 0.78), w=Inches(6.8))

    slide_num(slide, 6)

make_properties()

# ─────────────────────────────────────────────────────────────────────────────
# SLIDE 07 — Worker Dashboard & Services
# ─────────────────────────────────────────────────────────────────────────────
def make_worker():
    slide = prs.slides.add_slide(blank)
    bg(slide)
    header(slide, "WORKER DASHBOARD", "Service Management", accent_w=Inches(5.0))
    logo_sm(slide)

    txt(slide, "Workers manage their service catalogue and incoming requests from a unified dashboard.",
        Inches(0.7), Inches(1.75), Inches(8.5), Inches(0.4), sz=Pt(12.5), color=TEXT_SEC)

    FW, FH = Inches(2.45), Inches(4.6)
    for i, (path, label) in enumerate([
        (sc("10_worker_dashboard_screen.png"), "Worker Dashboard"),
        (sc("11_add_service_dialog.png"),       "Add Service"),
    ]):
        x = Inches(0.7 + i * 2.75)
        phone_frame(slide, path, x, Inches(2.1), FW, FH, label)

    fx_x = Inches(6.5)
    txt(slide, "WORKER FEATURES", fx_x, Inches(2.1), Inches(6.6), Inches(0.28),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)

    feats = [
        ("🔧", "Service Catalogue",    "List multiple services with category, description and pricing"),
        ("💵", "Flexible Pricing",     "Set price per hour, per piece or per unit per service"),
        ("🟢", "Availability Toggle",  "Instantly toggle each service on/off for availability"),
        ("📋", "Incoming Requests",    "Dedicated tab showing all booking requests with status"),
        ("✅", "Accept / Decline",     "One-tap accept or decline with automatic client notification"),
        ("➕", "Add Service Dialog",   "Quick-add modal: category, description, price, unit type"),
    ]
    for i, (icon, title, body) in enumerate(feats):
        feature_row(slide, icon, title, body, fx_x, Inches(2.48 + i * 0.75), w=Inches(6.6))

    # Service categories row — all 6 chips in one line inside the slide
    txt(slide, "SERVICE CATEGORIES", fx_x, Inches(6.6), Inches(6.6), Inches(0.25),
        sz=Pt(8), bold=True, color=TEXT_MUTED)
    cats = ["Plumbing", "Carpentry", "Tiling", "Finishing", "Painting", "Electrical"]
    for i, c in enumerate(cats):
        chip(slide, c, fx_x + Inches(i * 1.1), Inches(6.88), w=Inches(1.02), color=CYAN)

    slide_num(slide, 7)

make_worker()

# ─────────────────────────────────────────────────────────────────────────────
# SLIDE 08 — Requests & Reviews
# ─────────────────────────────────────────────────────────────────────────────
def make_requests():
    slide = prs.slides.add_slide(blank)
    bg(slide)
    header(slide, "REQUESTS & REVIEWS", "Booking Lifecycle", accent_w=Inches(4.8))
    logo_sm(slide)

    txt(slide, "End-to-end request tracking with status management and a built-in review system.",
        Inches(0.7), Inches(1.75), Inches(8.5), Inches(0.4), sz=Pt(12.5), color=TEXT_SEC)

    FW, FH = Inches(2.4), Inches(4.55)
    phone_frame(slide, sc("08_requests_screen.png"), Inches(0.7), Inches(2.25), FW, FH, "My Requests")

    fx_x = Inches(4.0)

    # Flow diagram
    txt(slide, "REQUEST LIFECYCLE", fx_x, Inches(2.25), Inches(9.0), Inches(0.28),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)

    flow = [
        ("User Submits\nRequest", ACCENT_LIGHT),
        ("Worker\nReviews",       TEXT_SEC),
        ("Accept /\nDecline",     CYAN),
        ("Service\nDelivered",    SUCCESS),
        ("Review\nSubmitted",     WARNING),
    ]
    CW = Inches(1.6)
    STEP = Inches(1.78)
    for i, (label, c) in enumerate(flow):
        bx = fx_x + i * STEP
        card(slide, bx, Inches(2.62), CW, Inches(0.85), bcolor=c, bw=Pt(1))
        txt(slide, label, bx, Inches(2.66), CW, Inches(0.78),
            sz=Pt(9.5), bold=True, color=c, align=PP_ALIGN.CENTER, wrap=True)
        if i < len(flow) - 1:
            txt(slide, ">", bx + CW, Inches(2.94), Inches(0.18), Inches(0.3),
                sz=Pt(13), color=TEXT_MUTED, align=PP_ALIGN.CENTER)

    # Status explanation
    txt(slide, "STATUS DEFINITIONS", fx_x, Inches(3.55), Inches(9.0), Inches(0.25),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)
    statuses = [
        ("PENDING",   WARNING,    "Request submitted, awaiting worker response"),
        ("ACCEPTED",  CYAN,       "Worker confirmed — service in progress"),
        ("COMPLETED", SUCCESS,    "Service delivered and marked done by worker"),
        ("CANCELLED", TEXT_MUTED, "Request cancelled by user or worker"),
    ]
    for i, (s, c, desc) in enumerate(statuses):
        y = Inches(3.85 + i * 0.56)
        card(slide, fx_x, y, Inches(9.0), Inches(0.48), bcolor=c, bw=Pt(0.5))
        rect(slide, fx_x, y, Inches(0.55), Inches(0.48), fill=c, r=4000)
        txt(slide, s,    fx_x + Inches(0.67), y + Inches(0.04), Inches(2), Inches(0.23),
            sz=Pt(10), bold=True, color=c)
        txt(slide, desc, fx_x + Inches(0.67), y + Inches(0.24), Inches(8.1), Inches(0.22),
            sz=Pt(9), color=TEXT_SEC)

    # Review system — starts at 3.85 + 4*0.56 = 6.09, card ends at 6.09+0.25+0.1+0.46 = 6.9
    txt(slide, "REVIEW SYSTEM", fx_x, Inches(6.12), Inches(9.0), Inches(0.25),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)
    card(slide, fx_x, Inches(6.4), Inches(9.0), Inches(0.48))
    txt(slide, "Star Ratings (1-5)  |  Written Text Reviews  |  Worker Profile Feedback  |  Admin Moderation",
        fx_x + Inches(0.2), Inches(6.47), Inches(8.6), Inches(0.38),
        sz=Pt(10.5), color=TEXT_SEC)

    slide_num(slide, 8)

make_requests()

# ─────────────────────────────────────────────────────────────────────────────
# SLIDE 09 — User Profile & Authentication
# ─────────────────────────────────────────────────────────────────────────────
def make_profile():
    slide = prs.slides.add_slide(blank)
    bg(slide)
    header(slide, "PROFILE & AUTHENTICATION", "User Account Management", accent_w=Inches(6.2))
    logo_sm(slide)

    txt(slide, "Persistent sessions, role-based UI, editable profile with secure token authentication.",
        Inches(0.7), Inches(1.75), Inches(9), Inches(0.4), sz=Pt(12.5), color=TEXT_SEC)

    FW, FH = Inches(2.4), Inches(4.55)
    phone_frame(slide, sc("09_profile_screen.png"), Inches(0.7), Inches(2.25), FW, FH, "User Profile")

    fx_x = Inches(4.0)
    txt(slide, "PROFILE FEATURES", fx_x, Inches(2.25), Inches(9.0), Inches(0.28),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)

    feats = [
        ("👤", "Avatar & Display Name",  "Gradient avatar with user initials, name and email displayed"),
        ("🏷️", "Role Badge",            "Prominent role chip: Admin (purple) / User (cyan) / Worker"),
        ("✏️", "Editable Phone",        "Inline phone number editing with instant API save"),
        ("📋", "My Requests Shortcut",  "Quick navigation to full request history from profile"),
        ("🔐", "Secure Token Auth",      "Laravel Sanctum bearer tokens with persistent session storage"),
        ("🚪", "Logout",                "Single-tap secure logout with token invalidation on server"),
    ]
    # 6 rows × 0.62" gap = last row at 2.62 + 5×0.62 = 5.72", ends at 5.72+0.62=6.34"
    for i, (icon, title, body) in enumerate(feats):
        feature_row(slide, icon, title, body, fx_x, Inches(2.62 + i * 0.62), w=Inches(8.9), h=Inches(0.58))

    # Auth flow summary — starts at 6.45", well below last feature row
    txt(slide, "AUTHENTICATION FLOW", fx_x, Inches(6.42), Inches(9.0), Inches(0.22),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)
    card(slide, fx_x, Inches(6.66), Inches(9.0), Inches(0.42))
    txt(slide, "Login  >  Sanctum Token  >  SharedPreferences  >  Auto-Restored on Relaunch  >  Role-Based Routing",
        fx_x + Inches(0.2), Inches(6.72), Inches(8.6), Inches(0.32),
        sz=Pt(10), color=TEXT_SEC)

    slide_num(slide, 9)

make_profile()

# ─────────────────────────────────────────────────────────────────────────────
# SLIDE 10 — System Architecture
# ─────────────────────────────────────────────────────────────────────────────
def make_arch():
    slide = prs.slides.add_slide(blank)
    bg(slide)
    header(slide, "SYSTEM ARCHITECTURE", "Technical Design", accent_w=Inches(4.8))
    logo_sm(slide)

    txt(slide, "Clean separation of concerns across four architectural layers with JWT-secured REST communication.",
        Inches(0.7), Inches(1.75), Inches(11.5), Inches(0.4), sz=Pt(12.5), color=TEXT_SEC)

    # Architecture layers
    layers = [
        ("Flutter Mobile App",    "Dart  |  Provider State Management  |  GoRouter Navigation  |  http Package",       ACCENT_LIGHT, "Presentation Layer"),
        ("REST API Contract",     "HTTPS  |  JSON Envelope  |  Bearer Token  |  Standardised Response Shape",           ACCENT,       "Interface Layer"),
        ("Laravel 11 Backend",    "PHP 8.2  |  Eloquent ORM  |  Resource Controllers  |  Form Requests  |  Gates",     CYAN,         "Business Logic Layer"),
        ("MySQL 8 Database",      "Migrations  |  Seeders  |  Foreign Keys  |  Indexes  |  Relationships",             SUCCESS,      "Data Layer"),
    ]
    for i, (title, desc, c, layer_label) in enumerate(layers):
        ly = Inches(2.25 + i * 1.0)
        card(slide, Inches(0.7), ly, Inches(11.3), Inches(0.82), bcolor=c, bw=Pt(1.2))
        rect(slide, Inches(0.7), ly, Inches(0.18), Inches(0.82), fill=c, r=3000)
        txt(slide, title,       Inches(1.05), ly + Inches(0.05), Inches(4.5), Inches(0.3),
            sz=Pt(13), bold=True, color=c)
        txt(slide, layer_label, Inches(8.5),  ly + Inches(0.05), Inches(3.3), Inches(0.3),
            sz=Pt(8.5), bold=True, color=c, align=PP_ALIGN.RIGHT)
        txt(slide, desc,        Inches(1.05), ly + Inches(0.38), Inches(10.7), Inches(0.35),
            sz=Pt(10), color=TEXT_MUTED)
        if i < 3:
            txt(slide, "|", Inches(6.3), ly + Inches(0.82), Inches(0.5), Inches(0.2),
                sz=Pt(11), color=TEXT_MUTED, align=PP_ALIGN.CENTER)

    # Key API endpoints table — 6 items in 2 columns, 3 rows
    txt(slide, "KEY API ENDPOINTS", Inches(0.7), Inches(6.18), Inches(12), Inches(0.22),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)

    endpoints = [
        ("POST", "/api/auth/login",        "Authenticate user, receive Sanctum token",   ACCENT_LIGHT),
        ("POST", "/api/auth/register",     "Create new user or worker account",           ACCENT_LIGHT),
        ("GET",  "/api/properties",        "Paginated property listings with filters",    CYAN),
        ("POST", "/api/properties",        "Create new property (authenticated owner)",   CYAN),
        ("GET",  "/api/worker-services",   "Available home services catalogue",           SUCCESS),
        ("POST", "/api/service-requests",  "Submit a booking request for a service",      WARNING),
    ]
    for i, (method, path, desc, c) in enumerate(endpoints):
        col = i % 2
        row = i // 2
        x = Inches(0.7 + col * 6.35)
        y = Inches(6.42 + row * 0.22)
        card(slide, x, y, Inches(6.05), Inches(0.20), bcolor=c, bw=Pt(0.4))
        txt(slide, method, x + Inches(0.1), y, Inches(0.6), Inches(0.20),
            sz=Pt(7), bold=True, color=c)
        txt(slide, path,   x + Inches(0.65), y, Inches(2.1), Inches(0.20),
            sz=Pt(7.5), color=ACCENT_LIGHT)
        txt(slide, desc,   x + Inches(2.78), y, Inches(3.1), Inches(0.20),
            sz=Pt(7), color=TEXT_MUTED)

    slide_num(slide, 10)

make_arch()

# ─────────────────────────────────────────────────────────────────────────────
# SLIDE 11 — Brand Identity & Design System
# ─────────────────────────────────────────────────────────────────────────────
def make_brand():
    slide = prs.slides.add_slide(blank)
    bg(slide)
    header(slide, "BRANDING & DESIGN SYSTEM", "Visual Identity", accent_w=Inches(5.2))
    logo_sm(slide)

    # Color palette
    txt(slide, "BRAND COLORS", Inches(0.7), Inches(2.05), Inches(12), Inches(0.28),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)
    palette = [
        ("#060B18", "Background",    BG),
        ("#0D1424", "Surface",       SURFACE),
        ("#7C5CFC", "Accent Violet", ACCENT),
        ("#B69EFF", "Accent Light",  ACCENT_LIGHT),
        ("#4FC3F7", "Cyan",          CYAN),
        ("#34D399", "Success",       SUCCESS),
        ("#F0F4FF", "Text Primary",  TEXT_PRI),
    ]
    sw = Inches(1.72)
    for i, (hex_, name, c) in enumerate(palette):
        x = Inches(0.7 + i * 1.8)
        rect(slide, x, Inches(2.4), sw, Inches(0.88), fill=c, r=4000)
        txt(slide, hex_, x, Inches(3.35), sw, Inches(0.25),
            sz=Pt(8.5), bold=True, color=TEXT_SEC, align=PP_ALIGN.CENTER)
        txt(slide, name, x, Inches(3.6),  sw, Inches(0.25),
            sz=Pt(8), color=TEXT_MUTED, align=PP_ALIGN.CENTER)

    # Logo variants
    txt(slide, "LOGO VARIANTS", Inches(0.7), Inches(4.1), Inches(12), Inches(0.28),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)
    variants = [
        ("Logo_padded.png",      "Primary"),
        ("Logo_ios.png",         "iOS / Dark"),
        ("Logo_transparent.png", "Transparent"),
        ("Logo.png",             "Compact"),
        ("Logo_splash.png",      "Splash"),
    ]
    ls = Inches(1.55)
    for i, (fname, label) in enumerate(variants):
        x = Inches(0.7 + i * 2.5)
        card(slide, x, Inches(4.45), ls + Inches(0.5), ls + Inches(0.62))
        img(slide, lg(fname), x + Inches(0.25), Inches(4.6), ls, ls)
        txt(slide, label, x, Inches(4.45) + ls + Inches(0.56),
            ls + Inches(0.5), Inches(0.28),
            sz=Pt(9), color=TEXT_MUTED, align=PP_ALIGN.CENTER)

    # Design principles
    txt(slide, "DESIGN PRINCIPLES", Inches(0.7), Inches(6.42), Inches(12), Inches(0.28),
        sz=Pt(8.5), bold=True, color=TEXT_MUTED)
    principles = [
        ("Dark-First",       "OLED dark optimised\nzero eye strain"),
        ("Glassmorphism",    "Blur layers, soft\nborders and glow"),
        ("Motion Language",  "Purposeful animations\nelastic & easing"),
        ("Negative Space",   "Clean grids, generous\npadding always"),
        ("Design Tokens",    "Centralised palette\nand typography"),
    ]
    for i, (title, body) in enumerate(principles):
        x = Inches(0.7 + i * 2.52)
        card(slide, x, Inches(6.75), Inches(2.35), Inches(0.62), bcolor=ACCENT, bw=Pt(0.4))
        txt(slide, title, x + Inches(0.14), Inches(6.83), Inches(2.1), Inches(0.28),
            sz=Pt(10.5), bold=True, color=ACCENT_LIGHT)
        txt(slide, body,  x + Inches(0.14), Inches(7.1),  Inches(2.1), Inches(0.25),
            sz=Pt(8.5), color=TEXT_MUTED, wrap=True)

    slide_num(slide, 11)

make_brand()

# ─────────────────────────────────────────────────────────────────────────────
# SLIDE 12 — Thank You / Closing
# ─────────────────────────────────────────────────────────────────────────────
def make_closing():
    slide = prs.slides.add_slide(blank)
    bg(slide)

    # Left accent bar (same as every slide header bar)
    rect(slide, Inches(0.45), Inches(0.55), Inches(0.055), Inches(6.4), fill=ACCENT)

    # Large centred logo
    img(slide, lg("Logo_padded.png"), Inches(5.27), Inches(0.8), Inches(2.8), Inches(2.8))

    # "Thank You" headline
    txt(slide, "Thank You",
        Inches(1.0), Inches(3.72), Inches(11.33), Inches(1.2),
        sz=Pt(72), bold=True, color=ACCENT_LIGHT, align=PP_ALIGN.CENTER)

    # App name subtitle
    txt(slide, "B&B  —  Real Estate & Home Services",
        Inches(1.0), Inches(4.95), Inches(11.33), Inches(0.45),
        sz=Pt(18), color=TEXT_SEC, align=PP_ALIGN.CENTER)

    # Thin accent divider line
    rect(slide, Inches(3.5), Inches(5.48), Inches(6.33), Inches(0.025), fill=ACCENT)

    # Built-with caption
    txt(slide, "Built with Flutter & Laravel  |  2026",
        Inches(1.0), Inches(5.6), Inches(11.33), Inches(0.38),
        sz=Pt(13), color=TEXT_MUTED, align=PP_ALIGN.CENTER)

    # Team card
    CL, CT, CW, CH = Inches(2.2), Inches(6.1), Inches(8.93), Inches(1.02)
    card(slide, CL, CT, CW, CH, bcolor=ACCENT, bw=Pt(0.6))
    rect(slide, CL, CT, CW, Inches(0.025), fill=ACCENT)

    # Team leader inside card
    txt(slide, "يوسف حسن محمد محمود  —  Team Leader  |  ID: 2320751",
        CL + Inches(0.2), CT + Inches(0.1), CW - Inches(0.4), Inches(0.3),
        sz=Pt(12), bold=True, color=ACCENT_LIGHT, align=PP_ALIGN.CENTER)

    # Members line
    members_line = (
        "ياسر علاء إبراهيم (2320731)  ·  يوسف محمد عيد رزق (2320766)  ·  يوسف مصطفى كامل (2320771)  ·  عمر ذكي محمد ذكي (2320405)  ·  رحمه عبدالحميد فؤاد (2320223)\n"
        "أحمد محمد محمود عبدالكريم (2320904)  ·  بثينة مجدي أحمد محمد (2320157)  ·  مازن محمد إسماعيل أحمد (2320470)  ·  خلود عاطف عبداللطيف والى (2320213)"
    )
    txt(slide, members_line,
        CL + Inches(0.2), CT + Inches(0.42), CW - Inches(0.4), Inches(0.55),
        sz=Pt(7.5), color=TEXT_MUTED, align=PP_ALIGN.CENTER, wrap=True)

    # Slide number (12 / 12)
    txt(slide, "12 / 12", W - Inches(1.6), Inches(7.1),
        Inches(1.4), Inches(0.3), sz=Pt(9), color=TEXT_MUTED, align=PP_ALIGN.RIGHT)
    txt(slide, "B&B  Real Estate & Home Services",
        Inches(0.7), Inches(7.1), Inches(5), Inches(0.3),
        sz=Pt(8), color=TEXT_MUTED)

make_closing()

# ── Save ──────────────────────────────────────────────────────────────────────
os.makedirs(os.path.dirname(OUT), exist_ok=True)
prs.save(OUT)
print(f"Saved: {OUT}")
