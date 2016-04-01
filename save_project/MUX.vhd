-- MULTIPLEXEUR 2 ENTRÉES À 1 BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY MUX_2_1 IS
PORT (
	x, y, s : in STD_LOGIC;
	m : out STD_LOGIC
);
END MUX_2_1;

ARCHITECTURE Behavior OF MUX_2_1 IS
BEGIN
	m <= (NOT (s) AND x) OR (s AND y);
END Behavior;

-- MULTIPLEXEUR 2 ENTRÉES À 8 BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY MUX_2_8 IS
PORT (
	s : in STD_LOGIC;
	x, y : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	m : out STD_LOGIC_VECTOR(7 DOWNTO 0)
);
END MUX_2_8;

ARCHITECTURE Behavior OF MUX_2_8 IS
	COMPONENT MUX_2_1 IS
	PORT (
		x, y, s : in STD_LOGIC;
		m : out STD_LOGIC
	);
	END COMPONENT MUX_2_1;
	
	BEGIN		
		mux0 : MUX_2_1 PORT MAP (x => x(0), y => y(0), s => s, m => m(0));
		mux1 : MUX_2_1 PORT MAP (x => x(1), y => y(1), s => s, m => m(1));
		mux2 : MUX_2_1 PORT MAP (x => x(2), y => y(2), s => s, m => m(2));
		mux3 : MUX_2_1 PORT MAP (x => x(3), y => y(3), s => s, m => m(3));
		mux4 : MUX_2_1 PORT MAP (x => x(4), y => y(4), s => s, m => m(4));
		mux5 : MUX_2_1 PORT MAP (x => x(5), y => y(5), s => s, m => m(5));
		mux6 : MUX_2_1 PORT MAP (x => x(6), y => y(6), s => s, m => m(6));
		mux7 : MUX_2_1 PORT MAP (x => x(7), y => y(7), s => s, m => m(7));

END Behavior;

-- MULTIPLEXEUR 2 ENTRÉES À N BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY MUX_2_N IS
GENERIC( NB_BITS : positive := 8);
PORT (
	a, b : in STD_LOGIC_VECTOR(NB_BITS-1 downto 0) := (others => '0');
	sel : in STD_LOGIC;
	s : out STD_LOGIC_VECTOR(NB_BITS-1 downto 0)
);
END ENTITY MUX_2_N;

ARCHITECTURE Behavior of MUX_2_N IS
BEGIN
	with sel select
	s <=	a when '0',
			b when '1';
END Behavior;

-- MULTIPLEXEUR 5 ENTRÉES À 1 BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY MUX_5_1 IS
PORT (
	s : in STD_LOGIC_VECTOR(2 downto 0);
	u, v, w, x, y : in STD_LOGIC;
	m : out STD_LOGIC
);
END MUX_5_1;

ARCHITECTURE Behavior OF MUX_5_1 IS
	COMPONENT MUX_2_1 IS
	PORT (
		x, y, s : in STD_LOGIC;
		m : out STD_LOGIC
	);
	END COMPONENT MUX_2_1;
	Signal cout_mux0 : std_logic;
	Signal cout_mux1 : std_logic;
	Signal cout_mux2 : std_logic;
	
	BEGIN		
		mux0 : MUX_2_1 PORT MAP (x => u, y => v, s => s(0), m => cout_mux0);
		mux1 : MUX_2_1 PORT MAP (x => w, y => x, s => s(0), m => cout_mux1);
		mux2 : MUX_2_1 PORT MAP (x => cout_mux0, y => cout_mux1, s => s(1), m => cout_mux2);
		mux3 : MUX_2_1 PORT MAP (x => cout_mux2, y => y, s => s(2), m => m);

END Behavior;

-- MULTIPLEXEUR 5 ENTRÉES À 3 BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY MUX_5_3 IS
PORT (
	s : in STD_LOGIC_VECTOR(2 downto 0);
	u, v, w, x, y : in STD_LOGIC_VECTOR(2 downto 0);
	m : out STD_LOGIC_VECTOR(2 downto 0)
);
END MUX_5_3;

ARCHITECTURE Behavior OF MUX_5_3 IS
	COMPONENT MUX_5_1 IS
	PORT (
		s : in STD_LOGIC_VECTOR(2 downto 0);
		u, v, w, x, y : in STD_LOGIC;
		m : out STD_LOGIC
	);
	END COMPONENT MUX_5_1;
	
	BEGIN		
		mux0 : MUX_5_1 PORT MAP (u => u(0), v => v(0), w => w(0), x => x(0), y => y(0), s => s, m => m(0));
		mux1 : MUX_5_1 PORT MAP (u => u(1), v => v(1), w => w(1), x => x(1), y => y(1), s => s, m => m(1));
		mux2 : MUX_5_1 PORT MAP (u => u(2), v => v(2), w => w(2), x => x(2), y => y(2), s => s, m => m(2));

END Behavior;

-- MULTIPLEXEUR 8 ENTRÉES À N BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY MUX_8_N IS
GENERIC( SIZE_MUX_8 : positive := 8);
PORT (
	a, b, c, d, e, f, g, h : in STD_LOGIC_VECTOR(SIZE_MUX_8-1 downto 0) := (others => '0');
	sel : in STD_LOGIC_VECTOR(2 downto 0);
	s : out STD_LOGIC_VECTOR(SIZE_MUX_8-1 downto 0)
);
END ENTITY;

ARCHITECTURE Behavior of MUX_8_N IS
BEGIN
	with sel select
	s <=	a when "000",
			b when "001",
			c when "010",
			d when "011",
			e when "100",
			f when "101",
			g when "110",
			h when "111";
END Behavior;

-- MULTIPLEXEUR 16 ENTRÉES À N BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY MUX_16_N IS
	GENERIC( NB_BITS : positive := 8);
	PORT (
		a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p : in STD_LOGIC_VECTOR(NB_BITS-1 downto 0) := (others => '0');
		sel : in STD_LOGIC_VECTOR(3 downto 0);
		s : out STD_LOGIC_VECTOR(NB_BITS-1 downto 0)
	);
END ENTITY MUX_16_N;

ARCHITECTURE Behavior of MUX_16_N IS
BEGIN
	with sel select
	s <=	a when "0000",
			b when "0001",
			c when "0010",
			d when "0011",
			e when "0100",
			f when "0101",
			g when "0110",
			h when "0111",
			i when "1000",
			j when "1001",
			k when "1010",
			l when "1011",
			m when "1100",
			n when "1101",
			o when "1110",
			p when "1111";
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ONE_HOT_8 IS
	PORT (
		sel : in STD_LOGIC_VECTOR(2 downto 0);
		s : out STD_LOGIC_VECTOR(7 downto 0)
	);
END ENTITY ONE_HOT_8;

ARCHITECTURE Behavior of ONE_HOT_8 IS
BEGIN
	with sel select
	s <=	"00000001" when "000",
			"00000010" when "001",
			"00000100" when "010",
			"00001000" when "011",
			"00010000" when "100",
			"00100000" when "101",
			"01000000" when "110",
			"10000000" when "111";
END Behavior;