-- TWO'S COMPLEMENT
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY TWOS_COMP IS
	GENERIC (SIZE_COMP : positive := 8);
	PORT(
		b : in STD_LOGIC_VECTOR(SIZE_COMP-1 downto 0);
		s : out STD_LOGIC_VECTOR(SIZE_COMP-1 downto 0)
	);
END ENTITY;

ARCHITECTURE Behavior OF TWOS_COMP IS
	
COMPONENT FULL_ADDER_N IS
	GENERIC (SIZE_FA : positive := 8);
	PORT (
		a, b : in STD_LOGIC_VECTOR(SIZE_FA-1 downto 0);
		c_in : in STD_LOGIC;
		s : out STD_LOGIC_VECTOR(SIZE_FA-1 downto 0);
		c_out : out STD_LOGIC
	);
END COMPONENT;

Signal invert : STD_LOGIC_VECTOR(SIZE_COMP-1 downto 0);
Signal one : STD_LOGIC_VECTOR(SIZE_COMP-1 downto 0) := (others => '0');

BEGIN
	
	invert <= not(b);
	one(0) <= '1';
	adder : FULL_ADDER_N GENERIC MAP (SIZE_COMP) PORT MAP (a => invert, b => one, c_in => '0', s => s);
	
END Behavior;

-- ALU 8 operations, N bits
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ALU_8_N IS
GENERIC (N_BITS : positive := 8);
PORT (
	a, b : in STD_LOGIC_VECTOR(N_BITS-1 downto 0);
	sel : in STD_LOGIC_VECTOR(2 downto 0);
	
	s : out STD_LOGIC_VECTOR(N_BITS-1 downto 0);
	overAdd, overMult : out STD_LOGIC
);
END ENTITY;

ARCHITECTURE Behavior of ALU_8_N IS

COMPONENT TWOS_COMP IS
	GENERIC (SIZE_COMP : positive := 8);
	PORT(
		b : in STD_LOGIC_VECTOR(SIZE_COMP-1 downto 0);
		s : out STD_LOGIC_VECTOR(SIZE_COMP-1 downto 0)
	);
END COMPONENT;

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

Signal subOperand : STD_LOGIC_VECTOR(N_BITS-1 downto 0);
Signal c_out_sub : STD_LOGIC;
Signal c_out_add : STD_LOGIC;
	
Signal adderResult : STD_LOGIC_VECTOR(N_BITS-1 downto 0);
Signal subResult : STD_LOGIC_VECTOR(N_BITS-1 downto 0);
Signal multResult : STD_LOGIC_VECTOR(2*N_BITS-1 downto 0);
Signal multOFResult : STD_LOGIC_VECTOR(N_BITS-1 downto 0);
Signal zero : STD_LOGIC_VECTOR(N_BITS-1 downto 0) := (others => '0');
BEGIN
	
	-- Adder
	adder : FULL_ADDER_N GENERIC MAP (N_BITS) PORT MAP (a => a, b => b, s => adderResult, c_out => c_out_add);
	
	-- Subber
	inverter : TWOS_COMP GENERIC MAP (N_BITS) PORT MAP (b => b, s=>subOperand);
	subber : FULL_ADDER_N GENERIC MAP (N_BITS) PORT MAP (a => a, b => subOperand, s=> subResult, c_out => c_out_sub);
	
	-- Overflow adder & subber
	OF_add : process(a, b, c_out_add, c_out_sub, adderResult, subResult)
	BEGIN
		case sel is
			when "000" =>
				if (a(N_BITS-1)='0' and b(N_BITS-1)='0' and adderResult(N_BITS-1)='1') or
					(a(N_BITS-1)='1' and b(N_BITS-1)='1' and adderResult(N_BITS-1)='0') then
					
					overAdd <= '1';
				else
					overAdd <= '0';
				end if;
			when "001" =>
				if (a(N_BITS-1)='0' and b(N_BITS-1)='1' and subResult(N_BITS-1)='1') or
					(a(N_BITS-1)='1' and b(N_BITS-1)='0' and subResult(N_BITS-1)='0') then
					
					overAdd <= '1';
				else
					overAdd <= '0';
				end if;
			when others =>
				overAdd <= '0';
		end case;
	END process OF_add;
	
	-- Multiplier
	multiplier : MULT_N GENERIC MAP (N_BITS) PORT MAP (a => a(N_BITS-1 downto 0), b => b(N_BITS-1 downto 0), s => multResult);
	
	multOFresult <= multResult(N_BITS-1 downto 0);
	
	-- Overflow multiplier
	OF_mult : process(multResult)
	BEGIN
		if multResult(2*N_BITS-1 downto N_BITS) /= zero then
			overMult <= '1';
		else
			if (a(N_BITS-1)='0' and b(N_BITS-1)='0' and multOFresult(N_BITS-1)='1') or
				(a(N_BITS-1)='0' and b(N_BITS-1)='1' and multOFresult(N_BITS-1)='0') or
				(a(N_BITS-1)='1' and b(N_BITS-1)='0' and multOFresult(N_BITS-1)='0') or
				(a(N_BITS-1)='1' and b(N_BITS-1)='1' and multOFresult(N_BITS-1)='1') then
				overMult <= '1';
			else
				overMult <= '0';
			end if;
		end if;
	END process OF_mult;
	
	-- Multiplexer
	multiplexer : MUX_8_N GENERIC MAP (N_BITS) 
		PORT MAP (a => adderResult, b => subResult, c => multOFResult,
			e => a AND b, f => a OR b, g => NOT(a), h => a XOR b, sel => sel, s => s);


END Behavior;
