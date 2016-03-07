-- FULL ADDER 1 BIT
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

-- TWO'S COMPLEMENT
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY TWOS_COMP IS
GENERIC

-- FULL ADDER N BITS
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FULL_ADDER_N IS
GENERIC (SIZE_FA : positive := 8);
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

-- ALU 8 operations, N bits
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ALU_8_N IS
GENERIC( N_BITS : positive := 8);
PORT (
	a, b : in STD_LOGIC_VECTOR(N_BITS-1 downto 0);
	sel : in STD_LOGIC_VECTOR(2 downto 0);
	
	s : out STD_LOGIC_VECTOR(N_BITS-1 downto 0);
	c_out, overflow : out STD_LOGIC
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

Signal adderResult : STD_LOGIC_VECTOR(N_BITS-1 downto 0);
Signal subResult : STD_LOGIC_VECTOR(N_BITS-1 downto 0);
Signal multResult : STD_LOGIC_VECTOR(2*N_BITS-1 downto 0);
Signal multOFResult : STD_LOGIC_VECTOR(N_BITS-1 downto 0);
BEGIN
	
	adder : FULL_ADDER_N GENERIC MAP (N_BITS) PORT MAP (a => a, b => b, s => adderResult, c_out => c_out);
	multiplier : MULT_N GENERIC MAP (N_BITS) PORT MAP (a => a(7 downto 0), b => b(7 downto 0), s => multResult);
	
	multOFresult <= multResult(N_BITS-1 downto 0);
	
	OF_check : process
	BEGIN
		if multResult(2*N_BITS-1 downto N_BITS) = (others => '0') then
			overflow <= '1';
		end if;
	END process OF_check;
	
	multiplexer : MUX_8_N GENERIC MAP (N_BITS) 
		PORT MAP (a => adderResult, b => subResult, c => multOFResult,
			e => a AND b, f => a OR b, g => NOT(a), h => a XOR b, sel => sel, s => s);


END Behavior;
