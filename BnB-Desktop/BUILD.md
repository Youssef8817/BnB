# Build Instructions — bb-admin Qt6 Desktop App

## Prerequisites (already installed via pacman)
- MSYS2 with mingw64: `C:\msys64`
- cmake, ninja, Qt6 (installed via pacman)

## Build Steps

Open **MSYS2 MinGW64** terminal (from Start menu: "MSYS2 MinGW x64") and run:

```bash
cd /d/BnB/BnB-Desktop
mkdir -p build
cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/mingw64
cmake --build build --parallel
```

Or from **Windows CMD** / **PowerShell**:

```bat
set PATH=C:\msys64\mingw64\bin;%PATH%
cd "D:\BnB\BnB-Desktop"
mkdir build
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=C:\msys64\mingw64
cmake --build build --parallel
```

## Run

After building:
```bash
# From MSYS2 mingw64 terminal:
./build/bb-admin.exe

# Or from CMD:
build\bb-admin.exe
```

The app connects to the Laravel backend at http://127.0.0.1:8000 by default.

## Start Backend First

```bash
cd D:\BnB\BnB-Backend
php artisan serve --host=127.0.0.1 --port=8000
```

Login credentials (seeded):
- Admin:  admin@bb.com  / password
- User 1: user1@bb.com / password
- Worker: worker1@bb.com / password
