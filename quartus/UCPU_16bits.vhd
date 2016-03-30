LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY UCPU_16bits IS
PORT (
	
	SW : in STD_LOGIC_VECTOR(17 downto 0);
	LEDR : out STD_LOGIC_VECTOR(17 downto 0);
	LEDG: out STD_LOGIC_VECTOR(7 downto 0);
	HEX7, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0: out STD_LOGIC_VECTOR(0 to 6);
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
	Done, idle : OUT std_logic;
	Result : OUT std_logic_vector(NBITS-1 downto 0);
	countClock : OUT std_logic_vector(7 downto 0);
	CODOPout : OUT std_logic_vector(3 downto 0)
);
END COMPONENT;

COMPONENT debouncer is
	port(s_i, clk: IN std_logic;
			s_o: OUT std_logic);
END COMPONENT debouncer;

Signal output : STD_LOGIC_VECTOR(15 downto 0);
Signal overAdd, overMult : STD_LOGIC;
Signal clockSignal: STD_LOGIC;
Signal idleState : STD_LOGIC;
Signal countClock : STD_LOGIC_VECTOR(7 downto 0);
Signal instruction : STD_LOGIC_VECTOR(3 downto 0);

BEGIN

	-- TODO : Overflow du mutliplicateur à corriger
	-- utiliser le truc du controle

	LEDR(17) <= SW(17);
	--LEDR(16) <= SW(16);
	LEDR(15 downto 0) <= SW(15 downto 0);
	
	beloved_cpu : CPU GENERIC MAP(16) PORT MAP(clock => clockSignal, Run => SW(17), nReset => KEY(0),
														Din => SW(15 downto 0),
														Result => output, Done => LEDG(7), idle => idleState,
														countClock => countClock, CODOPout => instruction);
		
	hexa3 : HEXA_DISPLAY PORT MAP (input => output(15 downto 12), display => HEX3);
	hexa2 : HEXA_DISPLAY PORT MAP (input => output(11 downto 8), display => HEX2);
	hexa1 : HEXA_DISPLAY PORT MAP (input => output(7 downto 4), display => HEX1);
	hexa0 : HEXA_DISPLAY PORT MAP (input => output(3 downto 0), display => HEX0);
	
	count1 : HEXA_DISPLAY PORT MAP (input => instruction, display => HEX5);
	count2 : HEXA_DISPLAY PORT MAP (input => countClock(3 downto 0), display => HEX4);
	
	process(idleState)
	begin
		if idleState = '1' then
			HEX7 <= "1001111";
		else
			HEX7 <= "0011000";
		end if;
	end process;
	
	LEDG(0) <= NOT(key(0));
	LEDG(6) <= clockSignal;
	clockDeboncer: debouncer PORT MAP(s_i => NOT(KEY(3)), s_o => clockSignal, clk => CLOCK_50);

END ARCHITECTURE Behavior;