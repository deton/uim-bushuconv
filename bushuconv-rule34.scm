;;;
;;; Copyright (c) 2012 KIHARA Hideto https://github.com/deton/uim-bushuconv
;;;
;;; All rights reserved.
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:
;;; 1. Redistributions of source code must retain the above copyright
;;;    notice, this list of conditions and the following disclaimer.
;;; 2. Redistributions in binary form must reproduce the above copyright
;;;    notice, this list of conditions and the following disclaimer in the
;;;    documentation and/or other materials provided with the distribution.
;;; 3. Neither the name of authors nor the names of its contributors
;;;    may be used to endorse or promote products derived from this software
;;;    without specific prior written permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS'' AND
;;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE
;;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;;; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
;;; OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
;;; SUCH DAMAGE.
;;;;

;;; stroke-help candwin用のannotation追加や代替候補文字列への置換用alist。
;;; ("候補" "annotation" (("画数" "代替候補文字列")))
(define bushuconv-bushu-annotation-alist
  '(("く" "(巛)")
    ("フ" "(幻)")
    ("L" "(直 断)")
    ("乀" "(刄 及)")
    ;; 2画
    ("ソ" "(並 并 挟 曽 柬 為)")
    ("ユ" "(侯)")
    ("ナ" "(右 左 布 友 有)")
    ("マ" "(通 勇)")
    ("犯" "(枙 苑)" "(犯-犭)")
    ;; 3画
    ("キ" "(奉 津)")
    ("ツ" "(畄 鼡 単)")
    ("囗" "くにがまえ(国 固)")
    ;; 4画
    ("ホ" "(余 朮 茶)")
    ("ヰ" "(舛)")
    ("軣" "(塁 摂)" "(軣-車)")
    ("印" "(虐 襃 段)" "(印-卩)")
    ;; 5画
    ("売" "(壱 壷 壹 孛 / 殻 続)" (("5" "(売-儿)"))) ; 5画 / 7画
    ("並" "(虚 晋 普 霊 椪)" (("5" "(虚-虍)"))) ; 5画 / 8画
    ("施" "(駞 / 椸)" (("5" "(施-方)"))) ; 5画 / 9画
    ("珍" "(診 疹)" "(珍-王)")
    ;; 6画
    ("夾" "(峡 狭 / 俠 匧)" (("6" "(夹){夾}"))) ; 6画 / 7画
    ("峠" "(垰 挊 桛 裃 鞐)" "(峠-山)")
    ("巩" "(鞏 蛩)" "巩(恐-心)")
    ("旅" "(旄 旃)" "(旅-𠂢)")
    ;; 7画
    ("寝" "(寢 寤)" "(寢-侵)")
    ("侵" "(浸 駸)" "(侵-亻)")
    ("利" "(鯏 / 黎)" (("8" "(𥝢)(棃-木)"))) ; 7画 / 8画
    ;; 8画
    ("僉" "(倹 剣 検 / 儉 劍 匳)" (("8" "(検-木)"))) ; 8画 / 13画
    ("戔" "(棧 / 桟)" (("6" "(桟-木)"))) ; 6画 / 8画
    ("臽" "(焔 / 餡 / 㴞 / 熖)" (("7" "(焔-火)") ("9" "(㷔-火)") ("0" "(舀)(熖-火)"))) ; 7画 / 8画 / 9画 / 10画
    ("倍" "(殕 碚)" "(咅)(倍-亻)")
    ("啓" "(綮 肇)" "(啓-口)")
    ("昆" "(鯤 / 貔)" (("0" "(𣬉)(蓖-艹)"))) ; 8画 / 10画
    ;; 9画
    ("堙" "垔 (煙 湮 甄)" "(垔)(堙-土)")
    ("葉" "(喋 牒)" "(枼)")
    ("隨" "(惰 楕)" "(隋-阝)")
    ("曷" "(褐 / 渴)" (("8" "(掲-扌)"))) ; 8画 / 9画
    ("契" "(挈 / 楔)" (("6" "(契-大)"))) ; 6画 / 9画
    ("殻" "(轂 𧏚)" "(穀-禾)")
    ;; 10画
    ("寒" "寒-冫 (塞 搴 寨 謇 賽 蹇 騫)" "(寒-冫)")
    ("蚤" "(掻 / 騷)" (("8" "(掻-扌)"))) ; 8画 / 10画
    ("高" "(毫 / 犒)" (("7" "(亮-儿){高}"))) ; 7画 / 10画
    ("𦰩" "(嘆 / 槿)" (("q" "(堇)(僅-亻)"))) ; 10画 / 11画
    ("𤇾" "(鴬 / 撈)" (("5" "(労-力)"))) ; 5画 / 10画
    ("奚" "(鶏 / 溪)" (("8" "(渓-氵)"))) ; 8画 / 10画
    ("勝" "(縢 滕)" "(勝-力)")
    ;; 11画
    ("嗽" "欶 (漱 蔌)" "(欶)(嗽-口)")
    ("聲" "(馨 謦)" "(聲-耳)")
    ("郷" "(響 / 薌)" (("e" "(薌-艹)"))) ; 11画 / 13画
    ("醫" "(翳 毉)" "(醫-酉)")
    ("釐" "(嫠 斄)" "(釐-里)")
    ("鹿" "(薦 𢈘 / 漉 麕)" (("7" "(鹿-比)"))) ; 7画 / 11画
    ("産" "(偐 / 薩)" (("9" "(彦)(彥)"))) ; 9画 / 11画
    ("傷" "(殤 塲)" "(傷-亻)")
    ("婁" "(屡 / 樓)" (("9" "(娄)"))) ; 9画 / 11画
    ("撃" "(繋 / 墼)" (("q" "(軗)(撃-手)") ("e" "(𣪠)(繫-糸)"))) ; 11画 / 13画
    ("算" "(簒 纂)" "(算-廾)")
    ;; 12画
    ("徹" "(撤 轍)" "(徹-彳)")
    ("識" "(幟 熾)" "(識-言)")
    ("乱" "(辭 覶)" "(亂-乚)")
    ("樹" "(闘 / 廚)" (("0" "(厨-厂)") ("w" "(尌)(樹-木)"))) ; 10画 / 12画
    ("備" "(鞴 / 憊)" (("0" "(備-亻)"))) ; 10画 / 12画
    ("遷" "(僊 韆)" "(遷-辶)")
    ;; 13画
    ("壊" "(懐 / 褱)" (("e" "(壊-土)") ("y" "(褱)(壞-土)"))) ; 13画 / 16画
    ("劇" "(醵 據)" "(劇-刂)")
    ("夢" "(薨 / 儚)" (("0" "(夢-夕)"))) ; 10画 / 13画
    ;; 17画
    ("韱" "(纎 / 籤)" (("t" "(懴-忄)"))) ; 15画 / 17画
    ;; 18画
    ("雚" "(潅 / 權)" (("q" "(勧-力)"))) ; 11画 / 18画
    ;; その他
    ("3" "「蟲」「毳」「橸」等、同じ部品3つから成る漢字の合成用")))

;;; 何もキー入力が無い場合に表示する内容のalist。
(define bushuconv-rule-stroke-help-top-page-alist
  '(
    ("p" "*20画/その他")
    ("o" "*19画")
    ("i" "*18画")
    ("u" "*17画")
    ("y" "*16画")
    ("t" "*15画")
    ("r" "*14画")
    ("e" "*13画")
    ("w" "*12画")
    ("q" "*11画")
    ("0" "*10画")
    ("9" "*9画")
    ("8" "*8画")
    ("7" "*7画")
    ("6" "*6画")
    ("5" "*5画")
    ("4" "*4画")
    ("3" "*3画")
    ("2" "*2画")
    ("1" "*1画")))

(define bushuconv-rule
  '(
    ((("1" "1"))("一"))
    ((("1" "2"))("丶"))
    ((("1" "3"))("丿"))
    ((("1" "4"))("乚"))
    ((("1" "5"))("丨"))
    ((("1" "6"))("乙"))
    ((("1" "7"))("L"))
    ((("1" "8"))("フ"))
    ((("1" "9"))("く"))
    ((("1" "0"))("亅"))
    ((("1" "q"))("乀"))
    ((("1" "w"))("/"))
    ((("2" "1"))("亻"))
    ((("2" "2"))("冖"))
    ((("2" "3"))("刂"))
    ((("2" "4"))("力"))
    ((("2" "5"))("厂"))
    ((("2" "6"))("又"))
    ((("2" "7"))("十"))
    ((("2" "8"))("勹"))
    ((("2" "9"))("刀"))
    ((("2" "0"))("八"))
    ((("2" "q"))("𠂉"))
    ((("2" "w"))("𠆢"))
    ((("2" "e"))("厶"))
    ((("2" "r"))("儿"))
    ((("2" "t"))("ソ"))
    ((("2" "y"))("亠"))
    ((("2" "u"))("冫"))
    ((("2" "i"))("匚"))
    ((("2" "o"))("卩"))
    ((("2" "p"))("人"))
    ((("2" "a"))("匕"))
    ((("2" "s"))("丂"))
    ((("2" "d"))("二"))
    ((("2" "f"))("乂"))
    ((("2" "g"))("冂"))
    ((("2" "h"))("几"))
    ((("2" "j"))("丁"))
    ((("2" "k"))("卜"))
    ((("2" "l"))("ク"))
    ((("2" ";"))("九"))
    ((("2" "z"))("凵"))
    ((("2" "x"))("犯"))
    ((("2" "c"))("乃"))
    ((("2" "v"))("入"))
    ((("2" "b"))("𠘨"))
    ((("2" "n"))("ナ"))
    ((("2" "m"))("丩"))
    ((("2" ","))("ン"))
    ((("2" "."))("七"))
    ((("2" "/"))("コ"))
    ((("2" "Q"))("了"))
    ((("2" "W"))("マ"))
    ((("2" "E"))("ユ"))
    ((("2" "R"))("匸"))
    ((("3" "1"))("氵"))
    ((("3" "2"))("艹"))
    ((("3" "3"))("口"))
    ((("3" "4"))("扌"))
    ((("3" "5"))("土"))
    ((("3" "6"))("忄"))
    ((("3" "7"))("女"))
    ((("3" "8"))("山"))
    ((("3" "9"))("阝"))
    ((("3" "0"))("宀"))
    ((("3" "q"))("犭"))
    ((("3" "w"))("大"))
    ((("3" "e"))("广"))
    ((("3" "r"))("巾"))
    ((("3" "t"))("囗"))
    ((("3" "y"))("彳"))
    ((("3" "u"))("辶"))
    ((("3" "i"))("弓"))
    ((("3" "o"))("彡"))
    ((("3" "p"))("子"))
    ((("3" "a"))("夂"))
    ((("3" "s"))("尸"))
    ((("3" "d"))("巳"))
    ((("3" "f"))("工"))
    ((("3" "g"))("夕"))
    ((("3" "h"))("寸"))
    ((("3" "j"))("干"))
    ((("3" "k"))("小"))
    ((("3" "l"))("幺"))
    ((("3" ";"))("士"))
    ((("3" "z"))("ヨ"))
    ((("3" "x"))("廾"))
    ((("3" "c"))("也"))
    ((("3" "v"))("亼"))
    ((("3" "b"))("亡"))
    ((("3" "n"))("勺"))
    ((("3" "m"))("己"))
    ((("3" ","))("ツ"))
    ((("3" "."))("千"))
    ((("3" "/"))("于"))
    ((("3" "Q"))("䒑"))
    ((("3" "W"))("下"))
    ((("3" "E"))("及"))
    ((("3" "R"))("川"))
    ((("3" "T"))("上"))
    ((("3" "Y"))("凡"))
    ((("3" "U"))("三"))
    ((("3" "I"))("兀"))
    ((("3" "O"))("丸"))
    ((("3" "P"))("乞"))
    ((("3" "A"))("巛"))
    ((("3" "S"))("久"))
    ((("3" "D"))("弋"))
    ((("3" "F"))("乇"))
    ((("3" "G"))("卂"))
    ((("3" "H"))("屮"))
    ((("3" "J"))("刄"))
    ((("3" "K"))("尢"))
    ((("3" "L"))("廴"))
    ((("3" "+"))("彑"))
    ((("3" "Z"))("万"))
    ((("3" "X"))("才"))
    ((("3" "C"))("屮"))
    ((("3" "V"))("キ"))
    ((("3" "B"))("丬"))
    ((("3" "N"))("与"))
    ((("3" "M"))("丈"))
    ((("3" "<"))("之"))
    ((("4" "1"))("木"))
    ((("4" "2"))("月"))
    ((("4" "3"))("日"))
    ((("4" "4"))("王"))
    ((("4" "5"))("火"))
    ((("4" "6"))("心"))
    ((("4" "7"))("辶"))
    ((("4" "8"))("攵"))
    ((("4" "9"))("爫"))
    ((("4" "0"))("欠"))
    ((("4" "q"))("殳"))
    ((("4" "w"))("中"))
    ((("4" "e"))("戈"))
    ((("4" "r"))("方"))
    ((("4" "t"))("丰"))
    ((("4" "y"))("灬"))
    ((("4" "u"))("止"))
    ((("4" "i"))("斤"))
    ((("4" "o"))("戸"))
    ((("4" "p"))("夫"))
    ((("4" "a"))("歹"))
    ((("4" "s"))("牛"))
    ((("4" "d"))("文"))
    ((("4" "f"))("比"))
    ((("4" "g"))("犬"))
    ((("4" "h"))("毛"))
    ((("4" "j"))("分"))
    ((("4" "k"))("廿"))
    ((("4" "l"))("手"))
    ((("4" ";"))("元"))
    ((("4" "z"))("今"))
    ((("4" "x"))("少"))
    ((("4" "c"))("水"))
    ((("4" "v"))("円"))
    ((("4" "b"))("巴"))
    ((("4" "n"))("支"))
    ((("4" "m"))("爿"))
    ((("4" ","))("屯"))
    ((("4" "."))("介"))
    ((("4" "/"))("氏"))
    ((("4" "Q"))("斗"))
    ((("4" "W"))("内"))
    ((("4" "E"))("亢"))
    ((("4" "R"))("尹"))
    ((("4" "T"))("云"))
    ((("4" "Y"))("反"))
    ((("4" "U"))("片"))
    ((("4" "I"))("夬"))
    ((("4" "O"))("礻"))
    ((("4" "P"))("勿"))
    ((("4" "A"))("从"))
    ((("4" "S"))("夭"))
    ((("4" "D"))("牙"))
    ((("4" "F"))("公"))
    ((("4" "G"))("壬"))
    ((("4" "H"))("予"))
    ((("4" "J"))("冘"))
    ((("4" "K"))("天"))
    ((("4" "L"))("尺"))
    ((("4" "+"))("不"))
    ((("4" "Z"))("尤"))
    ((("4" "X"))("气"))
    ((("4" "C"))("厷"))
    ((("4" "V"))("区"))
    ((("4" "B"))("弔"))
    ((("4" "N"))("牜"))
    ((("4" "M"))("开"))
    ((("4" "<"))("午"))
    ((("4" ">"))("旡"))
    ((("4" "?"))("井"))
    ((("4" "!"))("卆"))
    ((("4" "\""))("攴"))
    ((("4" "#"))("丑"))
    ((("4" "$"))("太"))
    ((("4" "%"))("爪"))
    ((("4" "&"))("父"))
    ((("4" "'"))("友"))
    ((("4" "("))("爻"))
    ((("4" ")"))("耂"))
    ((("4" "-"))("五"))
    ((("4" "^"))("禸"))
    ((("4" "\\"))("㣺"))
    ((("4" "@"))("ホ"))
    ((("4" "["))("印"))
    ((("4" ":"))("毋"))
    ((("4" "]"))("軣"))
    ((("4" "="))("匀"))
    ((("4" "~"))("卬"))
    ((("4" "|"))("𠬝"))
    ((("4" "`"))("ヰ"))
    ((("4" "{"))("互"))
    ((("5" "1"))("石"))
    ((("5" "2"))("疒"))
    ((("5" "3"))("禾"))
    ((("5" "4"))("目"))
    ((("5" "5"))("衤"))
    ((("5" "6"))("田"))
    ((("5" "7"))("示"))
    ((("5" "8"))("立"))
    ((("5" "9"))("罒"))
    ((("5" "0"))("穴"))
    ((("5" "q"))("白"))
    ((("5" "w"))("皿"))
    ((("5" "e"))("且"))
    ((("5" "r"))("由"))
    ((("5" "t"))("占"))
    ((("5" "y"))("瓦"))
    ((("5" "u"))("令"))
    ((("5" "i"))("氺"))
    ((("5" "o"))("世"))
    ((("5" "p"))("矢"))
    ((("5" "a"))("包"))
    ((("5" "s"))("台"))
    ((("5" "d"))("生"))
    ((("5" "f"))("句"))
    ((("5" "g"))("皮"))
    ((("5" "h"))("氐"))
    ((("5" "j"))("古"))
    ((("5" "k"))("召"))
    ((("5" "l"))("兄"))
    ((("5" ";"))("可"))
    ((("5" "z"))("去"))
    ((("5" "x"))("玄"))
    ((("5" "c"))("旦"))
    ((("5" "v"))("乍"))
    ((("5" "b"))("正"))
    ((("5" "n"))("売"))
    ((("5" "m"))("必"))
    ((("5" ","))("甲"))
    ((("5" "."))("疋"))
    ((("5" "/"))("央"))
    ((("5" "Q"))("巨"))
    ((("5" "W"))("甘"))
    ((("5" "E"))("珍"))
    ((("5" "R"))("弗"))
    ((("5" "T"))("它"))
    ((("5" "Y"))("犮"))
    ((("5" "U"))("加"))
    ((("5" "I"))("申"))
    ((("5" "O"))("半"))
    ((("5" "P"))("付"))
    ((("5" "A"))("卯"))
    ((("5" "S"))("失"))
    ((("5" "D"))("出"))
    ((("5" "F"))("丙"))
    ((("5" "G"))("冋"))
    ((("5" "H"))("未"))
    ((("5" "J"))("民"))
    ((("5" "K"))("主"))
    ((("5" "L"))("尼"))
    ((("5" "+"))("奴"))
    ((("5" "Z"))("平"))
    ((("5" "X"))("弁"))
    ((("5" "C"))("玉"))
    ((("5" "V"))("市"))
    ((("5" "B"))("矛"))
    ((("5" "N"))("尓"))
    ((("5" "M"))("永"))
    ((("5" "<"))("左"))
    ((("5" ">"))("四"))
    ((("5" "?"))("施"))
    ((("5" "!"))("末"))
    ((("5" "\""))("用"))
    ((("5" "#"))("丕"))
    ((("5" "$"))("圣"))
    ((("5" "%"))("𡗗"))
    ((("5" "&"))("旧"))
    ((("5" "'"))("冊"))
    ((("5" "("))("司"))
    ((("5" ")"))("並"))
    ((("5" "-"))("北"))
    ((("5" "^"))("幼"))
    ((("5" "\\"))("丘"))
    ((("5" "@"))("代"))
    ((("5" "["))("冬"))
    ((("5" ":"))("本"))
    ((("5" "]"))("冉"))
    ((("5" "="))("只"))
    ((("5" "~"))("㠯"))
    ((("5" "|"))("𤇾"))
    ((("5" "`"))("癶"))
    ((("5" "{"))("以"))
    ((("5" "*"))("史"))
    ((("5" "}"))("歺"))
    ((("5" "_"))("乎"))
    ((("6" "1"))("糸"))
    ((("6" "2"))("虫"))
    ((("6" "3"))("竹"))
    ((("6" "4"))("米"))
    ((("6" "5"))("耳"))
    ((("6" "6"))("羽"))
    ((("6" "7"))("舟"))
    ((("6" "8"))("衣"))
    ((("6" "9"))("共"))
    ((("6" "0"))("臼"))
    ((("6" "q"))("圭"))
    ((("6" "w"))("羊"))
    ((("6" "e"))("合"))
    ((("6" "r"))("至"))
    ((("6" "t"))("各"))
    ((("6" "y"))("行"))
    ((("6" "u"))("自"))
    ((("6" "i"))("交"))
    ((("6" "o"))("虍"))
    ((("6" "p"))("𠔉"))
    ((("6" "a"))("舌"))
    ((("6" "s"))("同"))
    ((("6" "d"))("𦍌"))
    ((("6" "f"))("艮"))
    ((("6" "g"))("覀"))
    ((("6" "h"))("缶"))
    ((("6" "j"))("兆"))
    ((("6" "k"))("光"))
    ((("6" "l"))("亥"))
    ((("6" ";"))("吉"))
    ((("6" "z"))("此"))
    ((("6" "x"))("瓜"))
    ((("6" "c"))("兇"))
    ((("6" "v"))("有"))
    ((("6" "b"))("并"))
    ((("6" "n"))("耒"))
    ((("6" "m"))("回"))
    ((("6" ","))("聿"))
    ((("6" "."))("朱"))
    ((("6" "/"))("旬"))
    ((("6" "Q"))("先"))
    ((("6" "W"))("旅"))
    ((("6" "E"))("夸"))
    ((("6" "R"))("血"))
    ((("6" "T"))("次"))
    ((("6" "Y"))("多"))
    ((("6" "U"))("百"))
    ((("6" "I"))("𢦏"))
    ((("6" "O"))("而"))
    ((("6" "P"))("西"))
    ((("6" "A"))("安"))
    ((("6" "S"))("成"))
    ((("6" "D"))("亘"))
    ((("6" "F"))("孛"))
    ((("6" "G"))("寺"))
    ((("6" "H"))("因"))
    ((("6" "J"))("危"))
    ((("6" "K"))("全"))
    ((("6" "L"))("早"))
    ((("6" "+"))("亦"))
    ((("6" "Z"))("老"))
    ((("6" "X"))("囟"))
    ((("6" "C"))("𠂤"))
    ((("6" "V"))("列"))
    ((("6" "B"))("戔"))
    ((("6" "N"))("夷"))
    ((("6" "M"))("契"))
    ((("6" "<"))("旨"))
    ((("6" ">"))("争"))
    ((("6" "?"))("如"))
    ((("6" "!"))("牟"))
    ((("6" "\""))("向"))
    ((("6" "#"))("后"))
    ((("6" "$"))("色"))
    ((("6" "%"))("肉"))
    ((("6" "&"))("夾"))
    ((("6" "'"))("幵"))
    ((("6" "("))("曲"))
    ((("6" ")"))("舛"))
    ((("6" "-"))("巩"))
    ((("6" "^"))("𠂢"))
    ((("6" "\\"))("关"))
    ((("6" "@"))("会"))
    ((("6" "["))("峠"))
    ((("6" ":"))("朿"))
    ((("6" "]"))("灰"))
    ((("6" "="))("在"))
    ((("6" "~"))("当"))
    ((("6" "|"))("両"))
    ((("6" "`"))("※"))
    ((("6" "{"))("襾"))
    ((("6" "*"))("年"))
    ((("7" "1"))("言"))
    ((("7" "2"))("𧾷"))
    ((("7" "3"))("車"))
    ((("7" "4"))("貝"))
    ((("7" "5"))("酉"))
    ((("7" "6"))("見"))
    ((("7" "7"))("豕"))
    ((("7" "8"))("良"))
    ((("7" "9"))("角"))
    ((("7" "0"))("走"))
    ((("7" "q"))("肖"))
    ((("7" "w"))("臣"))
    ((("7" "e"))("甫"))
    ((("7" "r"))("兌"))
    ((("7" "t"))("谷"))
    ((("7" "y"))("豆"))
    ((("7" "u"))("辛"))
    ((("7" "i"))("豸"))
    ((("7" "o"))("身"))
    ((("7" "p"))("完"))
    ((("7" "a"))("里"))
    ((("7" "s"))("夋"))
    ((("7" "d"))("束"))
    ((("7" "f"))("余"))
    ((("7" "g"))("夾"))
    ((("7" "h"))("告"))
    ((("7" "j"))("吾"))
    ((("7" "k"))("辰"))
    ((("7" "l"))("我"))
    ((("7" ";"))("孚"))
    ((("7" "z"))("君"))
    ((("7" "x"))("足"))
    ((("7" "c"))("巠"))
    ((("7" "v"))("每"))
    ((("7" "b"))("肙"))
    ((("7" "n"))("求"))
    ((("7" "m"))("弟"))
    ((("7" ","))("更"))
    ((("7" "."))("呈"))
    ((("7" "/"))("攸"))
    ((("7" "Q"))("折"))
    ((("7" "W"))("邑"))
    ((("7" "E"))("利"))
    ((("7" "R"))("呂"))
    ((("7" "T"))("甬"))
    ((("7" "Y"))("𦥑"))
    ((("7" "U"))("坐"))
    ((("7" "I"))("侵"))
    ((("7" "O"))("赤"))
    ((("7" "P"))("廷"))
    ((("7" "A"))("希"))
    ((("7" "S"))("呉"))
    ((("7" "D"))("寿"))
    ((("7" "F"))("旱"))
    ((("7" "G"))("镸"))
    ((("7" "H"))("孝"))
    ((("7" "J"))("矣"))
    ((("7" "K"))("㐬"))
    ((("7" "L"))("妥"))
    ((("7" "+"))("男"))
    ((("7" "Z"))("釆"))
    ((("7" "X"))("冏"))
    ((("7" "C"))("皀"))
    ((("7" "V"))("含"))
    ((("7" "B"))("秀"))
    ((("7" "N"))("声"))
    ((("7" "M"))("壯"))
    ((("7" "<"))("𦣝"))
    ((("7" ">"))("亜"))
    ((("7" "?"))("高"))
    ((("7" "!"))("寝"))
    ((("7" "\""))("兵"))
    ((("7" "#"))("即"))
    ((("7" "$"))("禿"))
    ((("7" "%"))("麦"))
    ((("7" "&"))("鹿"))
    ((("7" "'"))("寽"))
    ((("7" "("))("売"))
    ((("7" ")"))("来"))
    ((("7" "-"))("条"))
    ((("7" "^"))("臽"))
    ((("8" "1"))("金"))
    ((("8" "2"))("門"))
    ((("8" "3"))("隹"))
    ((("8" "4"))("雨"))
    ((("8" "5"))("林"))
    ((("8" "6"))("青"))
    ((("8" "7"))("非"))
    ((("8" "8"))("其"))
    ((("8" "9"))("奇"))
    ((("8" "0"))("卒"))
    ((("8" "q"))("卑"))
    ((("8" "w"))("果"))
    ((("8" "e"))("炎"))
    ((("8" "r"))("京"))
    ((("8" "t"))("虎"))
    ((("8" "y"))("尚"))
    ((("8" "u"))("免"))
    ((("8" "i"))("宛"))
    ((("8" "o"))("周"))
    ((("8" "p"))("享"))
    ((("8" "a"))("取"))
    ((("8" "s"))("昔"))
    ((("8" "d"))("彔"))
    ((("8" "f"))("來"))
    ((("8" "g"))("易"))
    ((("8" "h"))("奄"))
    ((("8" "j"))("宗"))
    ((("8" "k"))("卓"))
    ((("8" "l"))("長"))
    ((("8" ";"))("昆"))
    ((("8" "z"))("倍"))
    ((("8" "x"))("夌"))
    ((("8" "c"))("忩"))
    ((("8" "v"))("東"))
    ((("8" "b"))("戔"))
    ((("8" "n"))("委"))
    ((("8" "m"))("垂"))
    ((("8" ","))("亞"))
    ((("8" "."))("臽"))
    ((("8" "/"))("延"))
    ((("8" "Q"))("官"))
    ((("8" "W"))("空"))
    ((("8" "E"))("侖"))
    ((("8" "R"))("兒"))
    ((("8" "T"))("卷"))
    ((("8" "Y"))("叕"))
    ((("8" "U"))("育"))
    ((("8" "I"))("昌"))
    ((("8" "O"))("朋"))
    ((("8" "P"))("僉"))
    ((("8" "A"))("爭"))
    ((("8" "S"))("或"))
    ((("8" "D"))("若"))
    ((("8" "F"))("斉"))
    ((("8" "G"))("𠦝"))
    ((("8" "H"))("英"))
    ((("8" "J"))("幸"))
    ((("8" "K"))("采"))
    ((("8" "L"))("定"))
    ((("8" "+"))("武"))
    ((("8" "Z"))("飠"))
    ((("8" "X"))("幷"))
    ((("8" "C"))("固"))
    ((("8" "V"))("妻"))
    ((("8" "B"))("者"))
    ((("8" "N"))("叔"))
    ((("8" "M"))("直"))
    ((("8" "<"))("典"))
    ((("8" ">"))("念"))
    ((("8" "?"))("匊"))
    ((("8" "!"))("甾"))
    ((("8" "\""))("疌"))
    ((("8" "#"))("居"))
    ((("8" "$"))("帚"))
    ((("8" "%"))("兩"))
    ((("8" "&"))("亟"))
    ((("8" "'"))("隶"))
    ((("8" "("))("夜"))
    ((("8" ")"))("利"))
    ((("8" "-"))("啓"))
    ((("8" "^"))("国"))
    ((("8" "\\"))("参"))
    ((("8" "@"))("曷"))
    ((("8" "["))("舎"))
    ((("8" ":"))("毒"))
    ((("8" "]"))("奚"))
    ((("8" "="))("並"))
    ((("8" "~"))("事"))
    ((("8" "|"))("蚤"))
    ((("8" "`"))("阜"))
    ((("8" "{"))("冐"))
    ((("8" "*"))("鼡"))
    ((("8" "}"))("叀"))
    ((("9" "1"))("頁"))
    ((("9" "2"))("革"))
    ((("9" "3"))("𩙿"))
    ((("9" "4"))("韋"))
    ((("9" "5"))("者"))
    ((("9" "6"))("風"))
    ((("9" "7"))("昜"))
    ((("9" "8"))("兪"))
    ((("9" "9"))("曷"))
    ((("9" "0"))("音"))
    ((("9" "q"))("軍"))
    ((("9" "w"))("葉"))
    ((("9" "e"))("皇"))
    ((("9" "r"))("是"))
    ((("9" "t"))("扁"))
    ((("9" "y"))("甚"))
    ((("9" "u"))("茲"))
    ((("9" "i"))("叚"))
    ((("9" "o"))("畐"))
    ((("9" "p"))("耑"))
    ((("9" "a"))("咸"))
    ((("9" "s"))("秋"))
    ((("9" "d"))("食"))
    ((("9" "f"))("咼"))
    ((("9" "g"))("帝"))
    ((("9" "h"))("胡"))
    ((("9" "j"))("思"))
    ((("9" "k"))("爰"))
    ((("9" "l"))("禺"))
    ((("9" ";"))("殻"))
    ((("9" "z"))("重"))
    ((("9" "x"))("咢"))
    ((("9" "c"))("彖"))
    ((("9" "v"))("春"))
    ((("9" "b"))("貞"))
    ((("9" "n"))("面"))
    ((("9" "m"))("柬"))
    ((("9" ","))("隨"))
    ((("9" "."))("复"))
    ((("9" "/"))("侯"))
    ((("9" "Q"))("宣"))
    ((("9" "W"))("前"))
    ((("9" "E"))("品"))
    ((("9" "R"))("韭"))
    ((("9" "T"))("飠"))
    ((("9" "Y"))("壴"))
    ((("9" "U"))("皆"))
    ((("9" "I"))("香"))
    ((("9" "O"))("星"))
    ((("9" "P"))("単"))
    ((("9" "A"))("南"))
    ((("9" "S"))("咠"))
    ((("9" "D"))("畏"))
    ((("9" "F"))("屋"))
    ((("9" "G"))("契"))
    ((("9" "H"))("建"))
    ((("9" "J"))("酋"))
    ((("9" "K"))("柔"))
    ((("9" "L"))("怱"))
    ((("9" "+"))("癸"))
    ((("9" "Z"))("胥"))
    ((("9" "X"))("臤"))
    ((("9" "C"))("𡿺"))
    ((("9" "V"))("産"))
    ((("9" "B"))("査"))
    ((("9" "N"))("室"))
    ((("9" "M"))("為"))
    ((("9" "<"))("首"))
    ((("9" ">"))("奏"))
    ((("9" "?"))("婁"))
    ((("9" "!"))("堙"))
    ((("9" "\""))("臿"))
    ((("9" "#"))("発"))
    ((("9" "$"))("臽"))
    ((("9" "%"))("巻"))
    ((("9" "&"))("県"))
    ((("9" "'"))("施"))
    ((("9" "("))("乗"))
    ((("9" ")"))("度"))
    ((("9" "-"))("卑"))
    ((("9" "^"))("飛"))
    ((("0" "1"))("馬"))
    ((("0" "2"))("髟"))
    ((("0" "3"))("骨"))
    ((("0" "4"))("鬼"))
    ((("0" "5"))("高"))
    ((("0" "6"))("兼"))
    ((("0" "7"))("𤇾"))
    ((("0" "8"))("𥁕"))
    ((("0" "9"))("眞"))
    ((("0" "0"))("莫"))
    ((("0" "q"))("䍃"))
    ((("0" "w"))("奚"))
    ((("0" "e"))("差"))
    ((("0" "r"))("倉"))
    ((("0" "t"))("員"))
    ((("0" "y"))("豈"))
    ((("0" "u"))("鬲"))
    ((("0" "i"))("華"))
    ((("0" "o"))("容"))
    ((("0" "p"))("冓"))
    ((("0" "a"))("尃"))
    ((("0" "s"))("叟"))
    ((("0" "d"))("旁"))
    ((("0" "f"))("益"))
    ((("0" "g"))("芻"))
    ((("0" "h"))("𦰩"))
    ((("0" "j"))("寒"))
    ((("0" "k"))("勝"))
    ((("0" "l"))("唐"))
    ((("0" ";"))("留"))
    ((("0" "z"))("盍"))
    ((("0" "x"))("臽"))
    ((("0" "c"))("离"))
    ((("0" "v"))("臭"))
    ((("0" "b"))("夏"))
    ((("0" "n"))("弱"))
    ((("0" "m"))("冥"))
    ((("0" ","))("既"))
    ((("0" "."))("原"))
    ((("0" "/"))("般"))
    ((("0" "Q"))("鬥"))
    ((("0" "W"))("挙"))
    ((("0" "E"))("昆"))
    ((("0" "R"))("将"))
    ((("0" "T"))("真"))
    ((("0" "Y"))("島"))
    ((("0" "U"))("蚤"))
    ((("0" "I"))("能"))
    ((("0" "O"))("索"))
    ((("0" "P"))("樹"))
    ((("0" "A"))("帯"))
    ((("0" "S"))("備"))
    ((("q" "1"))("魚"))
    ((("q" "2"))("鳥"))
    ((("q" "3"))("鹿"))
    ((("q" "4"))("翏"))
    ((("q" "5"))("票"))
    ((("q" "6"))("婁"))
    ((("q" "7"))("區"))
    ((("q" "8"))("章"))
    ((("q" "9"))("參"))
    ((("q" "0"))("敖"))
    ((("q" "q"))("𦰩"))
    ((("q" "w"))("責"))
    ((("q" "e"))("專"))
    ((("q" "r"))("曼"))
    ((("q" "t"))("皐"))
    ((("q" "y"))("麻"))
    ((("q" "u"))("斬"))
    ((("q" "i"))("將"))
    ((("q" "o"))("崔"))
    ((("q" "p"))("從"))
    ((("q" "a"))("麥"))
    ((("q" "s"))("㒼"))
    ((("q" "d"))("強"))
    ((("q" "f"))("畢"))
    ((("q" "g"))("啇"))
    ((("q" "h"))("祭"))
    ((("q" "j"))("執"))
    ((("q" "k"))("庸"))
    ((("q" "l"))("帶"))
    ((("q" ";"))("巢"))
    ((("q" "z"))("頃"))
    ((("q" "x"))("粛"))
    ((("q" "c"))("國"))
    ((("q" "v"))("鹵"))
    ((("q" "b"))("傷"))
    ((("q" "n"))("曽"))
    ((("q" "m"))("竟"))
    ((("q" ","))("黄"))
    ((("q" "."))("亀"))
    ((("q" "/"))("産"))
    ((("q" "Q"))("算"))
    ((("q" "W"))("嗽"))
    ((("q" "E"))("聲"))
    ((("q" "R"))("釐"))
    ((("q" "T"))("桼"))
    ((("q" "Y"))("雚"))
    ((("q" "U"))("断"))
    ((("q" "I"))("郷"))
    ((("q" "O"))("撃"))
    ((("q" "P"))("黒"))
    ((("q" "A"))("旋"))
    ((("q" "S"))("醫"))
    ((("w" "1"))("單"))
    ((("w" "2"))("黑"))
    ((("w" "3"))("番"))
    ((("w" "4"))("堯"))
    ((("w" "5"))("間"))
    ((("w" "6"))("尞"))
    ((("w" "7"))("喜"))
    ((("w" "8"))("貴"))
    ((("w" "9"))("喬"))
    ((("w" "0"))("登"))
    ((("w" "q"))("焦"))
    ((("w" "w"))("曾"))
    ((("w" "e"))("童"))
    ((("w" "r"))("無"))
    ((("w" "t"))("敝"))
    ((("w" "y"))("黃"))
    ((("w" "u"))("覃"))
    ((("w" "i"))("幾"))
    ((("w" "o"))("賁"))
    ((("w" "p"))("矞"))
    ((("w" "a"))("尊"))
    ((("w" "s"))("巽"))
    ((("w" "d"))("厤"))
    ((("w" "f"))("發"))
    ((("w" "g"))("肅"))
    ((("w" "h"))("菐"))
    ((("w" "j"))("斯"))
    ((("w" "k"))("尋"))
    ((("w" "l"))("達"))
    ((("w" ";"))("敦"))
    ((("w" "z"))("惠"))
    ((("w" "x"))("萬"))
    ((("w" "c"))("畱"))
    ((("w" "v"))("識"))
    ((("w" "b"))("替"))
    ((("w" "n"))("爲"))
    ((("w" "m"))("雁"))
    ((("w" ","))("歯"))
    ((("w" "."))("𢛳"))
    ((("w" "/"))("徹"))
    ((("w" "Q"))("奥"))
    ((("w" "W"))("乱"))
    ((("w" "E"))("樹"))
    ((("w" "R"))("普"))
    ((("w" "T"))("黍"))
    ((("w" "Y"))("遷"))
    ((("w" "U"))("備"))
    ((("e" "1"))("僉"))
    ((("e" "2"))("辟"))
    ((("e" "3"))("粦"))
    ((("e" "4"))("亶"))
    ((("e" "5"))("睘"))
    ((("e" "6"))("鼠"))
    ((("e" "7"))("黽"))
    ((("e" "8"))("會"))
    ((("e" "9"))("睪"))
    ((("e" "0"))("蜀"))
    ((("e" "q"))("詹"))
    ((("e" "w"))("喿"))
    ((("e" "e"))("蒦"))
    ((("e" "r"))("豊"))
    ((("e" "t"))("義"))
    ((("e" "y"))("歳"))
    ((("e" "u"))("蒙"))
    ((("e" "i"))("敫"))
    ((("e" "o"))("𦥯"))
    ((("e" "p"))("愛"))
    ((("e" "a"))("解"))
    ((("e" "s"))("業"))
    ((("e" "d"))("奧"))
    ((("e" "f"))("畺"))
    ((("e" "g"))("意"))
    ((("e" "h"))("農"))
    ((("e" "j"))("嗇"))
    ((("e" "k"))("鼓"))
    ((("e" "l"))("當"))
    ((("e" ";"))("劇"))
    ((("e" "z"))("禀"))
    ((("e" "x"))("㐮"))
    ((("e" "c"))("幹"))
    ((("e" "v"))("稟"))
    ((("e" "b"))("撃"))
    ((("e" "n"))("楽"))
    ((("e" "m"))("鼎"))
    ((("e" ","))("夢"))
    ((("e" "."))("郷"))
    ((("e" "/"))("聖"))
    ((("e" "Q"))("節"))
    ((("e" "W"))("壊"))
    ((("e" "E"))("黹"))
    ((("r" "1"))("壽"))
    ((("r" "2"))("需"))
    ((("r" "3"))("鼻"))
    ((("r" "4"))("齊"))
    ((("r" "5"))("爾"))
    ((("r" "6"))("翟"))
    ((("r" "7"))("賓"))
    ((("r" "8"))("厭"))
    ((("r" "9"))("徴"))
    ((("r" "0"))("寧"))
    ((("r" "q"))("疑"))
    ((("r" "w"))("㬎"))
    ((("r" "e"))("蔑"))
    ((("t" "1"))("齒"))
    ((("t" "2"))("監"))
    ((("t" "3"))("廣"))
    ((("t" "4"))("𧶠"))
    ((("t" "5"))("畾"))
    ((("t" "6"))("賛"))
    ((("t" "7"))("樂"))
    ((("t" "8"))("巤"))
    ((("t" "9"))("器"))
    ((("t" "0"))("黎"))
    ((("t" "q"))("韱"))
    ((("y" "1"))("龍"))
    ((("y" "2"))("盧"))
    ((("y" "3"))("與"))
    ((("y" "4"))("歷"))
    ((("y" "5"))("興"))
    ((("y" "6"))("壊"))
    ((("y" "7"))("頼"))
    ((("y" "8"))("頽"))
    ((("y" "9"))("龜"))
    ((("y" "0"))("褱"))
    ((("u" "1"))("襄"))
    ((("u" "2"))("闌"))
    ((("u" "3"))("嬰"))
    ((("u" "4"))("龠"))
    ((("u" "5"))("毚"))
    ((("u" "6"))("韱"))
    ((("u" "7"))("爵"))
    ((("u" "8"))("厳"))
    ((("i" "1"))("雚"))
    ((("i" "2"))("瞿"))
    ((("i" "3"))("聶"))
    ((("i" "4"))("豐"))
    ((("o" "1"))("䜌"))
    ((("o" "2"))("麗"))
    ((("o" "3"))("贊"))
    ((("o" "4"))("羅"))
    ((("o" "5"))("蘭"))
    ((("p" "1"))("嚴"))
    ((("a" "1"))("3"))
    ))
