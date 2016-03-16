LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY UCPU_16bits IS
PORT (
	
	SW : in STD_LOGIC_VECTOR(17 downto 0);
	LEDR : out STD_LOGIC_VECTOR(17 downto 0);
	LEDG: out STD_LOGIC_VECTOR(7 downto 0);
	HEX4, HEX3, HEX2, HEX1, HEX0: out STD_LOGIC_VECTOR(0 to 6);
	KEY: in STD_LOGIC_VECTOR(7 downto 0);
	CLOCK_50: IN STD_LOGIC
);
END UCPU_16bits;

ARCHITECTURE Behavior of UCPU_16bits IS

COMPONENT HEXA_DISPLAY IS
PORT (
	input : in STD_LOGIC_VECTOR(3 downto 0);
	display : out STD_LOGIC_VECTOR(0 to 6)
);
END COMPONENT;

COMPONENT ALU_8_N IS

	GENERIC (N_BITS : positive := 8);
	PORT (
		a, b : in STD_LOGIC_VECTOR(N_BITS-1 downto 0);
		sel : in STD_LOGIC_VECTOR(2 downto 0);
		
		s : out STD_LOGIC_VECTOR(N_BITS-1 downto 0);
		overAdd, overMult : out STD_LOGIC
	);
END COMPONENT;

COMPONENT CPU IS
GENERIC(NBITS : positive := 16);
PORT (
	clock, Run, nReset: IN std_logic;
	Din: IN std_logic_vector(NBITS-1 downto 0);
	Done : OUT std_logic;
	Result : OUT std_logic_vector(NBITS-1 downto 0)
);
END COMPONENT;

COMPONENT debouncer is
	port(s_i, clk: IN std_logic;
			s_o: OUT std_logic);
END COMPONENT debouncer;

Signal output : STD_LOGIC_VECTOR(15 downto 0);
Signal overAdd, overMult : STD_LOGIC;
Signal clockSignal: STD_LOGIC;

BEGIN

	-- TODO : Overflow du mutliplicateur à corriger
	-- utiliser le truc du controle

	LEDR(17) <= SW(17);
	LEDR(15 downto 0) <= SW(15 downto 0);

	--alu : ALU_8_N GENERIC MAP (4) PORT MAP (a => SW(17 downto 14), b => SW(11 downto 8), sel => SW(5 downto 3),
	--	s => output, overAdd => overAdd, overMult => overMult);
	
	beloved_cpu : CPU GENERIC MAP(16) PORT MAP(clock => clockSignal, Run => SW(17), nReset => KEY(0),
														Din => SW(15 downto 0),
														Result => output, Done => LEDG(7));
		
	--hexa : HEXA_DISPLAY_NEG PORT MAP (input => SW(17 downto 14), s_sign => HEX7, s_number => HEX6);
	--hexb : HEXA_DISPLAY_NEG PORT MAP (input => SW(11 downto 8), s_sign => HEX5, s_number => HEX4);
	hexa3 : HEXA_DISPLAY PORT MAP (input => output(15 downto 12), display => HEX3);
	hexa2 : HEXA_DISPLAY PORT MAP (input => output(11 downto 8), display => HEX2);
	hexa1 : HEXA_DISPLAY PORT MAP (input => output(7 downto 4), display => HEX1);
	hexa0 : HEXA_DISPLAY PORT MAP (input => output(3 downto 0), display => HEX0);
	
	LEDG(0) <= key(0);
	clockDeboncer: debouncer PORT MAP(s_i => KEY(0), s_o => clockSignal, clk => CLOCK_50);
	
	--LEDR(1) <= overAdd;
	--LEDR(0) <= overMult;

END ARCHITECTURE Behavior;