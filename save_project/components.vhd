LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY LETTER_DISPLAY IS
PORT (
		sel : in STD_LOGIC_VECTOR(1 downto 0);
		display : out STD_LOGIC_VECTOR(0 to 6)
);
END ENTITY;

ARCHITECTURE Behavior OF LETTER_DISPLAY IS
BEGIN
	with sel select
		display <=
		"1001000" when "00",
		"0110000" when "01",
		"1110001" when "10",
		"0000001" when "11";
END Behavior;

-- Hexa Display (positive)
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY HEXA_DISPLAY IS
PORT (
	input : in STD_LOGIC_VECTOR(3 downto 0);
	display : out STD_LOGIC_VECTOR(0 to 6)
);
END ENTITY;

ARCHITECTURE Behavior OF HEXA_DISPLAY IS
BEGIN
	with input select
		display <=
		"0000001" when "0000",--0
		"1001111" when "0001",--1
		"0010010" when "0010",--2
		"0000110" when "0011",--3
		"1001100" when "0100",--4
		"0100100" when "0101",--5
		"0100000" when "0110",--6
		"0001111" when "0111",--7
		"0000000" when "1000",--8
		"0000100" when "1001",--9
		"0001000" when "1010",--A
		"1100000" when "1011",--B
		"0110001" when "1100",--C
		"1000010" when "1101",--D
		"0110000" when "1110",--E
		"0111000" when "1111";--F
END Behavior;

-- Hexa Display (negative)
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY HEXA_DISPLAY_NEG IS
PORT (
	input : in STD_LOGIC_VECTOR(3 downto 0);
	s_number : out STD_LOGIC_VECTOR(0 to 6);
	s_sign : out STD_LOGIC_VECTOR(0 to 6)
);
END ENTITY;

ARCHITECTURE Behavior OF HEXA_DISPLAY_NEG IS
BEGIN
	with input select
		s_number <=
		"0000001" when "0000",-- 0
		"1001111" when "0001",-- 1
		"0010010" when "0010",-- 2
		"0000110" when "0011",-- 3
		"1001100" when "0100",-- 4
		"0100100" when "0101",-- 5
		"0100000" when "0110",-- 6
		"0001111" when "0111",-- 7
		"0000000" when "1000",-- -8
		"0001111" when "1001",-- -7
		"0100000" when "1010",-- -6
		"0100100" when "1011",-- -5
		"1001100" when "1100",-- -4
		"0000110" when "1101",-- -3
		"0010010" when "1110",-- -2
		"1001111" when "1111";-- -1
		
	with input select
		s_sign <=
		"1111111" when "0000",
		"1111111" when "0001",
		"1111111" when "0010",
		"1111111" when "0011",
		"1111111" when "0100",
		"1111111" when "0101",
		"1111111" when "0110",
		"1111111" when "0111",
		"1111110" when "1000",
		"1111110" when "1001",
		"1111110" when "1010",
		"1111110" when "1011",
		"1111110" when "1100",
		"1111110" when "1101",
		"1111110" when "1110",
		"1111110" when "1111";
END Behavior;

-- Full Adder 1 bit
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FULL_ADDER_1 IS
PORT (
	a, b, c_in : in STD_LOGIC;
	s, c_out : out STD_LOGIC
);
END ENTITY;

ARCHITECTURE Behavior OF FULL_ADDER_1 IS
BEGIN
	s <= a xor b xor c_in;
	c_out <= (a and b) or (c_in and (a xor b));
END Behavior;


-- ADDITIONNEUR N BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FULL_ADDER_N IS
generic( SIZE_FA : positive := 8);
PORT (
	a, b : in STD_LOGIC_VECTOR(SIZE_FA-1 downto 0);
	c_in : in STD_LOGIC;
	s : out STD_LOGIC_VECTOR(SIZE_FA-1 downto 0);
	c_out : out STD_LOGIC
);
END ENTITY;

ARCHITECTURE Behavior OF FULL_ADDER_N IS

COMPONENT FULL_ADDER_1 IS
PORT (
	a, b, c_in : in STD_LOGIC;
	s, c_out : out STD_LOGIC
);
END COMPONENT FULL_ADDER_1;

Signal c_out_inside : STD_LOGIC_VECTOR(SIZE_FA-2 downto 0);
BEGIN
	
	AdderArray: for i in 1 to SIZE_FA generate
	
		first_adder: if i=1 generate
			adder1: FULL_ADDER_1 PORT MAP (a => a(0), b => b(0), c_in => c_in, s => s(0), c_out => c_out_inside(0));
		end generate first_adder;
		
		generic_adder: if i>1 and i<SIZE_FA generate
			adderGeneric: FULL_ADDER_1 PORT MAP (a => a(i-1), b => b(i-1), c_in => c_out_inside(i-2), s => s(i-1), c_out => c_out_inside(i-1));
		end generate generic_adder;
		
		last_adder: if i=SIZE_FA generate
			adderSIZE: FULL_ADDER_1 PORT MAP (a => a(SIZE_FA-1), b => b(SIZE_FA-1), c_in => c_out_inside(SIZE_FA-2), s => s(SIZE_FA-1), c_out => c_out);
		end generate last_adder;
		
	end generate AdderArray;

END Behavior;

-- MULTIPLICATEUR 4 BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY MULT_4 IS
PORT (
	a, b : in STD_LOGIC_VECTOR(3 downto 0);
	s : out STD_LOGIC_VECTOR(7 downto 0)
);
END MULT_4;

ARCHITECTURE Behavior of MULT_4 IS

	COMPONENT FULL_ADDER_1 IS
		PORT (
			a, b, c_in : in STD_LOGIC;
			s, c_out : out STD_LOGIC
		);
	END COMPONENT;

	TYPE mem_S IS ARRAY(0 to 3) OF STD_LOGIC_VECTOR(4 downto 0);
	TYPE mem_ET IS ARRAY(0 to 3) OF STD_LOGIC_VECTOR(3 downto 0);
	TYPE mem_C IS ARRAY(0 to 3) OF STD_LOGIC_VECTOR(4 downto 0);
	
	Signal memSortie : mem_S;
	Signal memEt : mem_ET;
	Signal memCarry : mem_C;
	
	BEGIN
	
		memSortie(0)(4) <= '0';
		ligne: for i in 0 to 3 generate
			memCarry(i)(0) <= '0';
			
			colonne: for j in 0 to 3 generate
				memEt(i)(j) <= a(j) AND b(i);
				
				prem_1: if i=0 generate
					memSortie(0)(j) <= memEt(0)(j);
				end generate prem_1;
				
				prem_2: if i>0 generate
					add_n: FULL_ADDER_1 PORT MAP (a => memSortie(i-1)(j+1), b => memEt(i)(j), s => memSortie(i)(j), c_in => memCarry(i)(j), c_out => memCarry(i)(j+1));
				end generate prem_2;
				
			end generate colonne;
			--memSortie(i)(4) <= memCarry(i)(4);
		end generate ligne;
		
		s(0) <= memSortie(0)(0);
		s(1) <= memSortie(1)(0);
		s(2) <= memSortie(2)(0);
		s(3) <= memSortie(3)(0);
		s(4) <= memSortie(3)(1);
		s(5) <= memSortie(3)(2);
		s(6) <= memSortie(3)(3);
		s(7) <= memSortie(3)(4);
 	
END ARCHITECTURE;

-- MULTIPLICATEUR N BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY MULT_N IS
	GENERIC (SIZE_MULT : positive := 8);
	PORT (
		a, b : in STD_LOGIC_VECTOR(SIZE_MULT-1 downto 0);
		s : out STD_LOGIC_VECTOR(2*SIZE_MULT-1 downto 0)
	);
END MULT_N;

ARCHITECTURE Behavior of MULT_N IS

	COMPONENT FULL_ADDER_1 IS
		PORT (
			a, b, c_in : in STD_LOGIC;
			s, c_out : out STD_LOGIC
		);
	END COMPONENT;

	TYPE mem_S IS ARRAY(0 to SIZE_MULT-1) OF STD_LOGIC_VECTOR(SIZE_MULT downto 0);
	TYPE mem_ET IS ARRAY(0 to SIZE_MULT-1) OF STD_LOGIC_VECTOR(SIZE_MULT-1 downto 0);
	TYPE mem_C IS ARRAY(0 to SIZE_MULT-1) OF STD_LOGIC_VECTOR(SIZE_MULT downto 0);
	
	Signal memSortie : mem_S;
	Signal memEt : mem_ET;
	Signal memCarry : mem_C;
	
	BEGIN
	
		memSortie(0)(SIZE_MULT) <= '0';
		ligne: for i in 0 to SIZE_MULT-1 generate
			memCarry(i)(0) <= '0';
			
			colonne: for j in 0 to SIZE_MULT-1 generate
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
		
		s(2*SIZE_MULT-1 downto SIZE_MULT-1) <= memSortie(SIZE_MULT-1)(SIZE_MULT downto 0);
 	
END ARCHITECTURE;

-- Multiplieur n bits
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY MULTIPLIER_N IS
	GENERIC ( SIZE_MUL : positive := 8);
	PORT (
		a, b : in STD_LOGIC_VECTOR(SIZE_MUL-1 downto 0);
		s : out STD_LOGIC_VECTOR((2*SIZE_MUL)-1 downto 0)
	);
END ENTITY;

ARCHITECTURE Behavior OF MULTIPLIER_N IS

	COMPONENT FULL_ADDER_N IS
		GENERIC( SIZE_FA : positive := 8);
		PORT (
			a, b : in STD_LOGIC_VECTOR(SIZE_FA-1 downto 0);
			c_in : in STD_LOGIC;
			s : out STD_LOGIC_VECTOR(SIZE_FA-1 downto 0);
			c_out : out STD_LOGIC
		);
	END COMPONENT FULL_ADDER_N;

Signal c_out_inside : STD_LOGIC_VECTOR(SIZE_MUL-2 downto 0);
Signal transmission : STD_LOGIC_VECTOR(SIZE_MUL*(SIZE_MUL+1)-1 downto 0);
Signal rightOperand : STD_LOGIC_VECTOR((SIZE_MUL*SIZE_MUL)-1 downto 0);
Signal output : STD_LOGIC_VECTOR((SIZE_MUL*SIZE_MUL)-1 downto 0);

BEGIN
	transmission(SIZE_MUL-1 downto 0) <= '0'&a(SIZE_MUL-1 downto 1) when (b(0) = '1') else (others => '0');
	s(0) <= a(0) when (b(0) = '1') else '0';
	
	MultiplyArray: for i in 1 to SIZE_MUL-1 generate
		rightOperand(i*SIZE_MUL-1 downto (i-1)*SIZE_MUL) <= a when (b(i) = '1') else (others => '0');
	
		adderGeneric: FULL_ADDER_N GENERIC MAP(SIZE_MUL)
											PORT MAP(a => transmission(i*SIZE_MUL-1 downto (i-1)*SIZE_MUL),
														b => rightOperand(i*SIZE_MUL-1 downto (i-1)*SIZE_MUL),
														c_in => '0',
														s => output((i+1)*SIZE_MUL-1 downto i*SIZE_MUL),
														c_out => transmission((i+1)*SIZE_MUL-1));
	
		-- decalage
		transmission((i+1)*SIZE_MUL-2 downto i*SIZE_MUL) <= output((i+1)*SIZE_MUL-1 downto i*SIZE_MUL+1);
		s(i) <= output(i*SIZE_MUL);
	end generate MultiplyArray;
	
	s((2*SIZE_MUL)-1 downto SIZE_MUL) <= transmission(SIZE_MUL*(SIZE_MUL+1)-1 downto SIZE_MUL*SIZE_MUL);

END Behavior;

-- REGISTRE N BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY REGISTER_N IS
	GENERIC (SIZE_REG: positive := 8);
	PORT (
		d : IN std_logic_vector(SIZE_REG-1 downto 0);
		en, clk, r : IN std_logic; -- enable clock, clock, reset
		q : OUT std_logic_vector(SIZE_REG-1 downto 0)
	);
END ENTITY;

ARCHITECTURE Behavior of REGISTER_N IS
BEGIN
	Process(clk, r)
	begin
		if r = '0' then
			q <= (others=>'0');
		elsif RISING_EDGE(clk) and en='1' then
			q <= d;
		end if;
	end process;
END Behavior;

-- ARITHMETIC LOGIC UNIT 8 OPERATIONS AND N BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ALU_N IS
GENERIC( SIZE_ALU : positive := 8);
PORT (
	a, b : in STD_LOGIC_VECTOR(SIZE_ALU-1 downto 0);
	sel : in STD_LOGIC_VECTOR(2 downto 0);
	
	s : out STD_LOGIC_VECTOR(SIZE_ALU-1 downto 0);
	c_out : out STD_LOGIC
);
END ENTITY;

ARCHITECTURE Behavior of ALU_N IS

	COMPONENT FULL_ADDER_N IS
	GENERIC( SIZE_FA : positive := 8);
	PORT (
		a, b : in STD_LOGIC_VECTOR(SIZE_FA-1 downto 0);
		s : out STD_LOGIC_VECTOR(SIZE_FA-1 downto 0);
		c_out : out STD_LOGIC
	);
	END COMPONENT FULL_ADDER_N;

	COMPONENT MULT_N IS
		GENERIC (SIZE_MULT : positive := 8);
		PORT (
			a, b : in STD_LOGIC_VECTOR(SIZE_MULT-1 downto 0);
			s : out STD_LOGIC_VECTOR(2*SIZE_MULT-1 downto 0)
		);
	END COMPONENT;

	COMPONENT MUX_8_N IS
		GENERIC( SIZE_MUX_8 : positive := 8);
		PORT (
			a, b, c, d, e, f, g, h : in STD_LOGIC_VECTOR(SIZE_MUX_8-1 downto 0) := (others => '0');
			sel : in STD_LOGIC_VECTOR(2 downto 0);
			s : out STD_LOGIC_VECTOR(SIZE_MUX_8-1 downto 0)
		);
	END COMPONENT;

Signal adderResult : STD_LOGIC_VECTOR(SIZE_ALU-1 downto 0);
Signal multResult : STD_LOGIC_VECTOR(SIZE_ALU-1 downto 0);
BEGIN
	
	SwagAdder : FULL_ADDER_N GENERIC MAP (SIZE_ALU) PORT MAP (a => a, b => b, s => adderResult, c_out => c_out);
	SwagMult : MULT_N GENERIC MAP (SIZE_ALU/2) PORT MAP (a => a(7 downto 0), b => b(7 downto 0), s => multResult);
	SwagMux : MUX_8_N GENERIC MAP (SIZE_ALU) PORT MAP (a => a AND b, b => a OR b, c => adderResult, d => multResult, sel => sel, s => s);


END Behavior;

-- FLIPFLOP 1 BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FLIPFLOP_1 IS
	PORT (
		D : in STD_LOGIC;
		set, reset, clk : in STD_LOGIC;
		S : out STD_LOGIC
	);
END ENTITY FLIPFLOP_1;

ARCHITECTURE Behavior OF FLIPFLOP_1 IS
BEGIN
	PROCESS(clk)
	BEGIN
		if (reset = '0') then S <= '0';
		elsif (set = '1') then S <= '1';
		elsif (clk'event and clk = '1') then S <= D;
		end if;
	END PROCESS;
END Behavior;

-- FLIPFLOP N BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FLIPFLOP_N IS
	GENERIC (SIZE_FF : positive := 8);
	PORT (
		D : in STD_LOGIC_VECTOR(SIZE_FF-1 downto 0);
		set, reset, clk : in STD_LOGIC;
		S : out STD_LOGIC_VECTOR(SIZE_FF-1 downto 0)
	);
END ENTITY FLIPFLOP_N;

ARCHITECTURE Behavior OF FLIPFLOP_N IS
BEGIN
	PROCESS(clk)
	BEGIN
		if (reset = '0') then S <= (others => '0');
		elsif (set = '1') then S <= (others => '1');
		elsif (clk'event and clk = '1') then S <= D;
		end if;
	END PROCESS;
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY STATE_DISPLAY IS
PORT (
	input : in STD_LOGIC_VECTOR(8 downto 0);
	display : out STD_LOGIC_VECTOR(0 to 6)
);
END ENTITY;

ARCHITECTURE Behavior OF STATE_DISPLAY IS
BEGIN
	with input select
		display <=
		"0001000" when "000000001",--A
		"1100000" when "000000010",--B
		"0110001" when "000000100",--C
		"1000010" when "000001000",--D
		"0110000" when "000010000",--E
		"0111000" when "000100000",--F
		"0100001" when "001000000",--G
		"1001000" when "010000000",--H
		"1001111" when "100000000",--I
		"1111111" when others;
END Behavior;

-- FSM 4 '0' ou 4 '1' à la suite
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FSM_4 IS
	PORT(
		w : in STD_LOGIC; -- entrée
		reset, clk : in STD_LOGIC;
		x : out STD_LOGIC;
		state : out STD_LOGIC_VECTOR(8 downto 0)
	);
END ENTITY FSM_4;

ARCHITECTURE Behavior OF FSM_4 IS
	COMPONENT FLIPFLOP_1 IS
		PORT (
			D : in STD_LOGIC;
			set, reset, clk : in STD_LOGIC;
			S : out STD_LOGIC
		);
	END COMPONENT FLIPFLOP_1;
	
	Signal ns, cs : STD_LOGIC_VECTOR(8 downto 0);
BEGIN
	ns(0) <= NOT(cs(0)) AND cs(1) AND cs(2) AND cs(3) AND cs(4) AND cs(5) AND cs(6) AND cs(7) AND cs(8); --A
	ns(1) <= NOT(w) AND (cs(0) OR cs(5) OR cs(6) OR cs(7) OR cs(8));--B
	ns(2) <= cs(1) AND NOT(w);--C
	ns(3) <= cs(2) AND NOT(w);--D
	ns(4) <= (cs(3) AND NOT(w)) OR (cs(4) AND NOT(w));--E
	ns(5) <= w AND (cs(0) OR cs(1) OR cs(2) OR cs(3) OR cs(4));--F
	ns(6) <= cs(5) AND w;--G
	ns(7) <= cs(6) AND w;--H
	ns(8) <= (cs(7) AND w) OR (cs(8) AND w);--I
	
	flip0: FLIPFLOP_1 port map(D=>ns(0), S=>cs(0), set=>NOT(reset), reset=>'1', clk=>clk);
	flip1: FLIPFLOP_1 port map(D=>ns(1), S=>cs(1), set=>'0', reset=>reset, clk=>clk);
	flip2: FLIPFLOP_1 port map(D=>ns(2), S=>cs(2), set=>'0', reset=>reset, clk=>clk);
	flip3: FLIPFLOP_1 port map(D=>ns(3), S=>cs(3), set=>'0', reset=>reset, clk=>clk);
	flip4: FLIPFLOP_1 port map(D=>ns(4), S=>cs(4), set=>'0', reset=>reset, clk=>clk);
	flip5: FLIPFLOP_1 port map(D=>ns(5), S=>cs(5), set=>'0', reset=>reset, clk=>clk);
	flip6: FLIPFLOP_1 port map(D=>ns(6), S=>cs(6), set=>'0', reset=>reset, clk=>clk);
	flip7: FLIPFLOP_1 port map(D=>ns(7), S=>cs(7), set=>'0', reset=>reset, clk=>clk);
	flip8: FLIPFLOP_1 port map(D=>ns(8), S=>cs(8), set=>'0', reset=>reset, clk=>clk);
	
	x <= cs(4) OR cs(8);
	state <= cs;

END Behavior;