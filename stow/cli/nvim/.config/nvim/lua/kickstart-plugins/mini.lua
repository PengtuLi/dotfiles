return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    event = 'VeryLazy',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- mini.surround — 包裹符操作（括号、引号、标签等）
      --
      -- 包裹符标识（单个字符，用于 sd/sr/sf/sh 后面指定要操作哪种包裹）:
      --   ) ] }  — 括号类，自动匹配左右对
      --   ' " `  — 引号类，左右相同
      --   f      — 函数调用，如 foo(x)。sd/sr 时匹配整个函数调用，sa 时提示输入函数名
      --   t      — HTML 标签，如 <div>x</div>。sd/sr 时匹配标签对，sa 时提示输入标签名
      --   ?      — 自定义，提示输入左半和右半
      --   其他   — 左右相同（如 _ - |）
      --
      -- ── sa: 添加包裹 ──────────────────────────────────────────────
      -- Normal 模式: sa + 范围动作 + 包裹符
      --   saiw)   光标在 hello 上  →  (hello)           给单词加圆括号
      --   saaw"   光标在 hello 上  →  "hello"           给单词加双引号
      --   saiW_   光标在 hello_world 上 → _hello_world_ 给大单词加下划线
      --   saip)   光标在段落内     →  整个段落被()包裹  给段落加圆括号
      --   saipf   光标在段落内     →  底部提示输入函数名，输入 print
      --           →  print(整段内容)                     给段落加函数调用
      --   saip?   光标在段落内     →  底部提示输入左符号，输入 /*
      --           →  再提示输入右符号，输入 */  →  /*整段内容*/
      --
      -- Visual 模式: 选中后 sa + 包裹符
      --   viw sa"  选中 hello  →  "hello"               给选中内容加双引号
      --   V2j sa(  选中3行     →  (三行内容)              给选中行加圆括号
      --
      -- ── sd: 删除包裹 ──────────────────────────────────────────────
      -- sd + 包裹符（自动找到包裹光标的那一对并删除）
      --   sd)   (hello)   →  hello          删除圆括号
      --   sd'   'hello'   →  hello          删除单引号
      --   sd"   "hello"   →  hello          删除双引号
      --   sdf   foo(x, y) →  x, y           删除函数调用（保留内容）
      --   sdt   <em>hi</em> →  hi            删除 HTML 标签
      --
      -- ── sr: 替换包裹 ──────────────────────────────────────────────
      -- sr + 旧包裹符 + 新包裹符
      --   sr)'   (hello)  →  'hello'        圆括号换成单引号
      --   sr([   (hello)  →  [hello]        圆括号换成方括号
      --   sr"{   "hello"  →  {hello}        双引号换成花括号
      --   sr)f   (hello)  →  底部提示输入函数名，输入 bar
      --                     →  bar(hello)   圆括号换成函数调用
      --   sr't   'hello'  →  底部提示输入标签名，输入 em
      --                     →  <em>hello</em>  单引号换成 HTML 标签
      --   srtf   <b>hi</b> →  底部提示输入函数名，输入 bold
      --                     →  bold(hi)     HTML 标签换成函数调用
      --
      -- ── sf / sF: 跳转到包裹符 ────────────────────────────────────
      -- sf + 包裹符  光标向右跳到匹配的右半边
      --   sf)   foo(bar|baz)  →  光标跳到 ) 位置
      -- sF + 包裹符  光标向左跳到匹配的左半边
      --   sF)   foo(bar|baz)  →  光标跳到 ( 位置
      --
      -- ── sh: 高亮包裹符对 ─────────────────────────────────────────
      -- sh + 包裹符  高亮匹配的一对（0.5秒后消失），用于确认要操作的是哪一对
      --   sh"   高亮光标附近的 "" 对
      --
      -- ── 后缀 n (next) / l (last): 改变搜索方向 ───────────────────
      -- 默认找包裹光标的那一对。有多对时用后缀指定:
      --   "foo" and |"bar" and "baz"     ← 光标在 | 位置
      --   sd'   →  删除包裹光标的 "bar"  →  "foo" and bar and "baz"
      --   sd'n  →  删除光标右边的 "baz"  →  "foo" and "bar" and baz
      --   sd'l  →  删除光标左边的 "foo"  →  foo and "bar" and "baz"
      -- 同理: sr'n" 替换下一个 '' 为 ""，sf)n 跳到下一个 )
      --
      -- ── 其他 ─────────────────────────────────────────────────────
      -- 支持 . 重复上次操作，支持数字前缀如 2sd' 删除两层
      --
      require('mini.surround').setup()

      require('mini.move').setup {
        mappings = {
          left = 'H',
          right = 'L',
          down = 'J',
          up = 'K',
          line_left = 'H',
          line_right = 'L',
          line_down = 'J',
          line_up = 'K',
        },
      }
      -- require('mini.indentscope').setup()
    end,
  },
}
