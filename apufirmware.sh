# 1. Capture the initial flashrom environment probe
    flash_err=$(flashrom -p internal 2>&1)
    
    # 2. Check if we need to target a specific chip definition
    if echo "$flash_err" | grep -q "Please specify which chip definition"; then
        chip_name=$(echo "$flash_err" | grep -o '".*?"' | head -1 | tr -d '"')
        chip_flag="-c $chip_name"
    else
        chip_flag=""
    fi

    # 3. Safely extract flash size (look for "kB" or "KB" in the text)
    # e.g., "Found Winbond flash chip... (8192 kB, SPI)" -> extracts 8192
    flashsize=$(echo "$flash_err" | grep -i "chip" | grep -o '[0-8]* [kK][bB]' | head -1 | cut -d' ' -f1)
    
    # Fallback to 0 if text parsing fails to prevent the "/ 1024" crash
    if [ -z "$flashsize" ]; then flashsize=0; fi

    # 4. Extract vendor and chip model safely from the detected chip text
    # e.g., 'Found Winbond flash chip "W25Q64..."' -> vendor="Winbond", chip="W25Q64..."
    flash_line=$(echo "$flash_err" | grep "Found" | grep "flash chip" | head -1)
    flashvendor=$(echo "$flash_line" | cut -d'"' -f1 | awk '{print $NF}')
    flashchip=$(echo "$flash_line" | cut -d'"' -f2)
