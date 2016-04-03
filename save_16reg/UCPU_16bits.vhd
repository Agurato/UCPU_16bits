LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY UCPU_16bits IS
PORT (
	
	SW : in STD_LOGIC_VECTOR(17 downto 0);
	LEDR : out STD_LOGIC_VECTOR(17 downto 0);
	LEDG: out STD_LOGIC_VECTOR(8 downto 0);
	HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0: out STD_LOGIC_VECTOR(0 to 6);
	KEY: in STD_LOGIC_VECTOR(7 downto 0);
	CLOCK_50: IN STD_LOGIC
);
END ENTITY UCPU_16bits;

ARCHITECTURE Behavior of UCPU_16bits IS

COMPONENT HEXA_DISPLAY IS
	PORT (
		input : in STD_LOGIC_VECTOR(3 downto 0);
		display : out STD_LOGIC_VECTOR(0 to 6)
	);
END COMPONENT;

COMPONENT CPU IS
	GENERIC(NBITS : positive := 16);
	PORT (
		clock, Run, nReset: IN std_logic;
		Din: IN std_logic_vector(NBITS-1 downto 0);
		
		Done, idle, writing0, writing1: OUT std_logic;
		Result : OUT std_logic_vector(NBITS-1 downto 0);
		in0 : OUT std_logic_vector(NBITS-1 downto 0);
		in1 : OUT std_logic_vector(NBITS-1 downto 0);
		countClock : OUT std_logic_vector(7 downto 0);
		CODOPout : OUT std_logic_vector(3 downto 0);
		
		overflow : OUT std_logic
	);
END COMPONENT;

COMPONENT debouncer is
	port(s_i, clk: IN std_logic;
			s_o: OUT std_logic);
END COMPONENT debouncer;

Signal output, in0, in1 : STD_LOGIC_VECTOR(15 downto 0);
Signal overAdd, overMult : STD_LOGIC;
Signal clockSignal: STD_LOGIC;
Signal idleState : STD_LOGIC;
Signal countClock : STD_LOGIC_VECTOR(7 downto 0);
Signal instruction : STD_LOGIC_VECTOR(3 downto 0);

BEGIN

	-- utiliser le truc du controle

	LEDR(17) <= SW(17);
	LEDR(16) <= '0';
	LEDR(15 downto 0) <= SW(15 downto 0);
	
	beloved_cpu : CPU GENERIC MAP(16) PORT MAP(clock => clockSignal, Run => SW(17), nReset => KEY(0),
														Din => SW(15 downto 0),
														Result => output, in0 => in0, in1 => in1, Done => LEDG(7), idle => idleState,
														countClock => countClock, CODOPout => instruction,
														writing0 => LEDG(5), writing1 => LEDG(4), overflow => LEDG(8));
														
	hexa5 : HEXA_DISPLAY PORT MAP (input => output(7 downto 4), display => HEX5);
	hexa4 : HEXA_DISPLAY PORT MAP (input => output(3 downto 0), display => HEX4);
	
	hexa3 : HEXA_DISPLAY PORT MAP (input => in0(7 downto 4), display => HEX3);
	hexa2 : HEXA_DISPLAY PORT MAP (input => in0(3 downto 0), display => HEX2);
	
	hexa1 : HEXA_DISPLAY PORT MAP (input => in1(7 downto 4), display => HEX1);
	hexa0 : HEXA_DISPLAY PORT MAP (input => in1(3 downto 0), display => HEX0);
	
	count1 : HEXA_DISPLAY PORT MAP (input => instruction, display => HEX6);
	count2 : HEXA_DISPLAY PORT MAP (input => countClock(3 downto 0), display => HEX7);
	
	LEDG(0) <= NOT(key(0));
	LEDG(6) <= clockSignal;
	clockDeboncer: debouncer PORT MAP(s_i => NOT(KEY(3)), s_o => clockSignal, clk => CLOCK_50);
	
	LEDG(3 downto 1) <= instruction(2 downto 0);

END ARCHITECTURE Behavior;