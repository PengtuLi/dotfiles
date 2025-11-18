docker stop redroid12
# --pull always \
    docker run --rm -itd --privileged \
    -v ~/rd-data12:/data \
    -p 5555:5555 \
    --name redroid12 \
    redroid/redroid:12.0.0_64only_magisk \
    ro.secure=0 \
    androidboot.redroid_width=1080 \
    androidboot.redroid_height=1920 \
    androidboot.redroid_dpi=480 \
    androidboot.redroid_fps=60 \
    androidboot.redroid_gpu_mode=host \
    ro.product.cpu.abilist=x86_64,arm64-v8a \
    ro.product.cpu.abilist64=x86_64,arm64-v8a
adb connect localhost:5555
sleep 3
scrcpy -s localhost:5555
