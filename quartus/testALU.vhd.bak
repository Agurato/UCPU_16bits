LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY UCPU_16bits IS
PORT (
	
	SW : in STD_LOGIC_VECTOR(17 downto 0);
	LEDR : out STD_LOGIC_VECTOR(17 downto 0);
	LEDG: out STD_LOGIC_VECTOR(7 downto 0);
	HEX7, HEX6, HEX5, HEX4, HEX1, HEX0: out STD_LOGIC_VECTOR(0 to 6)
);
END UCPU_16bits;

ARCHITECTURE Behavior of UCPU_16bits IS

COMPONENT HEXA_DISPLAY_NEG IS
PORT (
	input : in STD_LOGIC_VECTOR(3 downto 0);
	s_number : out STD_LOGIC_VECTOR(0 to 6);
	s_sign : out STD_LOGIC_VECTOR(0 to 6)
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

Signal output : STD_LOGIC_VECTOR(3 downto 0);
Signal overAdd, overMult : STD_LOGIC;

BEGIN

	-- TODO : Overflow du mutliplicateur à corriger
	-- utiliser le truc du controle

	LEDR(17 downto 14) <= SW(17 downto 14);
	LEDR(11 downto 8) <= SW(11 downto 8);
	LEDR(5 downto 3) <= SW(5 downto 3);

	alu : ALU_8_N GENERIC MAP (4) PORT MAP (a => SW(17 downto 14), b => SW(11 downto 8), sel => SW(5 downto 3),
		s => output, overAdd => overAdd, overMult => overMult);
		
	hexa : HEXA_DISPLAY_NEG PORT MAP (input => SW(17 downto 14), s_sign => HEX7, s_number => HEX6);
	hexb : HEXA_DISPLAY_NEG PORT MAP (input => SW(11 downto 8), s_sign => HEX5, s_number => HEX4);
	hexs : HEXA_DISPLAY_NEG PORT MAP (input => output, s_sign => HEX1, s_number => HEX0);
	
	LEDG(3 downto 0) <= output;
	
	LEDR(1) <= overAdd;
	LEDR(0) <= overMult;

END ARCHITECTURE Behavior;