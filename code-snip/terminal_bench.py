import argparse
import time
import sys
import psutil
import random
import string
from tqdm import tqdm

# Unicode 字符池（模拟真实复杂输出）
UNICODE_CHARS = (
    string.ascii_letters
    + string.digits
    + " .,;:!?-_=+*/\\|@#$%^&()[]{}<>\"'"
    + "中文测试αβγδεфжзийклмнопрстуфхцчшщъыьэюяÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞß"
    + "🚀🌍🔥✅❌⚠️💡📁📄🔗🔢📅🕒"
)


def generate_line(mode, chars_per_line, line_index=0, use_complex=False):
    """生成更真实的测试行"""
    if mode == "color":
        # 更丰富的 ANSI 样式
        styles = [
            "\033[31m",
            "\033[32m",
            "\033[33m",
            "\033[34m",
            "\033[35m",
            "\033[36m",
            "\033[1;31m",
            "\033[4;32m",
            "\033[41;97m",
            "\033[44;97m",  # 背景色
        ]
        reset = "\033[0m"
        style = styles[line_index % len(styles)]
        content = _generate_content(chars_per_line - 20, use_complex)
        return f"{style}{content}{reset}\n"

    elif mode == "ansi":
        # 模拟真实 ANSI 负载：光标、清屏、样式混合
        parts = []
        if line_index % 10000 == 0:  # 每 10k 行清屏一次（重绘压力）
            parts.append("\033[2J\033[H")  # 清屏 + 光标归位
        if line_index % 500 == 0:
            parts.append("\033[?25l")  # 隐藏光标
        elif line_index % 500 == 250:
            parts.append("\033[?25h")  # 显示光标

        content = _generate_content(chars_per_line, use_complex)
        parts.append(content + "\n")
        if line_index % 500 == 250:
            parts.append("\033[?25h")  # 确保光标最终显示
        return "".join(parts)

    elif mode == "mixed":
        # 混合 ANSI + 复杂字符
        if random.random() < 0.1:
            return generate_line("color", chars_per_line, line_index, use_complex=True)
        else:
            return _generate_content(chars_per_line, use_complex=True) + "\n"

    else:  # "text"
        return _generate_content(chars_per_line, use_complex) + "\n"


def _generate_content(length, use_complex=False):
    if use_complex and random.random() < 0.3:
        return "".join(random.choices(UNICODE_CHARS, k=length))
    else:
        return "".join(random.choices(string.printable[:62], k=length))  # 更快


def test_terminal(
    mode, total_lines, chars_per_line, block_size, show_memory, complex_chars
):
    print(
        f"Starting {mode.upper()} test with {'complex Unicode' if complex_chars else 'ASCII'}"
    )
    print(
        f"Total: {total_lines:,} lines × ~{chars_per_line} chars/line | Block: {block_size}"
    )
    print("(Press Ctrl+C to stop)\n")

    start_time = time.time()
    mem_start = psutil.Process().memory_info().rss if show_memory else 0
    pbar = tqdm(total=total_lines, unit="lines", smoothing=0.1)

    written = 0
    try:
        while written < total_lines:
            current_block = min(block_size, total_lines - written)
            output_lines = []

            for i in range(current_block):
                line = generate_line(
                    mode,
                    chars_per_line,
                    line_index=written + i,
                    use_complex=complex_chars,
                )
                output_lines.append(line)

                # 模拟真实程序的小延迟（避免内核缓冲吞没终端）
                if mode in ("ansi", "mixed") and random.random() < 0.001:
                    time.sleep(0.001)  # 1ms 随机停顿

            sys.stdout.write("".join(output_lines))
            sys.stdout.flush()
            written += current_block
            pbar.update(current_block)

    except KeyboardInterrupt:
        pbar.close()
        print("\n⚠️  Test interrupted by user.")
        sys.exit(1)

    pbar.close()
    elapsed = time.time() - start_time
    mem_end = psutil.Process().memory_info().rss if show_memory else 0

    # 结果
    print("\n" + "=" * 60)
    print(f"✅ TEST FINISHED in {elapsed:.2f} seconds")
    print(f"📊 Lines/sec:     {total_lines / elapsed:,.0f}")
    print(f"📊 Chars/sec:     {total_lines * chars_per_line / elapsed:,.0f}")
    if show_memory:
        delta = mem_end - mem_start
        for unit in ["B", "KB", "MB", "GB"]:
            if abs(delta) < 1024:
                print(f"🧠 Memory Δ:      {delta:.1f}{unit}")
                break
            delta /= 1024
    print("=" * 60)
    print(
        "💡 Tip: If your terminal became unresponsive, it indicates rendering bottleneck."
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Realistic Terminal Emulator Performance Tester"
    )
    parser.add_argument(
        "-m",
        "--mode",
        choices=["text", "color", "ansi", "mixed"],
        default="mixed",
        help="Test mode: text, color, ansi (full ANSI), or mixed",
    )
    parser.add_argument("-l", "--lines", type=int, default=2000000)
    parser.add_argument("-c", "--chars", type=int, default=120)
    parser.add_argument("-b", "--block", type=int, default=500)
    parser.add_argument("--memory", action="store_true", default=True)
    parser.add_argument(
        "--complex",
        action="store_true",
        default=True,
        help="Use Unicode/Emoji (heavier)",
    )

    args = parser.parse_args()

    if args.lines > 8000000:
        print("⚠️  Warning: >8M lines may freeze your terminal!")
        if input("Continue? (y/N): ").lower() != "y":
            sys.exit(0)

    test_terminal(
        mode=args.mode,
        total_lines=args.lines,
        chars_per_line=args.chars,
        block_size=args.block,
        show_memory=args.memory,
        complex_chars=args.complex,
    )
