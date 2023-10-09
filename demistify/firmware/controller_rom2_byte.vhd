
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"01",x"01",x"00",x"00"),
     1 => (x"01",x"01",x"7f",x"7f"),
     2 => (x"7f",x"3f",x"00",x"00"),
     3 => (x"3f",x"7f",x"40",x"40"),
     4 => (x"3f",x"0f",x"00",x"00"),
     5 => (x"0f",x"3f",x"70",x"70"),
     6 => (x"30",x"7f",x"7f",x"00"),
     7 => (x"7f",x"7f",x"30",x"18"),
     8 => (x"36",x"63",x"41",x"00"),
     9 => (x"63",x"36",x"1c",x"1c"),
    10 => (x"06",x"03",x"01",x"41"),
    11 => (x"03",x"06",x"7c",x"7c"),
    12 => (x"59",x"71",x"61",x"01"),
    13 => (x"41",x"43",x"47",x"4d"),
    14 => (x"7f",x"00",x"00",x"00"),
    15 => (x"00",x"41",x"41",x"7f"),
    16 => (x"06",x"03",x"01",x"00"),
    17 => (x"60",x"30",x"18",x"0c"),
    18 => (x"41",x"00",x"00",x"40"),
    19 => (x"00",x"7f",x"7f",x"41"),
    20 => (x"06",x"0c",x"08",x"00"),
    21 => (x"08",x"0c",x"06",x"03"),
    22 => (x"80",x"80",x"80",x"00"),
    23 => (x"80",x"80",x"80",x"80"),
    24 => (x"00",x"00",x"00",x"00"),
    25 => (x"00",x"04",x"07",x"03"),
    26 => (x"74",x"20",x"00",x"00"),
    27 => (x"78",x"7c",x"54",x"54"),
    28 => (x"7f",x"7f",x"00",x"00"),
    29 => (x"38",x"7c",x"44",x"44"),
    30 => (x"7c",x"38",x"00",x"00"),
    31 => (x"00",x"44",x"44",x"44"),
    32 => (x"7c",x"38",x"00",x"00"),
    33 => (x"7f",x"7f",x"44",x"44"),
    34 => (x"7c",x"38",x"00",x"00"),
    35 => (x"18",x"5c",x"54",x"54"),
    36 => (x"7e",x"04",x"00",x"00"),
    37 => (x"00",x"05",x"05",x"7f"),
    38 => (x"bc",x"18",x"00",x"00"),
    39 => (x"7c",x"fc",x"a4",x"a4"),
    40 => (x"7f",x"7f",x"00",x"00"),
    41 => (x"78",x"7c",x"04",x"04"),
    42 => (x"00",x"00",x"00",x"00"),
    43 => (x"00",x"40",x"7d",x"3d"),
    44 => (x"80",x"80",x"00",x"00"),
    45 => (x"00",x"7d",x"fd",x"80"),
    46 => (x"7f",x"7f",x"00",x"00"),
    47 => (x"44",x"6c",x"38",x"10"),
    48 => (x"00",x"00",x"00",x"00"),
    49 => (x"00",x"40",x"7f",x"3f"),
    50 => (x"0c",x"7c",x"7c",x"00"),
    51 => (x"78",x"7c",x"0c",x"18"),
    52 => (x"7c",x"7c",x"00",x"00"),
    53 => (x"78",x"7c",x"04",x"04"),
    54 => (x"7c",x"38",x"00",x"00"),
    55 => (x"38",x"7c",x"44",x"44"),
    56 => (x"fc",x"fc",x"00",x"00"),
    57 => (x"18",x"3c",x"24",x"24"),
    58 => (x"3c",x"18",x"00",x"00"),
    59 => (x"fc",x"fc",x"24",x"24"),
    60 => (x"7c",x"7c",x"00",x"00"),
    61 => (x"08",x"0c",x"04",x"04"),
    62 => (x"5c",x"48",x"00",x"00"),
    63 => (x"20",x"74",x"54",x"54"),
    64 => (x"3f",x"04",x"00",x"00"),
    65 => (x"00",x"44",x"44",x"7f"),
    66 => (x"7c",x"3c",x"00",x"00"),
    67 => (x"7c",x"7c",x"40",x"40"),
    68 => (x"3c",x"1c",x"00",x"00"),
    69 => (x"1c",x"3c",x"60",x"60"),
    70 => (x"60",x"7c",x"3c",x"00"),
    71 => (x"3c",x"7c",x"60",x"30"),
    72 => (x"38",x"6c",x"44",x"00"),
    73 => (x"44",x"6c",x"38",x"10"),
    74 => (x"bc",x"1c",x"00",x"00"),
    75 => (x"1c",x"3c",x"60",x"e0"),
    76 => (x"64",x"44",x"00",x"00"),
    77 => (x"44",x"4c",x"5c",x"74"),
    78 => (x"08",x"08",x"00",x"00"),
    79 => (x"41",x"41",x"77",x"3e"),
    80 => (x"00",x"00",x"00",x"00"),
    81 => (x"00",x"00",x"7f",x"7f"),
    82 => (x"41",x"41",x"00",x"00"),
    83 => (x"08",x"08",x"3e",x"77"),
    84 => (x"01",x"01",x"02",x"00"),
    85 => (x"01",x"02",x"02",x"03"),
    86 => (x"7f",x"7f",x"7f",x"00"),
    87 => (x"7f",x"7f",x"7f",x"7f"),
    88 => (x"1c",x"08",x"08",x"00"),
    89 => (x"7f",x"3e",x"3e",x"1c"),
    90 => (x"3e",x"7f",x"7f",x"7f"),
    91 => (x"08",x"1c",x"1c",x"3e"),
    92 => (x"18",x"10",x"00",x"08"),
    93 => (x"10",x"18",x"7c",x"7c"),
    94 => (x"30",x"10",x"00",x"00"),
    95 => (x"10",x"30",x"7c",x"7c"),
    96 => (x"60",x"30",x"10",x"00"),
    97 => (x"06",x"1e",x"78",x"60"),
    98 => (x"3c",x"66",x"42",x"00"),
    99 => (x"42",x"66",x"3c",x"18"),
   100 => (x"6a",x"38",x"78",x"00"),
   101 => (x"38",x"6c",x"c6",x"c2"),
   102 => (x"00",x"00",x"60",x"00"),
   103 => (x"60",x"00",x"00",x"60"),
   104 => (x"5b",x"5e",x"0e",x"00"),
   105 => (x"1e",x"0e",x"5d",x"5c"),
   106 => (x"cb",x"c3",x"4c",x"71"),
   107 => (x"c0",x"4d",x"bf",x"ce"),
   108 => (x"74",x"1e",x"c0",x"4b"),
   109 => (x"87",x"c7",x"02",x"ab"),
   110 => (x"c0",x"48",x"a6",x"c4"),
   111 => (x"c4",x"87",x"c5",x"78"),
   112 => (x"78",x"c1",x"48",x"a6"),
   113 => (x"73",x"1e",x"66",x"c4"),
   114 => (x"87",x"df",x"ee",x"49"),
   115 => (x"e0",x"c0",x"86",x"c8"),
   116 => (x"87",x"ef",x"ef",x"49"),
   117 => (x"6a",x"4a",x"a5",x"c4"),
   118 => (x"87",x"f0",x"f0",x"49"),
   119 => (x"cb",x"87",x"c6",x"f1"),
   120 => (x"c8",x"83",x"c1",x"85"),
   121 => (x"ff",x"04",x"ab",x"b7"),
   122 => (x"26",x"26",x"87",x"c7"),
   123 => (x"26",x"4c",x"26",x"4d"),
   124 => (x"1e",x"4f",x"26",x"4b"),
   125 => (x"cb",x"c3",x"4a",x"71"),
   126 => (x"cb",x"c3",x"5a",x"d2"),
   127 => (x"78",x"c7",x"48",x"d2"),
   128 => (x"87",x"dd",x"fe",x"49"),
   129 => (x"73",x"1e",x"4f",x"26"),
   130 => (x"c0",x"4a",x"71",x"1e"),
   131 => (x"d3",x"03",x"aa",x"b7"),
   132 => (x"cd",x"d5",x"c2",x"87"),
   133 => (x"87",x"c4",x"05",x"bf"),
   134 => (x"87",x"c2",x"4b",x"c1"),
   135 => (x"d5",x"c2",x"4b",x"c0"),
   136 => (x"87",x"c4",x"5b",x"d1"),
   137 => (x"5a",x"d1",x"d5",x"c2"),
   138 => (x"bf",x"cd",x"d5",x"c2"),
   139 => (x"c1",x"9a",x"c1",x"4a"),
   140 => (x"ec",x"49",x"a2",x"c0"),
   141 => (x"48",x"fc",x"87",x"e8"),
   142 => (x"bf",x"cd",x"d5",x"c2"),
   143 => (x"87",x"ef",x"fe",x"78"),
   144 => (x"cd",x"d5",x"c2",x"1e"),
   145 => (x"e7",x"c0",x"49",x"bf"),
   146 => (x"cb",x"c3",x"87",x"e4"),
   147 => (x"bf",x"e8",x"48",x"c6"),
   148 => (x"c2",x"cb",x"c3",x"78"),
   149 => (x"78",x"bf",x"ec",x"48"),
   150 => (x"bf",x"c6",x"cb",x"c3"),
   151 => (x"ff",x"c3",x"49",x"4a"),
   152 => (x"2a",x"b7",x"c8",x"99"),
   153 => (x"b0",x"71",x"48",x"72"),
   154 => (x"58",x"ce",x"cb",x"c3"),
   155 => (x"5e",x"0e",x"4f",x"26"),
   156 => (x"0e",x"5d",x"5c",x"5b"),
   157 => (x"c7",x"ff",x"4b",x"71"),
   158 => (x"c1",x"cb",x"c3",x"87"),
   159 => (x"73",x"50",x"c0",x"48"),
   160 => (x"87",x"d3",x"e5",x"49"),
   161 => (x"c2",x"4c",x"49",x"70"),
   162 => (x"49",x"ee",x"cb",x"9c"),
   163 => (x"70",x"87",x"c6",x"cb"),
   164 => (x"cb",x"c3",x"4d",x"49"),
   165 => (x"05",x"bf",x"97",x"c1"),
   166 => (x"d0",x"87",x"e2",x"c1"),
   167 => (x"cb",x"c3",x"49",x"66"),
   168 => (x"05",x"99",x"bf",x"ca"),
   169 => (x"66",x"d4",x"87",x"d6"),
   170 => (x"c2",x"cb",x"c3",x"49"),
   171 => (x"cb",x"05",x"99",x"bf"),
   172 => (x"e4",x"49",x"73",x"87"),
   173 => (x"98",x"70",x"87",x"e1"),
   174 => (x"87",x"c1",x"c1",x"02"),
   175 => (x"ff",x"fd",x"4c",x"c1"),
   176 => (x"ca",x"49",x"75",x"87"),
   177 => (x"98",x"70",x"87",x"db"),
   178 => (x"c3",x"87",x"c6",x"02"),
   179 => (x"c1",x"48",x"c1",x"cb"),
   180 => (x"c1",x"cb",x"c3",x"50"),
   181 => (x"c0",x"05",x"bf",x"97"),
   182 => (x"cb",x"c3",x"87",x"e3"),
   183 => (x"d0",x"49",x"bf",x"ca"),
   184 => (x"ff",x"05",x"99",x"66"),
   185 => (x"cb",x"c3",x"87",x"d6"),
   186 => (x"d4",x"49",x"bf",x"c2"),
   187 => (x"ff",x"05",x"99",x"66"),
   188 => (x"49",x"73",x"87",x"ca"),
   189 => (x"70",x"87",x"e0",x"e3"),
   190 => (x"ff",x"fe",x"05",x"98"),
   191 => (x"fb",x"48",x"74",x"87"),
   192 => (x"5e",x"0e",x"87",x"e9"),
   193 => (x"0e",x"5d",x"5c",x"5b"),
   194 => (x"4d",x"c0",x"86",x"f4"),
   195 => (x"7e",x"bf",x"ec",x"4c"),
   196 => (x"c3",x"48",x"a6",x"c4"),
   197 => (x"78",x"bf",x"ce",x"cb"),
   198 => (x"1e",x"c0",x"1e",x"c1"),
   199 => (x"cd",x"fd",x"49",x"c7"),
   200 => (x"70",x"86",x"c8",x"87"),
   201 => (x"87",x"cd",x"02",x"98"),
   202 => (x"d9",x"fb",x"49",x"ff"),
   203 => (x"49",x"da",x"c1",x"87"),
   204 => (x"c1",x"87",x"e4",x"e2"),
   205 => (x"c1",x"cb",x"c3",x"4d"),
   206 => (x"c3",x"02",x"bf",x"97"),
   207 => (x"87",x"c6",x"d5",x"87"),
   208 => (x"bf",x"c6",x"cb",x"c3"),
   209 => (x"cd",x"d5",x"c2",x"4b"),
   210 => (x"eb",x"c0",x"05",x"bf"),
   211 => (x"49",x"fd",x"c3",x"87"),
   212 => (x"c3",x"87",x"c4",x"e2"),
   213 => (x"fe",x"e1",x"49",x"fa"),
   214 => (x"c3",x"49",x"73",x"87"),
   215 => (x"1e",x"71",x"99",x"ff"),
   216 => (x"e4",x"c0",x"49",x"c0"),
   217 => (x"49",x"73",x"87",x"ec"),
   218 => (x"71",x"29",x"b7",x"c8"),
   219 => (x"c0",x"49",x"c1",x"1e"),
   220 => (x"c8",x"87",x"df",x"e4"),
   221 => (x"87",x"fb",x"c5",x"86"),
   222 => (x"bf",x"ca",x"cb",x"c3"),
   223 => (x"dd",x"02",x"9b",x"4b"),
   224 => (x"c9",x"d5",x"c2",x"87"),
   225 => (x"d8",x"c7",x"49",x"bf"),
   226 => (x"05",x"98",x"70",x"87"),
   227 => (x"4b",x"c0",x"87",x"c4"),
   228 => (x"e0",x"c2",x"87",x"d2"),
   229 => (x"87",x"fd",x"c6",x"49"),
   230 => (x"58",x"cd",x"d5",x"c2"),
   231 => (x"d5",x"c2",x"87",x"c6"),
   232 => (x"78",x"c0",x"48",x"c9"),
   233 => (x"99",x"c2",x"49",x"73"),
   234 => (x"c3",x"87",x"cd",x"05"),
   235 => (x"e6",x"e0",x"49",x"eb"),
   236 => (x"c2",x"49",x"70",x"87"),
   237 => (x"87",x"c2",x"02",x"99"),
   238 => (x"49",x"73",x"4c",x"fb"),
   239 => (x"cd",x"05",x"99",x"c1"),
   240 => (x"49",x"f4",x"c3",x"87"),
   241 => (x"70",x"87",x"d0",x"e0"),
   242 => (x"02",x"99",x"c2",x"49"),
   243 => (x"4c",x"fa",x"87",x"c2"),
   244 => (x"99",x"c8",x"49",x"73"),
   245 => (x"c3",x"87",x"ce",x"05"),
   246 => (x"df",x"ff",x"49",x"f5"),
   247 => (x"49",x"70",x"87",x"f9"),
   248 => (x"d4",x"02",x"99",x"c2"),
   249 => (x"d2",x"cb",x"c3",x"87"),
   250 => (x"87",x"c9",x"02",x"bf"),
   251 => (x"c3",x"88",x"c1",x"48"),
   252 => (x"c2",x"58",x"d6",x"cb"),
   253 => (x"c1",x"4c",x"ff",x"87"),
   254 => (x"c4",x"49",x"73",x"4d"),
   255 => (x"87",x"ce",x"05",x"99"),
   256 => (x"ff",x"49",x"f2",x"c3"),
   257 => (x"70",x"87",x"d0",x"df"),
   258 => (x"02",x"99",x"c2",x"49"),
   259 => (x"cb",x"c3",x"87",x"db"),
   260 => (x"48",x"7e",x"bf",x"d2"),
   261 => (x"03",x"a8",x"b7",x"c7"),
   262 => (x"48",x"6e",x"87",x"cb"),
   263 => (x"cb",x"c3",x"80",x"c1"),
   264 => (x"c2",x"c0",x"58",x"d6"),
   265 => (x"c1",x"4c",x"fe",x"87"),
   266 => (x"49",x"fd",x"c3",x"4d"),
   267 => (x"87",x"e7",x"de",x"ff"),
   268 => (x"99",x"c2",x"49",x"70"),
   269 => (x"c3",x"87",x"d5",x"02"),
   270 => (x"02",x"bf",x"d2",x"cb"),
   271 => (x"c3",x"87",x"c9",x"c0"),
   272 => (x"c0",x"48",x"d2",x"cb"),
   273 => (x"87",x"c2",x"c0",x"78"),
   274 => (x"4d",x"c1",x"4c",x"fd"),
   275 => (x"ff",x"49",x"fa",x"c3"),
   276 => (x"70",x"87",x"c4",x"de"),
   277 => (x"02",x"99",x"c2",x"49"),
   278 => (x"cb",x"c3",x"87",x"d9"),
   279 => (x"c7",x"48",x"bf",x"d2"),
   280 => (x"c0",x"03",x"a8",x"b7"),
   281 => (x"cb",x"c3",x"87",x"c9"),
   282 => (x"78",x"c7",x"48",x"d2"),
   283 => (x"fc",x"87",x"c2",x"c0"),
   284 => (x"c0",x"4d",x"c1",x"4c"),
   285 => (x"c0",x"03",x"ac",x"b7"),
   286 => (x"66",x"c4",x"87",x"d1"),
   287 => (x"82",x"d8",x"c1",x"4a"),
   288 => (x"c6",x"c0",x"02",x"6a"),
   289 => (x"74",x"4b",x"6a",x"87"),
   290 => (x"c0",x"0f",x"73",x"49"),
   291 => (x"1e",x"f0",x"c3",x"1e"),
   292 => (x"f7",x"49",x"da",x"c1"),
   293 => (x"86",x"c8",x"87",x"d8"),
   294 => (x"c0",x"02",x"98",x"70"),
   295 => (x"a6",x"c8",x"87",x"e2"),
   296 => (x"d2",x"cb",x"c3",x"48"),
   297 => (x"66",x"c8",x"78",x"bf"),
   298 => (x"c4",x"91",x"cb",x"49"),
   299 => (x"80",x"71",x"48",x"66"),
   300 => (x"bf",x"6e",x"7e",x"70"),
   301 => (x"87",x"c8",x"c0",x"02"),
   302 => (x"c8",x"4b",x"bf",x"6e"),
   303 => (x"0f",x"73",x"49",x"66"),
   304 => (x"c0",x"02",x"9d",x"75"),
   305 => (x"cb",x"c3",x"87",x"c8"),
   306 => (x"f3",x"49",x"bf",x"d2"),
   307 => (x"d5",x"c2",x"87",x"d3"),
   308 => (x"c0",x"02",x"bf",x"d1"),
   309 => (x"c2",x"49",x"87",x"dd"),
   310 => (x"98",x"70",x"87",x"c7"),
   311 => (x"87",x"d3",x"c0",x"02"),
   312 => (x"bf",x"d2",x"cb",x"c3"),
   313 => (x"87",x"f9",x"f2",x"49"),
   314 => (x"d9",x"f4",x"49",x"c0"),
   315 => (x"d1",x"d5",x"c2",x"87"),
   316 => (x"f4",x"78",x"c0",x"48"),
   317 => (x"87",x"f3",x"f3",x"8e"),
   318 => (x"5c",x"5b",x"5e",x"0e"),
   319 => (x"71",x"1e",x"0e",x"5d"),
   320 => (x"ce",x"cb",x"c3",x"4c"),
   321 => (x"cd",x"c1",x"49",x"bf"),
   322 => (x"d1",x"c1",x"4d",x"a1"),
   323 => (x"74",x"7e",x"69",x"81"),
   324 => (x"87",x"cf",x"02",x"9c"),
   325 => (x"74",x"4b",x"a5",x"c4"),
   326 => (x"ce",x"cb",x"c3",x"7b"),
   327 => (x"d2",x"f3",x"49",x"bf"),
   328 => (x"74",x"7b",x"6e",x"87"),
   329 => (x"87",x"c4",x"05",x"9c"),
   330 => (x"87",x"c2",x"4b",x"c0"),
   331 => (x"49",x"73",x"4b",x"c1"),
   332 => (x"d4",x"87",x"d3",x"f3"),
   333 => (x"87",x"c7",x"02",x"66"),
   334 => (x"70",x"87",x"da",x"49"),
   335 => (x"c0",x"87",x"c2",x"4a"),
   336 => (x"d5",x"d5",x"c2",x"4a"),
   337 => (x"e2",x"f2",x"26",x"5a"),
   338 => (x"00",x"00",x"00",x"87"),
   339 => (x"00",x"00",x"00",x"00"),
   340 => (x"00",x"00",x"00",x"00"),
   341 => (x"4a",x"71",x"1e",x"00"),
   342 => (x"49",x"bf",x"c8",x"ff"),
   343 => (x"26",x"48",x"a1",x"72"),
   344 => (x"c8",x"ff",x"1e",x"4f"),
   345 => (x"c0",x"fe",x"89",x"bf"),
   346 => (x"c0",x"c0",x"c0",x"c0"),
   347 => (x"87",x"c4",x"01",x"a9"),
   348 => (x"87",x"c2",x"4a",x"c0"),
   349 => (x"48",x"72",x"4a",x"c1"),
   350 => (x"5e",x"0e",x"4f",x"26"),
   351 => (x"0e",x"5d",x"5c",x"5b"),
   352 => (x"d4",x"ff",x"4b",x"71"),
   353 => (x"48",x"66",x"d0",x"4c"),
   354 => (x"49",x"d6",x"78",x"c0"),
   355 => (x"87",x"c7",x"db",x"ff"),
   356 => (x"6c",x"7c",x"ff",x"c3"),
   357 => (x"99",x"ff",x"c3",x"49"),
   358 => (x"c3",x"49",x"4d",x"71"),
   359 => (x"e0",x"c1",x"99",x"f0"),
   360 => (x"87",x"cb",x"05",x"a9"),
   361 => (x"6c",x"7c",x"ff",x"c3"),
   362 => (x"d0",x"98",x"c3",x"48"),
   363 => (x"c3",x"78",x"08",x"66"),
   364 => (x"4a",x"6c",x"7c",x"ff"),
   365 => (x"c3",x"31",x"c8",x"49"),
   366 => (x"4a",x"6c",x"7c",x"ff"),
   367 => (x"49",x"72",x"b2",x"71"),
   368 => (x"ff",x"c3",x"31",x"c8"),
   369 => (x"71",x"4a",x"6c",x"7c"),
   370 => (x"c8",x"49",x"72",x"b2"),
   371 => (x"7c",x"ff",x"c3",x"31"),
   372 => (x"b2",x"71",x"4a",x"6c"),
   373 => (x"c0",x"48",x"d0",x"ff"),
   374 => (x"9b",x"73",x"78",x"e0"),
   375 => (x"72",x"87",x"c2",x"02"),
   376 => (x"26",x"48",x"75",x"7b"),
   377 => (x"26",x"4c",x"26",x"4d"),
   378 => (x"1e",x"4f",x"26",x"4b"),
   379 => (x"5e",x"0e",x"4f",x"26"),
   380 => (x"f8",x"0e",x"5c",x"5b"),
   381 => (x"c8",x"1e",x"76",x"86"),
   382 => (x"fd",x"fd",x"49",x"a6"),
   383 => (x"70",x"86",x"c4",x"87"),
   384 => (x"c2",x"48",x"6e",x"4b"),
   385 => (x"ca",x"c3",x"03",x"a8"),
   386 => (x"c3",x"4a",x"73",x"87"),
   387 => (x"d0",x"c1",x"9a",x"f0"),
   388 => (x"87",x"c7",x"02",x"aa"),
   389 => (x"05",x"aa",x"e0",x"c1"),
   390 => (x"73",x"87",x"f8",x"c2"),
   391 => (x"02",x"99",x"c8",x"49"),
   392 => (x"c6",x"ff",x"87",x"c3"),
   393 => (x"c3",x"4c",x"73",x"87"),
   394 => (x"05",x"ac",x"c2",x"9c"),
   395 => (x"c4",x"87",x"cf",x"c1"),
   396 => (x"31",x"c9",x"49",x"66"),
   397 => (x"66",x"c4",x"1e",x"71"),
   398 => (x"92",x"d8",x"c2",x"4a"),
   399 => (x"49",x"d6",x"cb",x"c3"),
   400 => (x"d3",x"fe",x"81",x"72"),
   401 => (x"66",x"c4",x"87",x"c0"),
   402 => (x"e3",x"c0",x"1e",x"49"),
   403 => (x"eb",x"d8",x"ff",x"49"),
   404 => (x"ff",x"49",x"d8",x"87"),
   405 => (x"c8",x"87",x"c0",x"d8"),
   406 => (x"fa",x"c2",x"1e",x"c0"),
   407 => (x"eb",x"fd",x"49",x"c6"),
   408 => (x"d0",x"ff",x"87",x"de"),
   409 => (x"78",x"e0",x"c0",x"48"),
   410 => (x"1e",x"c6",x"fa",x"c2"),
   411 => (x"c2",x"4a",x"66",x"d0"),
   412 => (x"cb",x"c3",x"92",x"d8"),
   413 => (x"81",x"72",x"49",x"d6"),
   414 => (x"87",x"c8",x"ce",x"fe"),
   415 => (x"ac",x"c1",x"86",x"d0"),
   416 => (x"87",x"cf",x"c1",x"05"),
   417 => (x"c9",x"49",x"66",x"c4"),
   418 => (x"c4",x"1e",x"71",x"31"),
   419 => (x"d8",x"c2",x"4a",x"66"),
   420 => (x"d6",x"cb",x"c3",x"92"),
   421 => (x"fe",x"81",x"72",x"49"),
   422 => (x"c2",x"87",x"eb",x"d1"),
   423 => (x"c8",x"1e",x"c6",x"fa"),
   424 => (x"d8",x"c2",x"4a",x"66"),
   425 => (x"d6",x"cb",x"c3",x"92"),
   426 => (x"fe",x"81",x"72",x"49"),
   427 => (x"c8",x"87",x"d2",x"cc"),
   428 => (x"c0",x"1e",x"49",x"66"),
   429 => (x"d7",x"ff",x"49",x"e3"),
   430 => (x"49",x"d7",x"87",x"c2"),
   431 => (x"87",x"d7",x"d6",x"ff"),
   432 => (x"c2",x"1e",x"c0",x"c8"),
   433 => (x"fd",x"49",x"c6",x"fa"),
   434 => (x"d0",x"87",x"df",x"e9"),
   435 => (x"48",x"d0",x"ff",x"86"),
   436 => (x"f8",x"78",x"e0",x"c0"),
   437 => (x"87",x"cd",x"fc",x"8e"),
   438 => (x"5c",x"5b",x"5e",x"0e"),
   439 => (x"71",x"1e",x"0e",x"5d"),
   440 => (x"4c",x"d4",x"ff",x"4d"),
   441 => (x"48",x"7e",x"66",x"d4"),
   442 => (x"06",x"a8",x"b7",x"c3"),
   443 => (x"48",x"c0",x"87",x"c5"),
   444 => (x"75",x"87",x"e3",x"c1"),
   445 => (x"f4",x"e1",x"fe",x"49"),
   446 => (x"c4",x"1e",x"75",x"87"),
   447 => (x"d8",x"c2",x"4b",x"66"),
   448 => (x"d6",x"cb",x"c3",x"93"),
   449 => (x"fe",x"49",x"73",x"83"),
   450 => (x"c8",x"87",x"e9",x"c6"),
   451 => (x"ff",x"4b",x"6b",x"83"),
   452 => (x"e1",x"c8",x"48",x"d0"),
   453 => (x"73",x"7c",x"dd",x"78"),
   454 => (x"99",x"ff",x"c3",x"49"),
   455 => (x"49",x"73",x"7c",x"71"),
   456 => (x"c3",x"29",x"b7",x"c8"),
   457 => (x"7c",x"71",x"99",x"ff"),
   458 => (x"b7",x"d0",x"49",x"73"),
   459 => (x"99",x"ff",x"c3",x"29"),
   460 => (x"49",x"73",x"7c",x"71"),
   461 => (x"71",x"29",x"b7",x"d8"),
   462 => (x"7c",x"7c",x"c0",x"7c"),
   463 => (x"7c",x"7c",x"7c",x"7c"),
   464 => (x"7c",x"7c",x"7c",x"7c"),
   465 => (x"e0",x"c0",x"7c",x"7c"),
   466 => (x"1e",x"66",x"c4",x"78"),
   467 => (x"d4",x"ff",x"49",x"dc"),
   468 => (x"86",x"c8",x"87",x"ea"),
   469 => (x"fa",x"26",x"48",x"73"),
   470 => (x"5e",x"0e",x"87",x"c9"),
   471 => (x"0e",x"5d",x"5c",x"5b"),
   472 => (x"ff",x"7e",x"71",x"1e"),
   473 => (x"1e",x"6e",x"4b",x"d4"),
   474 => (x"49",x"c6",x"d0",x"c3"),
   475 => (x"87",x"c4",x"c5",x"fe"),
   476 => (x"4d",x"70",x"86",x"c4"),
   477 => (x"c3",x"c3",x"02",x"9d"),
   478 => (x"ce",x"d0",x"c3",x"87"),
   479 => (x"49",x"6e",x"4c",x"bf"),
   480 => (x"87",x"e9",x"df",x"fe"),
   481 => (x"c8",x"48",x"d0",x"ff"),
   482 => (x"d6",x"c1",x"78",x"c5"),
   483 => (x"15",x"4a",x"c0",x"7b"),
   484 => (x"c0",x"82",x"c1",x"7b"),
   485 => (x"04",x"aa",x"b7",x"e0"),
   486 => (x"d0",x"ff",x"87",x"f5"),
   487 => (x"c8",x"78",x"c4",x"48"),
   488 => (x"d3",x"c1",x"78",x"c5"),
   489 => (x"c4",x"7b",x"c1",x"7b"),
   490 => (x"02",x"9c",x"74",x"78"),
   491 => (x"c2",x"87",x"fc",x"c1"),
   492 => (x"c8",x"7e",x"c6",x"fa"),
   493 => (x"c0",x"8c",x"4d",x"c0"),
   494 => (x"c6",x"03",x"ac",x"b7"),
   495 => (x"a4",x"c0",x"c8",x"87"),
   496 => (x"c3",x"4c",x"c0",x"4d"),
   497 => (x"bf",x"97",x"f7",x"c6"),
   498 => (x"02",x"99",x"d0",x"49"),
   499 => (x"1e",x"c0",x"87",x"d2"),
   500 => (x"49",x"c6",x"d0",x"c3"),
   501 => (x"87",x"e9",x"c7",x"fe"),
   502 => (x"49",x"70",x"86",x"c4"),
   503 => (x"87",x"ef",x"c0",x"4a"),
   504 => (x"1e",x"c6",x"fa",x"c2"),
   505 => (x"49",x"c6",x"d0",x"c3"),
   506 => (x"87",x"d5",x"c7",x"fe"),
   507 => (x"49",x"70",x"86",x"c4"),
   508 => (x"48",x"d0",x"ff",x"4a"),
   509 => (x"c1",x"78",x"c5",x"c8"),
   510 => (x"97",x"6e",x"7b",x"d4"),
   511 => (x"48",x"6e",x"7b",x"bf"),
   512 => (x"7e",x"70",x"80",x"c1"),
   513 => (x"ff",x"05",x"8d",x"c1"),
   514 => (x"d0",x"ff",x"87",x"f0"),
   515 => (x"72",x"78",x"c4",x"48"),
   516 => (x"87",x"c5",x"05",x"9a"),
   517 => (x"e5",x"c0",x"48",x"c0"),
   518 => (x"c3",x"1e",x"c1",x"87"),
   519 => (x"fe",x"49",x"c6",x"d0"),
   520 => (x"c4",x"87",x"fd",x"c4"),
   521 => (x"05",x"9c",x"74",x"86"),
   522 => (x"ff",x"87",x"c4",x"fe"),
   523 => (x"c5",x"c8",x"48",x"d0"),
   524 => (x"7b",x"d3",x"c1",x"78"),
   525 => (x"78",x"c4",x"7b",x"c0"),
   526 => (x"87",x"c2",x"48",x"c1"),
   527 => (x"26",x"26",x"48",x"c0"),
   528 => (x"26",x"4c",x"26",x"4d"),
   529 => (x"0e",x"4f",x"26",x"4b"),
   530 => (x"0e",x"5c",x"5b",x"5e"),
   531 => (x"66",x"cc",x"4b",x"71"),
   532 => (x"4c",x"87",x"d8",x"02"),
   533 => (x"02",x"8c",x"f0",x"c0"),
   534 => (x"4a",x"74",x"87",x"d8"),
   535 => (x"d1",x"02",x"8a",x"c1"),
   536 => (x"cd",x"02",x"8a",x"87"),
   537 => (x"c9",x"02",x"8a",x"87"),
   538 => (x"73",x"87",x"d7",x"87"),
   539 => (x"87",x"ea",x"fb",x"49"),
   540 => (x"1e",x"74",x"87",x"d0"),
   541 => (x"df",x"f9",x"49",x"c0"),
   542 => (x"73",x"1e",x"74",x"87"),
   543 => (x"87",x"d8",x"f9",x"49"),
   544 => (x"fc",x"fe",x"86",x"c8"),
   545 => (x"c2",x"1e",x"00",x"87"),
   546 => (x"49",x"bf",x"ef",x"e2"),
   547 => (x"e2",x"c2",x"b9",x"c1"),
   548 => (x"d4",x"ff",x"59",x"f3"),
   549 => (x"78",x"ff",x"c3",x"48"),
   550 => (x"c8",x"48",x"d0",x"ff"),
   551 => (x"d4",x"ff",x"78",x"e1"),
   552 => (x"c4",x"78",x"c1",x"48"),
   553 => (x"ff",x"78",x"71",x"31"),
   554 => (x"e0",x"c0",x"48",x"d0"),
   555 => (x"00",x"4f",x"26",x"78"),
   556 => (x"1e",x"00",x"00",x"00"),
   557 => (x"87",x"ed",x"c3",x"ff"),
   558 => (x"c2",x"49",x"66",x"c4"),
   559 => (x"cd",x"02",x"99",x"c0"),
   560 => (x"1e",x"e0",x"c3",x"87"),
   561 => (x"49",x"e3",x"ca",x"c3"),
   562 => (x"87",x"fc",x"c4",x"ff"),
   563 => (x"66",x"c4",x"86",x"c4"),
   564 => (x"99",x"c0",x"c4",x"49"),
   565 => (x"c3",x"87",x"cd",x"02"),
   566 => (x"ca",x"c3",x"1e",x"f0"),
   567 => (x"c4",x"ff",x"49",x"e3"),
   568 => (x"86",x"c4",x"87",x"e6"),
   569 => (x"c1",x"49",x"66",x"c4"),
   570 => (x"1e",x"71",x"99",x"ff"),
   571 => (x"49",x"e3",x"ca",x"c3"),
   572 => (x"87",x"d4",x"c4",x"ff"),
   573 => (x"87",x"e5",x"c2",x"ff"),
   574 => (x"0e",x"4f",x"26",x"26"),
   575 => (x"5d",x"5c",x"5b",x"5e"),
   576 => (x"86",x"dc",x"ff",x"0e"),
   577 => (x"d2",x"c3",x"7e",x"c0"),
   578 => (x"c2",x"49",x"bf",x"e2"),
   579 => (x"72",x"1e",x"71",x"81"),
   580 => (x"fd",x"4a",x"c6",x"1e"),
   581 => (x"71",x"87",x"e2",x"df"),
   582 => (x"26",x"4a",x"26",x"48"),
   583 => (x"58",x"a6",x"c8",x"49"),
   584 => (x"bf",x"e2",x"d2",x"c3"),
   585 => (x"71",x"81",x"c4",x"49"),
   586 => (x"c6",x"1e",x"72",x"1e"),
   587 => (x"c8",x"df",x"fd",x"4a"),
   588 => (x"26",x"48",x"71",x"87"),
   589 => (x"cc",x"49",x"26",x"4a"),
   590 => (x"4c",x"c0",x"58",x"a6"),
   591 => (x"91",x"c4",x"49",x"74"),
   592 => (x"69",x"81",x"d0",x"fe"),
   593 => (x"c3",x"49",x"74",x"4a"),
   594 => (x"81",x"bf",x"e2",x"d2"),
   595 => (x"d2",x"c3",x"91",x"c4"),
   596 => (x"79",x"72",x"81",x"f2"),
   597 => (x"87",x"d1",x"02",x"9a"),
   598 => (x"89",x"c1",x"49",x"72"),
   599 => (x"48",x"6e",x"9a",x"71"),
   600 => (x"7e",x"70",x"80",x"c1"),
   601 => (x"ef",x"05",x"9a",x"72"),
   602 => (x"c2",x"84",x"c1",x"87"),
   603 => (x"ff",x"04",x"ac",x"b7"),
   604 => (x"48",x"6e",x"87",x"ca"),
   605 => (x"a8",x"b7",x"fc",x"c0"),
   606 => (x"87",x"ff",x"c8",x"04"),
   607 => (x"4a",x"74",x"4c",x"c0"),
   608 => (x"c4",x"82",x"66",x"c4"),
   609 => (x"f2",x"d2",x"c3",x"92"),
   610 => (x"c8",x"49",x"74",x"82"),
   611 => (x"91",x"c4",x"81",x"66"),
   612 => (x"81",x"f2",x"d2",x"c3"),
   613 => (x"49",x"69",x"4a",x"6a"),
   614 => (x"4b",x"74",x"b9",x"72"),
   615 => (x"bf",x"e2",x"d2",x"c3"),
   616 => (x"c3",x"93",x"c4",x"83"),
   617 => (x"6b",x"83",x"f2",x"d2"),
   618 => (x"71",x"48",x"72",x"ba"),
   619 => (x"58",x"a6",x"d0",x"98"),
   620 => (x"d2",x"c3",x"49",x"74"),
   621 => (x"c4",x"81",x"bf",x"e2"),
   622 => (x"f2",x"d2",x"c3",x"91"),
   623 => (x"d0",x"7e",x"69",x"81"),
   624 => (x"78",x"c0",x"48",x"a6"),
   625 => (x"df",x"49",x"66",x"cc"),
   626 => (x"c0",x"c7",x"02",x"29"),
   627 => (x"c0",x"4a",x"74",x"87"),
   628 => (x"66",x"d0",x"92",x"e0"),
   629 => (x"48",x"ff",x"c0",x"82"),
   630 => (x"4a",x"70",x"88",x"72"),
   631 => (x"c0",x"48",x"a6",x"d4"),
   632 => (x"c0",x"80",x"c4",x"78"),
   633 => (x"df",x"49",x"6e",x"78"),
   634 => (x"a6",x"e0",x"c0",x"29"),
   635 => (x"de",x"d2",x"c3",x"59"),
   636 => (x"72",x"78",x"c1",x"48"),
   637 => (x"b7",x"31",x"c3",x"49"),
   638 => (x"c0",x"b1",x"72",x"2a"),
   639 => (x"91",x"c4",x"99",x"ff"),
   640 => (x"4d",x"d9",x"f5",x"c2"),
   641 => (x"4b",x"6d",x"85",x"71"),
   642 => (x"c0",x"c0",x"c4",x"49"),
   643 => (x"f3",x"c0",x"02",x"99"),
   644 => (x"02",x"66",x"dc",x"87"),
   645 => (x"80",x"c8",x"87",x"c8"),
   646 => (x"c5",x"78",x"40",x"c0"),
   647 => (x"d2",x"c3",x"87",x"ef"),
   648 => (x"78",x"c1",x"48",x"e6"),
   649 => (x"bf",x"ea",x"d2",x"c3"),
   650 => (x"87",x"e1",x"c5",x"05"),
   651 => (x"f8",x"1e",x"d8",x"c1"),
   652 => (x"fe",x"f9",x"49",x"a0"),
   653 => (x"1e",x"d8",x"c5",x"87"),
   654 => (x"49",x"de",x"d2",x"c3"),
   655 => (x"c8",x"87",x"f4",x"f9"),
   656 => (x"87",x"c9",x"c5",x"86"),
   657 => (x"d8",x"02",x"66",x"dc"),
   658 => (x"c2",x"49",x"73",x"87"),
   659 => (x"02",x"99",x"c0",x"c0"),
   660 => (x"d0",x"87",x"c3",x"c0"),
   661 => (x"48",x"6d",x"2b",x"b7"),
   662 => (x"98",x"ff",x"ff",x"fd"),
   663 => (x"fa",x"c0",x"7d",x"70"),
   664 => (x"e6",x"d2",x"c3",x"87"),
   665 => (x"f2",x"c0",x"02",x"bf"),
   666 => (x"d0",x"48",x"73",x"87"),
   667 => (x"e4",x"c0",x"28",x"b7"),
   668 => (x"98",x"70",x"58",x"a6"),
   669 => (x"87",x"e3",x"c0",x"02"),
   670 => (x"bf",x"ee",x"d2",x"c3"),
   671 => (x"c0",x"e0",x"c0",x"49"),
   672 => (x"ca",x"c0",x"02",x"99"),
   673 => (x"c0",x"49",x"70",x"87"),
   674 => (x"02",x"99",x"c0",x"e0"),
   675 => (x"6d",x"87",x"cc",x"c0"),
   676 => (x"c0",x"c0",x"c2",x"48"),
   677 => (x"c0",x"7d",x"70",x"b0"),
   678 => (x"73",x"4b",x"66",x"e0"),
   679 => (x"c0",x"c0",x"c8",x"49"),
   680 => (x"c7",x"c2",x"02",x"99"),
   681 => (x"ee",x"d2",x"c3",x"87"),
   682 => (x"c0",x"cc",x"4a",x"bf"),
   683 => (x"cf",x"c0",x"02",x"9a"),
   684 => (x"8a",x"c0",x"c4",x"87"),
   685 => (x"87",x"d8",x"c0",x"02"),
   686 => (x"f9",x"c0",x"02",x"8a"),
   687 => (x"87",x"dd",x"c1",x"87"),
   688 => (x"ff",x"c3",x"49",x"73"),
   689 => (x"c2",x"91",x"c2",x"99"),
   690 => (x"11",x"81",x"cd",x"f5"),
   691 => (x"87",x"dc",x"c1",x"4b"),
   692 => (x"ff",x"c3",x"49",x"73"),
   693 => (x"c2",x"91",x"c2",x"99"),
   694 => (x"c1",x"81",x"cd",x"f5"),
   695 => (x"dc",x"4b",x"11",x"81"),
   696 => (x"c8",x"c0",x"02",x"66"),
   697 => (x"48",x"a6",x"d8",x"87"),
   698 => (x"ff",x"c0",x"78",x"d2"),
   699 => (x"48",x"a6",x"d4",x"87"),
   700 => (x"c0",x"78",x"d2",x"c4"),
   701 => (x"49",x"73",x"87",x"f6"),
   702 => (x"c2",x"99",x"ff",x"c3"),
   703 => (x"cd",x"f5",x"c2",x"91"),
   704 => (x"11",x"81",x"c1",x"81"),
   705 => (x"02",x"66",x"dc",x"4b"),
   706 => (x"d8",x"87",x"c9",x"c0"),
   707 => (x"d9",x"c1",x"48",x"a6"),
   708 => (x"87",x"d8",x"c0",x"78"),
   709 => (x"c5",x"48",x"a6",x"d4"),
   710 => (x"cf",x"c0",x"78",x"d9"),
   711 => (x"c3",x"49",x"73",x"87"),
   712 => (x"91",x"c2",x"99",x"ff"),
   713 => (x"81",x"cd",x"f5",x"c2"),
   714 => (x"4b",x"11",x"81",x"c1"),
   715 => (x"c0",x"02",x"66",x"dc"),
   716 => (x"49",x"73",x"87",x"dc"),
   717 => (x"fc",x"c7",x"b9",x"ff"),
   718 => (x"48",x"71",x"99",x"c0"),
   719 => (x"bf",x"ee",x"d2",x"c3"),
   720 => (x"f2",x"d2",x"c3",x"98"),
   721 => (x"9b",x"ff",x"c3",x"58"),
   722 => (x"c0",x"b3",x"c0",x"c4"),
   723 => (x"49",x"73",x"87",x"d4"),
   724 => (x"99",x"c0",x"fc",x"c7"),
   725 => (x"d2",x"c3",x"48",x"71"),
   726 => (x"c3",x"b0",x"bf",x"ee"),
   727 => (x"c3",x"58",x"f2",x"d2"),
   728 => (x"66",x"d4",x"9b",x"ff"),
   729 => (x"87",x"ca",x"c0",x"02"),
   730 => (x"de",x"d2",x"c3",x"1e"),
   731 => (x"87",x"c3",x"f5",x"49"),
   732 => (x"1e",x"73",x"86",x"c4"),
   733 => (x"49",x"de",x"d2",x"c3"),
   734 => (x"c4",x"87",x"f8",x"f4"),
   735 => (x"02",x"66",x"d8",x"86"),
   736 => (x"1e",x"87",x"ca",x"c0"),
   737 => (x"49",x"de",x"d2",x"c3"),
   738 => (x"c4",x"87",x"e8",x"f4"),
   739 => (x"48",x"66",x"cc",x"86"),
   740 => (x"a6",x"d0",x"30",x"c1"),
   741 => (x"c1",x"48",x"6e",x"58"),
   742 => (x"d0",x"7e",x"70",x"30"),
   743 => (x"80",x"c1",x"48",x"66"),
   744 => (x"c0",x"58",x"a6",x"d4"),
   745 => (x"04",x"a8",x"b7",x"e0"),
   746 => (x"c1",x"87",x"d9",x"f8"),
   747 => (x"ac",x"b7",x"c2",x"84"),
   748 => (x"87",x"ca",x"f7",x"04"),
   749 => (x"48",x"e2",x"d2",x"c3"),
   750 => (x"ff",x"78",x"66",x"c4"),
   751 => (x"4d",x"26",x"8e",x"dc"),
   752 => (x"4b",x"26",x"4c",x"26"),
   753 => (x"c0",x"1e",x"4f",x"26"),
   754 => (x"c4",x"49",x"72",x"4a"),
   755 => (x"f2",x"d2",x"c3",x"91"),
   756 => (x"c1",x"79",x"ff",x"81"),
   757 => (x"aa",x"b7",x"c6",x"82"),
   758 => (x"c3",x"87",x"ee",x"04"),
   759 => (x"c0",x"48",x"e2",x"d2"),
   760 => (x"80",x"c8",x"78",x"40"),
   761 => (x"4f",x"26",x"78",x"c0"),
   762 => (x"71",x"1e",x"73",x"1e"),
   763 => (x"c1",x"cb",x"c3",x"4b"),
   764 => (x"c0",x"02",x"bf",x"97"),
   765 => (x"49",x"73",x"87",x"e9"),
   766 => (x"e4",x"c1",x"91",x"cb"),
   767 => (x"81",x"ca",x"81",x"dc"),
   768 => (x"99",x"49",x"69",x"97"),
   769 => (x"c2",x"87",x"d8",x"05"),
   770 => (x"c7",x"1e",x"c1",x"1e"),
   771 => (x"fe",x"c3",x"ff",x"49"),
   772 => (x"c1",x"1e",x"c2",x"87"),
   773 => (x"ff",x"49",x"c7",x"1e"),
   774 => (x"d0",x"87",x"f4",x"c3"),
   775 => (x"73",x"87",x"cc",x"86"),
   776 => (x"c1",x"dc",x"fe",x"49"),
   777 => (x"fe",x"49",x"73",x"87"),
   778 => (x"fe",x"87",x"fb",x"db"),
   779 => (x"73",x"1e",x"87",x"d4"),
   780 => (x"f3",x"4b",x"71",x"1e"),
   781 => (x"49",x"73",x"87",x"c5"),
   782 => (x"87",x"fd",x"fa",x"fe"),
   783 => (x"0e",x"87",x"c3",x"fe"),
   784 => (x"5d",x"5c",x"5b",x"5e"),
   785 => (x"6b",x"4b",x"71",x"0e"),
   786 => (x"c0",x"c4",x"f8",x"4a"),
   787 => (x"c0",x"fc",x"c7",x"4d"),
   788 => (x"49",x"66",x"d0",x"4c"),
   789 => (x"cf",x"02",x"99",x"c2"),
   790 => (x"49",x"66",x"d4",x"87"),
   791 => (x"71",x"89",x"09",x"c0"),
   792 => (x"d4",x"34",x"c4",x"4c"),
   793 => (x"87",x"d7",x"8a",x"66"),
   794 => (x"c1",x"49",x"66",x"d0"),
   795 => (x"87",x"ca",x"02",x"99"),
   796 => (x"c4",x"4d",x"66",x"d4"),
   797 => (x"82",x"66",x"d4",x"35"),
   798 => (x"92",x"cf",x"87",x"c5"),
   799 => (x"75",x"2a",x"b7",x"c4"),
   800 => (x"c1",x"03",x"aa",x"b7"),
   801 => (x"b7",x"74",x"4a",x"87"),
   802 => (x"87",x"c1",x"06",x"aa"),
   803 => (x"fc",x"7b",x"72",x"4a"),
   804 => (x"5e",x"0e",x"87",x"ec"),
   805 => (x"71",x"0e",x"5c",x"5b"),
   806 => (x"4a",x"bf",x"ec",x"4c"),
   807 => (x"fc",x"fe",x"49",x"c5"),
   808 => (x"98",x"70",x"87",x"f5"),
   809 => (x"c2",x"87",x"c7",x"02"),
   810 => (x"df",x"48",x"d9",x"f9"),
   811 => (x"49",x"c6",x"78",x"f0"),
   812 => (x"87",x"e3",x"fc",x"fe"),
   813 => (x"c7",x"02",x"98",x"70"),
   814 => (x"d9",x"f9",x"c2",x"87"),
   815 => (x"78",x"c0",x"cc",x"48"),
   816 => (x"fc",x"fe",x"49",x"c4"),
   817 => (x"98",x"70",x"87",x"d1"),
   818 => (x"c2",x"87",x"c7",x"02"),
   819 => (x"c4",x"48",x"d9",x"f9"),
   820 => (x"49",x"cc",x"78",x"c0"),
   821 => (x"87",x"ff",x"fb",x"fe"),
   822 => (x"c7",x"02",x"98",x"70"),
   823 => (x"d9",x"f9",x"c2",x"87"),
   824 => (x"78",x"c0",x"c1",x"48"),
   825 => (x"74",x"1e",x"66",x"cc"),
   826 => (x"e4",x"fe",x"fe",x"49"),
   827 => (x"d9",x"f9",x"c2",x"87"),
   828 => (x"66",x"d4",x"1e",x"bf"),
   829 => (x"c2",x"4b",x"74",x"1e"),
   830 => (x"c8",x"4a",x"74",x"93"),
   831 => (x"e2",x"d3",x"c3",x"92"),
   832 => (x"fc",x"81",x"72",x"49"),
   833 => (x"f9",x"c2",x"87",x"f9"),
   834 => (x"dc",x"1e",x"bf",x"d9"),
   835 => (x"b7",x"c2",x"49",x"66"),
   836 => (x"73",x"1e",x"71",x"29"),
   837 => (x"c3",x"92",x"c4",x"4a"),
   838 => (x"72",x"49",x"e6",x"d3"),
   839 => (x"87",x"df",x"fc",x"81"),
   840 => (x"1e",x"e2",x"d3",x"c3"),
   841 => (x"fe",x"fe",x"49",x"74"),
   842 => (x"8e",x"e8",x"87",x"c8"),
   843 => (x"1e",x"87",x"d1",x"fa"),
   844 => (x"c2",x"87",x"d3",x"fa"),
   845 => (x"c7",x"1e",x"c1",x"1e"),
   846 => (x"d2",x"ff",x"fe",x"49"),
   847 => (x"c1",x"1e",x"c2",x"87"),
   848 => (x"fe",x"49",x"c7",x"1e"),
   849 => (x"c0",x"87",x"c8",x"ff"),
   850 => (x"26",x"8e",x"f0",x"48"),
   851 => (x"f2",x"eb",x"f4",x"4f"),
   852 => (x"04",x"06",x"05",x"f5"),
   853 => (x"83",x"0b",x"03",x"0c"),
   854 => (x"fc",x"00",x"66",x"0a"),
   855 => (x"da",x"00",x"5a",x"00"),
   856 => (x"94",x"80",x"00",x"00"),
   857 => (x"78",x"80",x"05",x"08"),
   858 => (x"01",x"80",x"02",x"00"),
   859 => (x"09",x"80",x"03",x"00"),
   860 => (x"00",x"80",x"04",x"00"),
   861 => (x"91",x"80",x"01",x"00"),
   862 => (x"04",x"00",x"26",x"08"),
   863 => (x"00",x"00",x"1d",x"00"),
   864 => (x"00",x"00",x"1c",x"00"),
   865 => (x"0c",x"00",x"25",x"00"),
   866 => (x"00",x"00",x"1a",x"00"),
   867 => (x"00",x"00",x"1b",x"00"),
   868 => (x"00",x"00",x"24",x"00"),
   869 => (x"00",x"01",x"12",x"00"),
   870 => (x"03",x"00",x"2e",x"00"),
   871 => (x"00",x"00",x"2d",x"00"),
   872 => (x"00",x"00",x"23",x"00"),
   873 => (x"0b",x"00",x"36",x"00"),
   874 => (x"00",x"00",x"21",x"00"),
   875 => (x"00",x"00",x"2b",x"00"),
   876 => (x"00",x"00",x"2c",x"00"),
   877 => (x"00",x"00",x"22",x"00"),
   878 => (x"6c",x"00",x"3d",x"00"),
   879 => (x"00",x"00",x"35",x"00"),
   880 => (x"00",x"00",x"34",x"00"),
   881 => (x"75",x"00",x"3e",x"00"),
   882 => (x"00",x"00",x"32",x"00"),
   883 => (x"00",x"00",x"33",x"00"),
   884 => (x"6b",x"00",x"3c",x"00"),
   885 => (x"00",x"00",x"2a",x"00"),
   886 => (x"01",x"00",x"46",x"00"),
   887 => (x"73",x"00",x"43",x"00"),
   888 => (x"69",x"00",x"3b",x"00"),
   889 => (x"09",x"00",x"45",x"00"),
   890 => (x"70",x"00",x"3a",x"00"),
   891 => (x"72",x"00",x"42",x"00"),
   892 => (x"74",x"00",x"44",x"00"),
   893 => (x"00",x"00",x"31",x"00"),
   894 => (x"00",x"00",x"55",x"00"),
   895 => (x"7c",x"00",x"4d",x"00"),
   896 => (x"7a",x"00",x"4b",x"00"),
   897 => (x"00",x"00",x"7b",x"00"),
   898 => (x"71",x"00",x"49",x"00"),
   899 => (x"84",x"00",x"4c",x"00"),
   900 => (x"77",x"00",x"54",x"00"),
   901 => (x"00",x"00",x"41",x"00"),
   902 => (x"00",x"00",x"61",x"00"),
   903 => (x"7c",x"00",x"5b",x"00"),
   904 => (x"00",x"00",x"52",x"00"),
   905 => (x"00",x"00",x"f1",x"00"),
   906 => (x"00",x"02",x"59",x"00"),
   907 => (x"5d",x"00",x"0e",x"00"),
   908 => (x"00",x"00",x"5d",x"00"),
   909 => (x"79",x"00",x"4a",x"00"),
   910 => (x"05",x"00",x"16",x"00"),
   911 => (x"07",x"00",x"76",x"00"),
   912 => (x"0d",x"00",x"0d",x"00"),
   913 => (x"06",x"00",x"1e",x"00"),
   914 => (x"00",x"00",x"29",x"00"),
   915 => (x"00",x"00",x"91",x"00"),
   916 => (x"00",x"00",x"15",x"00"),
   917 => (x"00",x"40",x"00",x"00"),
   918 => (x"00",x"00",x"80",x"00"),
   919 => (x"00",x"00",x"80",x"00"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;
