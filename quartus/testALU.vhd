-- DIVISEUR N BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY DIV_N IS
	GENERIC (SIZE_DIV : positive := 8);
	PORT (
		a, b : in STD_LOGIC_VECTOR(SIZE_MULT-1 downto 0);
		s : out STD_LOGIC_VECTOR(2*SIZE_MULT-1 downto 0)
	);
END DIV_N;

ARCHITECTURE Behavior of DIV_N IS

	COMPONENT FULL_ADDER_N IS
		GENERIC( SIZE_FA : positive := 8);
		PORT (
			a, b : in STD_LOGIC_VECTOR(SIZE_FA-1 downto 0);
			c_in : in STD_LOGIC;
			s : out STD_LOGIC_VECTOR(SIZE_FA-1 downto 0);
			c_out : out STD_LOGIC
		);
	END COMPONENT;

	COMPONENT FULL_ADDER_1 IS
		PORT (
			a, b, c_in : in STD_LOGIC;
			s, c_out : out STD_LOGIC
		);
	END COMPONENT;

	TYPE mem_S IS ARRAY(0 to SIZE_DIV-1) OF STD_LOGIC_VECTOR(SIZE_DIV downto 0);
	TYPE mem_ET IS ARRAY(0 to SIZE_DIV-1) OF STD_LOGIC_VECTOR(SIZE_DIV-1 downto 0);
	TYPE mem_C IS ARRAY(0 to SIZE_DIV-1) OF STD_LOGIC_VECTOR(SIZE_DIV downto 0);
	
	Signal memSortie : mem_S;
	Signal memEt : mem_ET;
	Signal memCarry : mem_C;
	
	BEGIN
	
		memSortie(0)(SIZE_DIV) <= '0';
		ligne: for i in 0 to SIZE_DIV-1 generate
			memCarry(i)(0) <= '0';
			
			colonne: for j in 0 to SIZE_DIV-1 generate
				memEt(i)(j) <= a(j) AND b(i);
				
				prem_1: if i=0 generate
					memSortie(0)(j) <= memEt(0)(j);
				end generate prem_1;
				
				prem_2: if i>0 generate
					add_n: FULL_ADDER_1 PORT MAP (a => memSortie(i-1)(j+1), b => memEt(i)(j), s => memSortie(i)(j), c_in => memCarry(i)(j), c_out => memCarry(i)(j+1));
				end generate prem_2;
				
			end generate colonne;
			s(i) <= memSortie(i)(0);
		end generate ligne;
		
		s(2*SIZE_DIV-1 downto SIZE_DIV-1) <= memSortie(SIZE_DIV-1)(SIZE_DIV downto 0);
 	
END ARCHITECTURE;


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY testALU IS
PORT (
	
	SW : in STD_LOGIC_VECTOR(17 downto 0);
	LEDR : out STD_LOGIC_VECTOR(17 downto 0);
	LEDG: out STD_LOGIC_VECTOR(7 downto 0);
	HEX7, HEX6, HEX5, HEX4, HEX1, HEX0: out STD_LOGIC_VECTOR(0 to 6)
);
END testALU;

ARCHITECTURE Behavior of testALU IS

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